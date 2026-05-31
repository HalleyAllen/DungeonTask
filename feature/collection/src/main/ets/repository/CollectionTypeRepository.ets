/**
 * 收藏类型数据操作类
 * 管理内置类型 + 用户自定义类型，支持多端同步
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { CollectionType } from 'core.model';
import { DateUtil } from 'core.util';

export class CollectionTypeRepository {
  private readonly TABLE = 'collection_type';

  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询所有类型（按 sortOrder 排序）
   */
  async queryAll(): Promise<CollectionType[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 只查询内置类型
   */
  async queryBuiltIn(): Promise<CollectionType[]> {
    const all = await this.queryAll();
    return all.filter(t => t.isBuiltIn === 1);
  }

  /**
   * 只查询自定义类型
   */
  async queryCustom(): Promise<CollectionType[]> {
    const all = await this.queryAll();
    return all.filter(t => t.isBuiltIn === 0);
  }

  /**
   * 按名称查询
   */
  async queryByName(name: string): Promise<CollectionType | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('name', name);

    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 创建自定义类型
   */
  async createCustom(label: string, deviceId: string = ''): Promise<CollectionType> {
    const name = `custom_${DateUtil.getNow()}`;
    const all = await this.queryAll();
    const maxOrder = all.reduce((max, t) => Math.max(max, t.sortOrder), 0);

    const store = this.getStore();
    const now = DateUtil.getNow();
    const valueBucket: relationalStore.ValuesBucket = {
      name: name,
      label: label,
      isBuiltIn: 0,
      sortOrder: maxOrder + 1,
      deviceId: deviceId,
      syncStatus: 0,
      createTime: now,
      updateTime: now
    };
    const rowId = await store.insert(this.TABLE, valueBucket);
    const result = new CollectionType();
    result.id = rowId;
    result.name = name;
    return result;
  }

  /**
   * 删除自定义类型（不可删除内置类型）
   */
  async delete(id: number): Promise<void> {
    const type = await this.queryById(id);
    if (!type) return;
    if (type.isBuiltIn === 1) {
      throw new Error('内置类型不可删除');
    }

    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  /**
   * 更新类型排序
   */
  async updateSortOrder(id: number, sortOrder: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    const valueBucket: relationalStore.ValuesBucket = {
      sortOrder: sortOrder,
      syncStatus: 0,
      updateTime: DateUtil.getNow()
    };
    await store.update(valueBucket, predicates);
  }

  // ==================== 同步相关 ====================

  async queryChangedSince(sinceTime: number): Promise<CollectionType[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.greaterThan('updateTime', sinceTime);
    predicates.orderByAsc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

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

  private async queryById(id: number): Promise<CollectionType | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    const result = await store.query(predicates);
    const list = this.parseResult(result);
    result.close();
    return list.length > 0 ? list[0] : null;
  }

  private parseResult(result: relationalStore.ResultSet): CollectionType[] {
    const list: CollectionType[] = [];
    while (result.goToNextRow()) {
      const t = new CollectionType();
      t.id = result.getLong(result.getColumnIndex('id'));
      t.name = result.getString(result.getColumnIndex('name'));
      t.label = result.getString(result.getColumnIndex('label'));
      t.isBuiltIn = result.getLong(result.getColumnIndex('isBuiltIn'));
      t.sortOrder = result.getLong(result.getColumnIndex('sortOrder'));
      t.deviceId = result.getString(result.getColumnIndex('deviceId'));
      t.syncStatus = result.getLong(result.getColumnIndex('syncStatus'));
      t.createTime = result.getLong(result.getColumnIndex('createTime'));
      t.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(t);
    }
    result.close();
    return list;
  }
}
