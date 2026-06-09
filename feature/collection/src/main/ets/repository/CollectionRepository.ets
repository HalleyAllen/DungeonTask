/**
 * 收藏数据操作类
 * 统一管理句子/词语/台词/知识点等碎片收藏，支持多端同步
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Collection } from 'core.model';
import { DateUtil } from 'core.util';

export class CollectionRepository {
  private readonly TABLE = 'collection';

  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询所有收藏（按 updateTime 倒序）
   */
  async queryAll(): Promise<Collection[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.orderByDesc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 按类型筛选
   */
  async queryByType(type: string): Promise<Collection[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('type', type);
    predicates.orderByDesc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 按标签筛选
   */
  async queryByTag(tag: string): Promise<Collection[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.like('tag', `%${tag}%`);
    predicates.orderByDesc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 关键词搜索（标题+内容）
   */
  async search(keyword: string): Promise<Collection[]> {
    const all = await this.queryAll();
    const kw = keyword.toLowerCase();
    return all.filter(c =>
      c.title.toLowerCase().includes(kw) ||
      c.content.toLowerCase().includes(kw) ||
      c.tag.toLowerCase().includes(kw)
    );
  }

  /**
   * 按ID查询
   */
  async queryById(id: number): Promise<Collection | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);

    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 插入收藏
   */
  async insert(collection: Collection): Promise<number> {
    const store = this.getStore();
    const now = DateUtil.getNow();
    const valueBucket: relationalStore.ValuesBucket = {
      type: collection.type,
      title: collection.title,
      content: collection.content || '',
      extra: collection.extra || '',
      tag: collection.tag || '',
      deviceId: collection.deviceId || '',
      syncStatus: 0,
      createTime: collection.createTime || now,
      updateTime: now
    };
    return await store.insert(this.TABLE, valueBucket);
  }

  /**
   * 更新收藏
   */
  async update(collection: Collection): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', collection.id);

    const valueBucket: relationalStore.ValuesBucket = {
      type: collection.type,
      title: collection.title,
      content: collection.content,
      extra: collection.extra,
      tag: collection.tag,
      deviceId: collection.deviceId,
      syncStatus: 0,
      updateTime: DateUtil.getNow()
    };

    await store.update(valueBucket, predicates);
  }

  /**
   * 删除收藏
   */
  async delete(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  /**
   * 获取所有标签（去重）
   */
  async queryTags(): Promise<string[]> {
    const all = await this.queryAll();
    const tags = new Set<string>();
    for (const c of all) {
      if (c.tag) {
        c.tag.split(',').forEach(t => {
          const trimmed = t.trim();
          if (trimmed) tags.add(trimmed);
        });
      }
    }
    return Array.from(tags).sort();
  }

  /**
   * 重命名标签：更新所有包含 oldTag 的收藏
   */
  async renameTag(oldTag: string, newTag: string): Promise<void> {
    const all = await this.queryAll();
    const store = this.getStore();
    const now = DateUtil.getNow();
    for (const c of all) {
      if (!c.tag) continue;
      const tags = c.tag.split(',').map(s => s.trim());
      const idx = tags.indexOf(oldTag);
      if (idx >= 0) {
        tags[idx] = newTag;
        const predicates = new relationalStore.RdbPredicates(this.TABLE);
        predicates.equalTo('id', c.id);
        const vb: relationalStore.ValuesBucket = {
          tag: tags.join(','),
          syncStatus: 0,
          updateTime: now
        };
        await store.update(vb, predicates);
      }
    }
  }

  /**
   * 删除标签：从所有收藏中移除该标签
   */
  async deleteTag(tag: string): Promise<void> {
    const all = await this.queryAll();
    const store = this.getStore();
    const now = DateUtil.getNow();
    for (const c of all) {
      if (!c.tag) continue;
      const tags = c.tag.split(',').map(s => s.trim());
      const idx = tags.indexOf(tag);
      if (idx >= 0) {
        tags.splice(idx, 1);
        const predicates = new relationalStore.RdbPredicates(this.TABLE);
        predicates.equalTo('id', c.id);
        const vb: relationalStore.ValuesBucket = {
          tag: tags.join(','),
          syncStatus: 0,
          updateTime: now
        };
        await store.update(vb, predicates);
      }
    }
  }

  // ==================== 同步相关 ====================

  async queryChangedSince(sinceTime: number): Promise<Collection[]> {
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

  private parseResult(result: relationalStore.ResultSet): Collection[] {
    const list: Collection[] = [];
    while (result.goToNextRow()) {
      const c = new Collection();
      c.id = result.getLong(result.getColumnIndex('id'));
      c.type = result.getString(result.getColumnIndex('type'));
      c.title = result.getString(result.getColumnIndex('title'));
      c.content = result.getString(result.getColumnIndex('content'));
      c.extra = result.getString(result.getColumnIndex('extra'));
      c.tag = result.getString(result.getColumnIndex('tag'));
      c.deviceId = result.getString(result.getColumnIndex('deviceId'));
      c.syncStatus = result.getLong(result.getColumnIndex('syncStatus'));
      c.createTime = result.getLong(result.getColumnIndex('createTime'));
      c.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(c);
    }
    result.close();
    return list;
  }
}
