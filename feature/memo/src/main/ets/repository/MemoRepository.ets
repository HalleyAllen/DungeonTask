/**
 * 备忘录数据操作类
 * 支持关键词搜索和多端同步
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Memo } from 'core.model';
import { DateUtil } from 'core.util';

export class MemoRepository {
  private readonly TABLE = 'memo';

  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询所有备忘录（按 createTime 倒序）
   */
  async queryAll(): Promise<Memo[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.orderByDesc('createTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 关键词搜索
   */
  async search(keyword: string): Promise<Memo[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.like('content', `%${keyword}%`);
    predicates.orderByDesc('createTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 按ID查询
   */
  async queryById(id: number): Promise<Memo | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);

    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 插入备忘录
   */
  async insert(memo: Memo): Promise<number> {
    const store = this.getStore();
    const now = DateUtil.getNow();
    const valueBucket: relationalStore.ValuesBucket = {
      content: memo.content,
      deviceId: memo.deviceId || '',
      syncStatus: 0,
      createTime: memo.createTime || now,
      updateTime: now
    };
    return await store.insert(this.TABLE, valueBucket);
  }

  /**
   * 快速创建备忘录（仅需内容）
   */
  async quickCreate(content: string, deviceId: string = ''): Promise<number> {
    const memo = new Memo();
    memo.content = content;
    memo.deviceId = deviceId;
    return await this.insert(memo);
  }

  /**
   * 更新备忘录
   */
  async update(memo: Memo): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', memo.id);

    const valueBucket: relationalStore.ValuesBucket = {
      content: memo.content,
      deviceId: memo.deviceId,
      syncStatus: 0,
      updateTime: DateUtil.getNow()
    };

    await store.update(valueBucket, predicates);
  }

  /**
   * 删除备忘录
   */
  async delete(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  // ==================== 同步相关 ====================

  /**
   * 查询变更记录（增量同步）
   */
  async queryChangedSince(sinceTime: number): Promise<Memo[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.greaterThan('updateTime', sinceTime);
    predicates.orderByAsc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 标记已同步
   */
  async markSynced(ids: number[]): Promise<void> {
    const store = this.getStore();
    for (const id of ids) {
      const predicates = new relationalStore.RdbPredicates(this.TABLE);
      predicates.equalTo('id', id);
      const valueBucket: relationalStore.ValuesBucket = {
        syncStatus: 1,
        updateTime: DateUtil.getNow()
      };
      await store.update(valueBucket, predicates);
    }
  }

  private parseResult(result: relationalStore.ResultSet): Memo[] {
    const list: Memo[] = [];
    while (result.goToNextRow()) {
      const m = new Memo();
      m.id = result.getLong(result.getColumnIndex('id'));
      m.content = result.getString(result.getColumnIndex('content'));
      m.deviceId = result.getString(result.getColumnIndex('deviceId'));
      m.syncStatus = result.getLong(result.getColumnIndex('syncStatus'));
      m.createTime = result.getLong(result.getColumnIndex('createTime'));
      m.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(m);
    }
    result.close();
    return list;
  }
}
