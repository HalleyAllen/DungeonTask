/**
 * 标签数据操作类
 */
import { getORM } from '@ibestservices/ibest-orm';
import { Tag } from 'core.model';
import { DateUtil, Logger } from 'common.util';

const TAG = 'TagRepo';

export class TagRepository {
  private get orm() {
    return getORM();
  }

  /** 查询所有标签 */
  async queryAll(): Promise<Tag[]> {
    try {
      return await this.orm.query(Tag)
        .orderBy('createTime', 'asc')
        .find() as Tag[];
    } catch (e) {
      Logger.error(TAG, 'queryAll failed', e);
      return [];
    }
  }

  /** 按名称查询 */
  async queryByName(name: string): Promise<Tag | null> {
    try {
      const results = await this.orm.query(Tag).where({ name: name }).find() as Tag[];
      return results.length > 0 ? results[0] as Tag : null;
    } catch (e) {
      Logger.error(TAG, `queryByName failed: "${name}"`, e);
      return null;
    }
  }

  /** 新增标签 */
  async add(name: string): Promise<number> {
    try {
      const existing = await this.queryByName(name);
      if (existing) {
        Logger.debug(TAG, `add: tag "${name}" already exists, id=${existing.id}`);
        return existing.id;
      }

      const tag = new Tag();
      tag.name = name;
      tag.createTime = DateUtil.getNow();
      await this.orm.insert(tag);
      Logger.info(TAG, `add: id=${tag.id}, name="${name}"`);
      return tag.id;
    } catch (e) {
      Logger.error(TAG, `add failed: "${name}"`, e);
      return 0;
    }
  }

  /** 重命名标签 */
  async rename(oldName: string, newName: string): Promise<void> {
    try {
      const tag = await this.queryByName(oldName);
      if (!tag) {
        Logger.warn(TAG, `rename: tag "${oldName}" not found`);
        return;
      }

      const conflict = await this.queryByName(newName);
      if (conflict && conflict.id !== tag.id) {
        Logger.warn(TAG, `rename: target "${newName}" already exists`);
        throw new Error('标签已存在');
      }

      tag.name = newName;
      await this.orm.save(tag);
      Logger.info(TAG, `rename: "${oldName}" -> "${newName}"`);
    } catch (e) {
      Logger.error(TAG, `rename failed: "${oldName}" -> "${newName}"`, e);
    }
  }

  /** 删除标签 */
  async delete(name: string): Promise<void> {
    try {
      const tag = await this.queryByName(name);
      if (tag) {
        await this.orm.delete(tag);
        Logger.info(TAG, `delete: "${name}"`);
      }
    } catch (e) {
      Logger.error(TAG, `delete failed: "${name}"`, e);
    }
  }

  /** 获取所有标签名称 */
  async queryAllNames(): Promise<string[]> {
    try {
      const tags = await this.queryAll();
      return tags.map(t => t.name);
    } catch (e) {
      Logger.error(TAG, 'queryAllNames failed', e);
      return [];
    }
  }

  /** 获取在顶栏可见的标签名称（showInTopBar=1） */
  async queryVisibleNames(): Promise<string[]> {
    try {
      const tags = await this.queryAll();
      return tags.filter(t => t.showInTopBar !== 0).map(t => t.name);
    } catch (e) {
      Logger.error(TAG, 'queryVisibleNames failed', e);
      return [];
    }
  }

  /** 设置标签是否在顶栏显示 */
  async setShowInTopBar(name: string, show: boolean): Promise<void> {
    try {
      const tag = await this.queryByName(name);
      if (tag) {
        tag.showInTopBar = show ? 1 : 0;
        await this.orm.save(tag);
        Logger.debug(TAG, `setShowInTopBar: "${name}" -> ${show}`);
      }
    } catch (e) {
      Logger.error(TAG, `setShowInTopBar failed: "${name}"`, e);
    }
  }
}
