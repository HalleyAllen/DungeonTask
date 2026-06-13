import { Collection } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';

export class CollectionRepository {
  async findAll(): Promise<Collection[]> {
    try {
      const orm = getORM();
      const result = await orm.query(Collection).find();
      return result as Collection[];
    } catch (e) {
      console.error('CollectionRepository.findAll failed:', e);
      return [];
    }
  }

  async findByType(typeName: string): Promise<Collection[]> {
    try {
      const orm = getORM();
      const result = await orm.query(Collection)
        .where({ type: typeName })
        .find();
      return result as Collection[];
    } catch (e) {
      console.error('CollectionRepository.findByType failed:', e);
      return [];
    }
  }

  async queryTags(): Promise<string[]> {
    try {
      const all = await this.findAll();
      const tagSet = new Set<string>();
      for (const c of all) {
        if (c.tag) {
          c.tag.split(',').map((s: string) => s.trim()).filter((s: string) => s.length > 0).forEach((tag: string) => tagSet.add(tag));
        }
      }
      return Array.from(tagSet);
    } catch (e) {
      console.error('CollectionRepository.queryTags failed:', e);
      return [];
    }
  }

  async findById(id: number): Promise<Collection | null> {
    try {
      const orm = getORM();
      const result = await orm.query(Collection)
        .where({ id })
        .first();
      return result as Collection | null;
    } catch (e) {
      console.error('CollectionRepository.findById failed:', e);
      return null;
    }
  }

  async insert(collection: Collection): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(collection);
      return result as number;
    } catch (e) {
      console.error('CollectionRepository.insert failed:', e);
      return 0;
    }
  }

  async update(collection: Collection): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(collection);
      return result as number;
    } catch (e) {
      console.error('CollectionRepository.update failed:', e);
      return 0;
    }
  }

  async deleteById(id: number): Promise<number> {
    try {
      const orm = getORM();
      const existing = await orm.query(Collection)
        .where({ id })
        .first();
      if (existing) {
        const result = await orm.delete(existing);
        return result as number;
      }
      return 0;
    } catch (e) {
      console.error('CollectionRepository.deleteById failed:', e);
      return 0;
    }
  }

  /** 重命名标签 */
  async renameTag(oldName: string, newName: string): Promise<void> {
    try {
      const orm = getORM();
      const all = await orm.query(Collection).find() as Collection[];
      for (const item of all) {
        if (!item.tag) {
          continue;
        }
        const tags = item.tag.split(',').map((s: string) => s.trim());
        const idx = tags.indexOf(oldName);
        if (idx !== -1) {
          tags[idx] = newName;
          item.tag = tags.join(',');
          await orm.save(item);
        }
      }
    } catch (e) {
      console.error('CollectionRepository.renameTag failed:', e);
    }
  }

  /** 删除标签（从所有收藏中移除） */
  async deleteTag(tagName: string): Promise<void> {
    try {
      const orm = getORM();
      const all = await orm.query(Collection).find() as Collection[];
      for (const item of all) {
        if (!item.tag) {
          continue;
        }
        const tags = item.tag.split(',').map((s: string) => s.trim()).filter((s: string) => s !== tagName);
        if (tags.join(',') !== item.tag) {
          item.tag = tags.join(',');
          await orm.save(item);
        }
      }
    } catch (e) {
      console.error('CollectionRepository.deleteTag failed:', e);
    }
  }
}

export default new CollectionRepository();
