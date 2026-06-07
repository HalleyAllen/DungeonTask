/**
 * 标签管理 ViewModel
 */
import { TaskRepository } from '../repository/TaskRepository';

/**
 * 标签统计
 */
export interface TagStat {
  tag: string;
  taskCount: number;
}

@Observed
export class TagManageViewModel {
  /** 标签列表（含任务数） */
  tagStats: TagStat[] = [];
  /** 是否正在编辑 */
  editingTag: string = '';
  /** 编辑中的值 */
  editValue: string = '';
  /** 是否显示新建弹窗 */
  showAddDialog: boolean = false;
  /** 新建标签名称 */
  newTagName: string = '';
  isLoading: boolean = false;

  private repo: TaskRepository = new TaskRepository();

  /**
   * 加载标签列表
   */
  async loadTags(): Promise<void> {
    this.isLoading = true;
    try {
      const allTasks = await this.repo.queryAll();
      const countMap = new Map<string, number>();
      for (const t of allTasks) {
        if (!t.tag) continue;
        const tags = t.tag.split(',').map(s => s.trim()).filter(s => s);
        for (const tag of tags) {
          countMap.set(tag, (countMap.get(tag) || 0) + 1);
        }
      }
      this.tagStats = [];
      countMap.forEach((count, tag) => {
        this.tagStats.push({ tag: tag, taskCount: count });
      });
    } catch (e) {
      console.error('Load tags failed:', e);
      this.tagStats = [];
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 开始编辑标签
   */
  startEdit(tag: string): void {
    this.editingTag = tag;
    this.editValue = tag;
  }

  /**
   * 取消编辑
   */
  cancelEdit(): void {
    this.editingTag = '';
    this.editValue = '';
  }

  /**
   * 确认重命名
   */
  async confirmRename(): Promise<void> {
    const newName = this.editValue.trim();
    if (!newName || newName === this.editingTag) {
      this.cancelEdit();
      return;
    }
    // 检查重名
    if (this.tagStats.some(s => s.tag === newName)) {
      console.error('标签已存在');
      return;
    }
    await this.repo.renameTag(this.editingTag, newName);
    this.cancelEdit();
    await this.loadTags();
  }

  /**
   * 删除标签
   */
  async deleteTag(tag: string): Promise<void> {
    await this.repo.deleteTag(tag);
    await this.loadTags();
  }

  /**
   * 新建标签
   */
  async createTag(): Promise<void> {
    const name = this.newTagName.trim();
    if (!name) return;
    if (this.tagStats.some(s => s.tag === name)) {
      console.error('标签已存在');
      return;
    }
    // 新标签直接加入列表（无关联任务）
    this.tagStats.push({ tag: name, taskCount: 0 });
    this.showAddDialog = false;
    this.newTagName = '';
  }

  /**
   * 关闭新建弹窗
   */
  dismissAddDialog(): void {
    this.showAddDialog = false;
    this.newTagName = '';
  }
}
