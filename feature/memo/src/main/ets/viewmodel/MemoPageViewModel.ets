/**
 * 备忘录列表页 ViewModel
 * 管理备忘录列表数据加载、搜索、删除等业务逻辑
 */
import { Memo } from 'core.model';
import { MemoRepository } from '../repository/MemoRepository';

@Observed
export class MemoPageViewModel {
  memos: Memo[] = [];
  searchText: string = '';

  private repo: MemoRepository = new MemoRepository();

  async loadMemos(): Promise<void> {
    try {
      if (this.searchText) {
        this.memos = await this.repo.search(this.searchText);
      } else {
        this.memos = await this.repo.queryAll();
      }
    } catch (e) {
      console.error('Load memos failed:', e);
    }
  }

  async deleteMemo(id: number): Promise<void> {
    try {
      await this.repo.delete(id);
      await this.loadMemos();
    } catch (e) {
      console.error('Delete memo failed:', e);
    }
  }
}
