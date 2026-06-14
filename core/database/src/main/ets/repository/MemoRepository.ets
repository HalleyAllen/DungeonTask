import { Memo } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';
import { Logger } from 'common.util';

const TAG = 'MemoRepo';

export class MemoRepository {
  async findAll(): Promise<Memo[]> {
    try {
      const orm = getORM();
      const result = await orm.query(Memo).find();
      return result as Memo[];
    } catch (e) {
      Logger.error(TAG, 'findAll failed', e);
      return [];
    }
  }

  async findById(id: number): Promise<Memo | null> {
    try {
      const orm = getORM();
      const result = await orm.query(Memo)
        .where({ id })
        .first();
      return result as Memo | null;
    } catch (e) {
      Logger.error(TAG, `findById failed: id=${id}`, e);
      return null;
    }
  }

  async insert(memo: Memo): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(memo);
      Logger.debug(TAG, `insert: id=${memo.id}`);
      return result as number;
    } catch (e) {
      Logger.error(TAG, 'insert failed', e);
      return 0;
    }
  }

  async update(memo: Memo): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(memo);
      return result as number;
    } catch (e) {
      Logger.error(TAG, `update failed: id=${memo.id}`, e);
      return 0;
    }
  }

  async search(keyword: string): Promise<Memo[]> {
    try {
      const all = await this.findAll();
      return all.filter((m: Memo) => m.content && m.content.includes(keyword));
    } catch (e) {
      Logger.error(TAG, `search failed: "${keyword}"`, e);
      return [];
    }
  }

  async deleteById(id: number): Promise<number> {
    try {
      const orm = getORM();
      const existing = await orm.query(Memo)
        .where({ id })
        .first();
      if (existing) {
        const result = await orm.delete(existing);
        return result as number;
      }
      return 0;
    } catch (e) {
      Logger.error(TAG, `deleteById failed: id=${id}`, e);
      return 0;
    }
  }
}

export default new MemoRepository();
