/**
 * 备忘录编辑 ViewModel
 * 管理备忘录编辑页的状态和业务逻辑
 */
import { Memo, EditPageParams } from 'core.model';
import { MemoRepository } from '../repository/MemoRepository';
import { DateUtil } from 'core.util';

@Observed
export class MemoEditViewModel {
  content: string = '';
  isEdit: boolean = false;
  memoId: number = 0;

  private repo: MemoRepository = new MemoRepository();

  /**
   * 初始化（根据路由参数判断新增/编辑）
   */
  async init(params: EditPageParams | undefined): Promise<void> {
    if (params && params.id) {
      this.isEdit = true;
      this.memoId = params.id;
      await this.loadMemo();
    }
  }

  async loadMemo(): Promise<void> {
    try {
      const memo = await this.repo.queryById(this.memoId);
      if (memo) {
        this.content = memo.content;
      }
    } catch (e) {
      console.error('Load memo failed:', e);
    }
  }

  async save(): Promise<boolean> {
    if (!this.content.trim()) return false;

    try {
      const memo = new Memo();
      memo.content = this.content;

      if (this.isEdit) {
        memo.id = this.memoId;
        await this.repo.update(memo);
      } else {
        memo.createTime = DateUtil.getNow();
        memo.updateTime = DateUtil.getNow();
        await this.repo.insert(memo);
      }
      return true;
    } catch (e) {
      console.error('Save memo failed:', e);
      return false;
    }
  }
}
