/**
 * 收藏标签管理 ViewModel
 * 只处理收藏表的标签
 */
import { CollectionRepository } from '../repository/CollectionRepository';

/**
 * 标签统计
 */
export interface CollectionTagStat {
  tag: string;
  /** 收藏中引用数 */
  count: number;
}

@ObservedV2
export class CollectionTagManageViewModel {
  /** 标签列表 */
  @Trace tagStats: CollectionTagStat[] = [];
  /** 是否正在编辑 */
  @Trace editingTag: string = '';
  /** 编辑中的值 */
  @Trace editValue: string = '';
  @Trace isLoading: boolean = false;

  private repo: CollectionRepository = new CollectionRepository();

  /**
   * 加载标签列表（仅收藏表）
   */
  async loadTags(): Promise<void> {
    this.isLoading = true;
    try {
      const countMap = new Map<string, number>();
      const all = await this.repo.queryAll();
      console.log(`CollectionTagManage: queryAll returned ${all.length} items`);
      for (const c of all) {
        if (!c.tag) {
          console.log(`CollectionTagManage: item id=${c.id} has no tag`);
          continue;
        }
        const tags = c.tag.split(',').map(s => s.trim()).filter(s => s);
        for (const tag of tags) {
          countMap.set(tag, (countMap.get(tag) || 0) + 1);
        }
      }
      console.log(`CollectionTagManage: tagCount=${countMap.size}`);
      const newStats: CollectionTagStat[] = [];
      countMap.forEach((count, tag) => {
        newStats.push({ tag, count });
      });
      this.tagStats = newStats;

    } catch (e) {
      console.error('Load collection tags failed:', e);
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
   * 新建标签，返回空字符串=成功，非空=错误信息
   */
  createTag(name: string): string {
    const trimmed = name.trim();
    if (!trimmed) return '';
    if (this.tagStats.some(s => s.tag === trimmed)) {
      return '标签已存在';
    }
    this.tagStats = [...this.tagStats, { tag: trimmed, count: 0 }];
    return '';
  }
}
