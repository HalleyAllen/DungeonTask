/**
 * 目标列表 ViewModel
 */
import { Goal } from 'core.model';
import { GoalModel } from '../model/GoalModel';
import { Constants } from 'core.util';

interface TreeNode {
  goal: Goal;
  children: TreeNode[];
  expanded: boolean;
}

export class GoalViewModel {
  @State treeData: TreeNode[] = [];
  @State filterType: 'all' | 'active' | 'completed' = 'all';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  private goalModel: GoalModel = new GoalModel();
  
  /** 最大层级 */
  readonly MAX_LEVEL = Constants.MAX_GOAL_LEVEL;

  /**
   * 加载目标树
   */
  async loadGoals(): Promise<void> {
    this.isLoading = true;
    
    try {
      const topLevelGoals = await this.goalModel.queryTopLevel(this.filterType);
      this.treeData = await this.buildTree(topLevelGoals);
    } catch (e) {
      this.errorMessage = '加载失败';
      console.error('Load goals failed:', e);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 构建树形结构
   */
  private async buildTree(goals: Goal[]): Promise<TreeNode[]> {
    const nodes: TreeNode[] = [];
    
    for (const goal of goals) {
      const node: TreeNode = {
        goal: goal,
        children: [],
        expanded: false
      };
      
      // 加载子目标
      const children = await this.goalModel.queryByParentId(goal.id);
      if (children.length > 0) {
        node.children = await this.buildTree(children);
      }
      
      nodes.push(node);
    }
    
    return nodes;
  }

  /**
   * 切换展开状态
   */
  toggleExpand(nodeIndex: number[]): void {
    if (nodeIndex.length === 0) return;
    
    let nodes = this.treeData;
    for (let i = 0; i < nodeIndex.length - 1; i++) {
      nodes = nodes[nodeIndex[i]].children;
    }
    
    const targetIndex = nodeIndex[nodeIndex.length - 1];
    if (nodes[targetIndex]) {
      nodes[targetIndex].expanded = !nodes[targetIndex].expanded;
    }
  }

  /**
   * 判断是否可以添加子目标
   */
  canAddChild(level: number): boolean {
    return level < this.MAX_LEVEL;
  }

  /**
   * 添加子目标
   */
  async addChildGoal(parentId: number, title: string): Promise<void> {
    const parent = await this.goalModel.queryById(parentId);
    if (!parent) return;

    if (parent.level >= this.MAX_LEVEL) {
      this.errorMessage = '已达到最大层级（5层）';
      return;
    }

    const newGoal = new Goal();
    newGoal.title = title;
    newGoal.parentId = parentId;
    newGoal.level = parent.level + 1;
    newGoal.type = parent.type;
    newGoal.createTime = Date.now();
    
    await this.goalModel.insert(newGoal);
    await this.goalModel.updateParentProgress(parentId);
    await this.loadGoals();
  }

  /**
   * 添加顶级目标
   */
  async addGoal(title: string, type: number = 1): Promise<void> {
    const goal = new Goal();
    goal.title = title;
    goal.type = type;
    goal.level = 0;
    goal.parentId = 0;
    goal.createTime = Date.now();
    
    await this.goalModel.insert(goal);
    await this.loadGoals();
  }

  /**
   * 更新目标
   */
  async updateGoal(goal: Goal): Promise<void> {
    await this.goalModel.update(goal);
    await this.goalModel.updateParentProgress(goal.parentId);
    await this.loadGoals();
  }

  /**
   * 更新进度
   */
  async updateProgress(goal: Goal, progress: number): Promise<void> {
    goal.progress = Math.min(100, Math.max(0, progress));
    goal.completed = goal.progress >= 100 ? 1 : 0;
    
    await this.goalModel.update(goal);
    await this.goalModel.updateParentProgress(goal.id);
    await this.goalModel.updateParentProgress(goal.parentId);
    await this.loadGoals();
  }

  /**
   * 删除目标
   */
  async deleteGoal(id: number): Promise<void> {
    const goal = await this.goalModel.queryById(id);
    if (goal) {
      await this.goalModel.delete(id);
      await this.goalModel.updateParentProgress(goal.parentId);
      await this.loadGoals();
    }
  }

  /**
   * 按ID查询
   */
  async getGoalById(id: number): Promise<Goal | null> {
    return await this.goalModel.queryById(id);
  }

  /**
   * 获取子目标列表
   */
  async getChildren(parentId: number): Promise<Goal[]> {
    return await this.goalModel.queryByParentId(parentId);
  }
}
