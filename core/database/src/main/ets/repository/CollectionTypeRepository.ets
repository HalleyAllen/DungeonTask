import { CollectionType } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';
import { Logger } from 'common.util';

const TAG = 'CollectionTypeRepo';

export class CollectionTypeRepository {
  async findAll(): Promise<CollectionType[]> {
    try {
      const orm = getORM();
      const result = await orm.query(CollectionType).find();
      return result as CollectionType[];
    } catch (e) {
      Logger.error(TAG, 'findAll failed', e);
      return [];
    }
  }

  async findById(id: number): Promise<CollectionType | null> {
    try {
      const orm = getORM();
      const result = await orm.query(CollectionType)
        .where({ id })
        .first();
      return result as CollectionType | null;
    } catch (e) {
      Logger.error(TAG, `findById failed: id=${id}`, e);
      return null;
    }
  }

  async insert(type: CollectionType): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(type);
      Logger.debug(TAG, `insert: id=${type.id}`);
      return result as number;
    } catch (e) {
      Logger.error(TAG, 'insert failed', e);
      return 0;
    }
  }

  async update(type: CollectionType): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(type);
      return result as number;
    } catch (e) {
      Logger.error(TAG, `update failed: id=${type.id}`, e);
      return 0;
    }
  }

  async createCustom(label: string): Promise<CollectionType> {
    try {
      const orm = getORM();
      const type = new CollectionType();
      type.name = label;
      type.label = label;
      type.isBuiltIn = 0;
      await orm.insert(type);
      Logger.info(TAG, `createCustom: id=${type.id}, label="${label}"`);
      return type;
    } catch (e) {
      Logger.error(TAG, `createCustom failed: "${label}"`, e);
      throw e as Error;
    }
  }

  async deleteById(id: number): Promise<number> {
    try {
      const orm = getORM();
      const existing = await orm.query(CollectionType)
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

export default new CollectionTypeRepository();
