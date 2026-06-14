/**
 * 标签管理 ViewModel
 *
 * 统一管理标签的增删改查，数据来源：
 * - Tag 表：标签持久化及顶栏显示状态
 * - Task 表：标签引用计数
 */
import { TaskRepository, TagRepository } from 'core.database';

/**
 * 标签统计信息
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
  /** 标签列表（含引用统计） */
  @Trace tagStats: TagStat[] = [];
  @Trace isLoading: boolean = false;
  /** 当前编辑目标的标签名（供编辑弹窗回调使用） */
  editTarget: string = '';

  private taskRepo: TaskRepository = new TaskRepository();
  private tagRepo: TagRepository = new TagRepository();

  // ==================== 查 ====================

  /**
   * 加载全部标签列表（Tag 表 + 任务引用计数）
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

      // 2. 从 Tag 表加载已持久化标签，合并计数与显示状态
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

  // ==================== 增 ====================

  /**
   * 新建标签
   * @returns 空字符串表示成功，非空=错误信息
   */
  async createTag(name: string): Promise<string> {
    const trimmed = name.trim();
    if (!trimmed) return '';
    if (this.tagStats.some(s => s.tag === trimmed)) {
      return '标签已存在';
    }
    const id = await this.tagRepo.add(trimmed);
    if (id <= 0) {
      return '创建标签失败';
    }
    this.tagStats = [...this.tagStats, { tag: trimmed, taskCount: 0, showInTopBar: false }];
    return '';
  }

  // ==================== 改（重命名） ====================

  /**
   * 重命名标签
   * @returns 空字符串表示成功，非空=错误信息
   */
  async renameTag(oldName: string, newName: string): Promise<string> {
    const trimmed = newName.trim();
    if (!trimmed) {
      return '标签名称不能为空';
    }
    if (trimmed === oldName) {
      return '';
    }
    if (this.tagStats.some(s => s.tag === trimmed)) {
      return '标签已存在';
    }
    try {
      await this.taskRepo.renameTag(oldName, trimmed);
      await this.tagRepo.rename(oldName, trimmed);
      await this.loadTags();
      return '';
    } catch (e) {
      console.error('Rename tag failed:', e);
      return '重命名失败';
    }
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

  // ==================== 删 ====================

  /**
   * 删除标签（同时清除任务表中的引用）
   */
  async deleteTag(tag: string): Promise<void> {
    await this.taskRepo.deleteTag(tag);
    await this.tagRepo.delete(tag);
    await this.loadTags();
  }
}
