import { CollectionType } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';

export class CollectionTypeRepository {
  async findAll(): Promise<CollectionType[]> {
    try {
      const orm = getORM();
      const result = await orm.query(CollectionType).find();
      return result as CollectionType[];
    } catch (e) {
      console.error('CollectionTypeRepository.findAll failed:', e);
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
      console.error('CollectionTypeRepository.findById failed:', e);
      return null;
    }
  }

  async insert(type: CollectionType): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(type);
      return result as number;
    } catch (e) {
      console.error('CollectionTypeRepository.insert failed:', e);
      return 0;
    }
  }

  async update(type: CollectionType): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(type);
      return result as number;
    } catch (e) {
      console.error('CollectionTypeRepository.update failed:', e);
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
      return type;
    } catch (e) {
      console.error('CollectionTypeRepository.createCustom failed:', e);
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
      console.error('CollectionTypeRepository.deleteById failed:', e);
      return 0;
    }
  }
}

export default new CollectionTypeRepository();
