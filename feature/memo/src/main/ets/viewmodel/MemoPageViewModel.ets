/**
 * 备忘录列表页 ViewModel
 * 管理备忘录列表数据加载、搜索、删除等业务逻辑
 */
import { Memo } from 'core.model';
import { MemoRepository } from 'core.database';
import { Logger } from 'common.util';

const TAG = 'MemoPageVM';

@Observed
export class MemoPageViewModel {
  memos: Memo[] = [];
  searchText: string = '';

  private repo: MemoRepository = new MemoRepository();

  /**
   * 页面可见时刷新
   */
  async refresh(): Promise<void> {
    await this.loadMemos();
  }

  async loadMemos(): Promise<void> {
    try {
      if (this.searchText) {
        this.memos = await this.repo.search(this.searchText);
      } else {
        this.memos = await this.repo.findAll();
      }
    } catch (e) {
      Logger.error(TAG, 'loadMemos failed', e);
    }
  }

  async deleteMemo(id: number): Promise<void> {
    try {
      await this.repo.deleteById(id);
      await this.loadMemos();
    } catch (e) {
      Logger.error(TAG, 'deleteMemo failed', e);
    }
  }
}
