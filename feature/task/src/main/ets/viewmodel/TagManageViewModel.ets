/**
 * 标签管理 ViewModel（仅任务表）
 */
import { Task } from 'core.model';
import { TaskRepository, TagRepository } from 'core.database';

/**
 * 标签统计
 */
export interface TagStat {
  tag: string;
  /** 任务中引用数 */
  taskCount: number;
  /** 是否在顶栏显示 */
  showInTopBar: boolean;
}

@ObservedV2
export class TagManageViewModel {
  /** 标签列表（含引用数） */
  @Trace tagStats: TagStat[] = [];
  /** 是否正在编辑 */
  @Trace editingTag: string = '';
  /** 编辑中的值 */
  @Trace editValue: string = '';
  @Trace isLoading: boolean = false;

  private taskRepo: TaskRepository = new TaskRepository();
  private tagRepo: TagRepository = new TagRepository();

  /**
   * 加载标签列表（Tag 表 + 任务表中的引用计数）
   */
  async loadTags(): Promise<void> {
    this.isLoading = true;
    try {
      // 1. 从任务表统计各标签引用数
      const countMap = new Map<string, number>();
      const all = await this.taskRepo.queryAll();
      for (const t of all) {
        if (!t.tag) continue;
        const tags = t.tag.split(',').map((s: string) => s.trim()).filter((s: string) => s.length > 0);
        for (const tag of tags) {
          countMap.set(tag, (countMap.get(tag) || 0) + 1);
        }
      }

      // 2. 从 Tag 表加载已持久化的标签，合并计数和显示状态
      const persistedTags = await this.tagRepo.queryAll();
      const tagSet = new Set<string>();
      const showMap = new Map<string, boolean>();
      for (const pt of persistedTags) {
        tagSet.add(pt.name);
        showMap.set(pt.name, pt.showInTopBar !== 0);
      }
      countMap.forEach((_: number, tag: string) => tagSet.add(tag));

      const newStats: TagStat[] = [];
      tagSet.forEach((tag: string) => {
        newStats.push({ tag, taskCount: countMap.get(tag) || 0, showInTopBar: showMap.get(tag) || false });
      });

      this.tagStats = newStats;
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
    if (this.tagStats.some(s => s.tag === newName)) {
      console.error('标签已存在');
      return;
    }
    await this.taskRepo.renameTag(this.editingTag, newName);
    await this.tagRepo.rename(this.editingTag, newName);
    this.cancelEdit();
    await this.loadTags();
  }

  /**
   * 删除标签
   */
  async deleteTag(tag: string): Promise<void> {
    await this.taskRepo.deleteTag(tag);
    await this.tagRepo.delete(tag);
    await this.loadTags();
  }

  /**
   * 切换标签顶栏显示状态
   */
  async toggleShowInTopBar(tag: string): Promise<void> {
    const stat = this.tagStats.find((s: TagStat) => s.tag === tag);
    if (!stat) return;
    stat.showInTopBar = !stat.showInTopBar;
    this.tagStats = [...this.tagStats];
    await this.tagRepo.setShowInTopBar(tag, stat.showInTopBar);
  }

  /**
   * 新建标签，返回空字符串=成功，非空=错误信息
   */
  createTag(name: string): string {
    const trimmed = name.trim();
    if (!trimmed) return '';
    if (this.tagStats.some(s => s.tag === trimmed)) {
      return '标签已存在';
    }
    this.tagStats = [...this.tagStats, { tag: trimmed, taskCount: 0, showInTopBar: false }];
    return '';
  }
}
