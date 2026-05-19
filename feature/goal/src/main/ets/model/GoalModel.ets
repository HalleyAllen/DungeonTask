/**
 * 目标数据操作类
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Goal } from 'core.model';
import { DateUtil, Constants } from 'core.util';

export class GoalModel {
  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询顶级目标（parentId = 0）
   */
  async queryTopLevel(filter: string = 'all'): Promise<Goal[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('goal');
    predicates.equalTo('parentId', 0);
    
    if (filter === 'active') {
      predicates.equalTo('completed', 0);
    } else if (filter === 'completed') {
      predicates.equalTo('completed', 1);
    }
    
    predicates.orderByAsc('sortOrder');
    predicates.orderByDesc('createTime');
    
    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询子目标
   */
  async queryByParentId(parentId: number): Promise<Goal[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('goal');
    predicates.equalTo('parentId', parentId);
    predicates.orderByAsc('sortOrder');
    
    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询所有目标
   */
  async queryAll(): Promise<Goal[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('goal');
    predicates.orderByAsc('level');
    predicates.orderByAsc('sortOrder');
    
    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 按ID查询
   */
  async queryById(id: number): Promise<Goal | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('goal');
    predicates.equalTo('id', id);
    
    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 插入目标
   */
  async insert(goal: Goal): Promise<number> {
    const store = this.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      title: goal.title,
      type: goal.type || Constants.GoalType.SHORT_TERM,
      progress: goal.progress || 0,
      completed: goal.completed || 0,
      parentId: goal.parentId || 0,
      level: goal.level || 0,
      sortOrder: goal.sortOrder || 0,
      createTime: goal.createTime || DateUtil.getNow(),
      updateTime: goal.updateTime || DateUtil.getNow()
    };
    
    const result = await store.insert('goal', valueBucket);
    return result;
  }

  /**
   * 更新目标
   */
  async update(goal: Goal): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('goal');
    predicates.equalTo('id', goal.id);
    
    const valueBucket: relationalStore.ValuesBucket = {
      title: goal.title,
      type: goal.type,
      progress: goal.progress,
      completed: goal.completed,
      parentId: goal.parentId,
      level: goal.level,
      sortOrder: goal.sortOrder,
      updateTime: DateUtil.getNow()
    };
    
    await store.update('goal', valueBucket, predicates);
  }

  /**
   * 删除目标（同时删除所有子目标）
   */
  async delete(id: number): Promise<void> {
    // 递归删除子目标
    await this.deleteChildren(id);
    
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('goal');
    predicates.equalTo('id', id);
    await store.delete('goal', predicates);
  }

  private async deleteChildren(parentId: number): Promise<void> {
    const children = await this.queryByParentId(parentId);
    for (const child of children) {
      await this.deleteChildren(child.id);
      const store = this.getStore();
      const predicates = new relationalStore.RdbPredicates('goal');
      predicates.equalTo('id', child.id);
      await store.delete('goal', predicates);
    }
  }

  /**
   * 更新父目标进度（子目标的平均值）
   */
  async updateParentProgress(parentId: number): Promise<void> {
    if (parentId === 0) return;

    const children = await this.queryByParentId(parentId);
    if (children.length === 0) return;

    const avgProgress = Math.round(
      children.reduce((sum, child) => sum + child.progress, 0) / children.length
    );
    
    const allCompleted = children.every(child => child.completed === 1);

    const parent = await this.queryById(parentId);
    if (parent) {
      parent.progress = avgProgress;
      parent.completed = allCompleted ? 1 : 0;
      await this.update(parent);
      
      // 递归更新更上层的父目标
      await this.updateParentProgress(parent.parentId);
    }
  }

  private parseResult(result: relationalStore.ResultSet): Goal[] {
    const list: Goal[] = [];
    while (result.goToNextRow()) {
      const goal = new Goal();
      goal.id = result.getLong(result.getColumnIndex('id'));
      goal.title = result.getString(result.getColumnIndex('title'));
      goal.type = result.getLong(result.getColumnIndex('type'));
      goal.progress = result.getLong(result.getColumnIndex('progress'));
      goal.completed = result.getLong(result.getColumnIndex('completed'));
      goal.parentId = result.getLong(result.getColumnIndex('parentId'));
      goal.level = result.getLong(result.getColumnIndex('level'));
      goal.sortOrder = result.getLong(result.getColumnIndex('sortOrder'));
      goal.createTime = result.getLong(result.getColumnIndex('createTime'));
      goal.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(goal);
    }
    result.close();
    return list;
  }
}
