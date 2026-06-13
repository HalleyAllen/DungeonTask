/**
 * 任务数据操作类（基于 ibest-orm）
 */
import { getORM } from '@ibestservices/ibest-orm';
import { Task, SortOrderItem } from 'core.model';
import { DateUtil } from 'common.util';

export class TaskRepository {
  private get orm() {
    return getORM();
  }

  /** 按日期查询（priority 降序，sortOrder 升序） */
  async queryByDate(date: string): Promise<Task[]> {
    const all = await this.orm.query(Task).where({ date: date }).find() as Task[];
    return all.sort((a: Task, b: Task) => {
      if (b.priority !== a.priority) return b.priority - a.priority;
      return a.sortOrder - b.sortOrder;
    });
  }

  /** 按日期范围查询 */
  async queryByDateRange(startDate: string, endDate: string): Promise<Task[]> {
    const all = await this.queryAll();
    return all
      .filter(t => t.date >= startDate && t.date <= endDate)
      .sort((a, b) => b.priority - a.priority || a.sortOrder - b.sortOrder);
  }

  /** 查指定日期的顶级任务 */
  async queryTopLevel(date: string): Promise<Task[]> {
    const all = await this.queryByDate(date);
    return all.filter(t => t.parentId === 0);
  }

  /** 按 parentId 查子任务 */
  async queryByParentId(parentId: number): Promise<Task[]> {
    const all = await this.orm.query(Task).where({ parentId: parentId }).find() as Task[];
    return all.sort((a: Task, b: Task) => a.sortOrder - b.sortOrder);
  }

  /** 查询所有任务 */
  async queryAll(): Promise<Task[]> {
    return await this.orm.query(Task)
      .orderBy('priority', 'desc')
      .orderBy('createTime', 'desc')
      .find() as Task[];
  }

  /** 获取所有不重复标签 */
  async queryTags(): Promise<string[]> {
    const all = await this.queryAll();
    const tagSet = new Set<string>();
    for (const t of all) {
      if (t.tag) {
        t.tag.split(',').map(s => s.trim()).filter(s => s).forEach(tag => tagSet.add(tag));
      }
    }
    return Array.from(tagSet);
  }

  /** 按标签筛选 */
  async queryByTag(tag: string): Promise<Task[]> {
    const all = await this.queryAll();
    return all.filter(t => t.tag && t.tag.includes(tag));
  }

  /** 重命名标签 */
  async renameTag(oldTag: string, newTag: string): Promise<void> {
    const all = await this.queryAll();
    const now = DateUtil.getNow();
    for (const t of all) {
      if (!t.tag) continue;
      const tags = t.tag.split(',').map(s => s.trim());
      const idx = tags.indexOf(oldTag);
      if (idx >= 0) {
        tags[idx] = newTag;
        t.tag = tags.join(',');
        t.syncStatus = 0;
        t.updateTime = now;
        await this.orm.save(t);
      }
    }
  }

  /** 删除标签 */
  async deleteTag(tag: string): Promise<void> {
    const all = await this.queryAll();
    const now = DateUtil.getNow();
    for (const t of all) {
      if (!t.tag) continue;
      const tags = t.tag.split(',').map(s => s.trim());
      const idx = tags.indexOf(tag);
      if (idx >= 0) {
        tags.splice(idx, 1);
        t.tag = tags.join(',');
        t.syncStatus = 0;
        t.updateTime = now;
        await this.orm.save(t);
      }
    }
  }

  /** 按ID查询 */
  async queryById(id: number): Promise<Task | null> {
    const results = await this.orm.query(Task).where({ id: id }).find() as Task[];
    return results.length > 0 ? results[0] as Task : null;
  }

  /** 插入任务 */
  async insert(task: Task): Promise<number> {
    const now = DateUtil.getNow();
    if (!task.date) task.date = DateUtil.getToday();
    if (!task.createTime) task.createTime = now;
    task.updateTime = now;
    task.syncStatus = 0;
    await this.orm.insert(task);
    return task.id;
  }

  /** 插入子任务 */
  async insertChild(parentId: number, title: string, deviceId: string = ''): Promise<number> {
    const parent = await this.queryById(parentId);
    if (!parent) throw new Error('父任务不存在');
    if (parent.level >= 4) throw new Error('已达到最大层级（5层）');

    const children = await this.queryByParentId(parentId);
    const maxOrder = children.reduce((max, t) => Math.max(max, t.sortOrder), 0);

    const task = new Task();
    task.title = title;
    task.date = parent.date;
    task.parentId = parentId;
    task.level = parent.level + 1;
    task.sortOrder = maxOrder + 1;
    task.deviceId = deviceId;
    return await this.insert(task);
  }

  /** 更新任务 */
  async update(task: Task): Promise<void> {
    task.updateTime = DateUtil.getNow();
    task.syncStatus = 0;
    await this.orm.save(task);
  }

  /** 切换完成状态 */
  async toggleComplete(id: number): Promise<void> {
    const task = await this.queryById(id);
    if (!task) return;
    task.completed = task.completed === 1 ? 0 : 1;
    await this.update(task);
    if (task.parentId > 0) {
      await this.checkParentCompletion(task.parentId);
    }
  }

  /** 删除任务及所有子任务 */
  async delete(id: number): Promise<void> {
    const idsToDelete = await this.collectDescendantIds(id);
    idsToDelete.push(id);
    for (const deleteId of idsToDelete) {
      const task = await this.queryById(deleteId);
      if (task) {
        await this.orm.delete(task);
      }
    }
  }

  /** 批量更新排序 */
  async updateSortOrders(tasks: SortOrderItem[]): Promise<void> {
    const now = DateUtil.getNow();
    for (const t of tasks) {
      const existing = await this.queryById(t.id);
      if (existing) {
        existing.sortOrder = t.sortOrder;
        existing.priority = t.priority;
        existing.syncStatus = 0;
        existing.updateTime = now;
        await this.orm.save(existing);
      }
    }
  }

  // ==================== 同步相关 ====================

  async queryChangedSince(sinceTime: number): Promise<Task[]> {
    const all = await this.queryAll();
    return all.filter(t => t.updateTime > sinceTime);
  }

  async markSynced(ids: number[]): Promise<void> {
    const now = DateUtil.getNow();
    for (const id of ids) {
      const task = await this.queryById(id);
      if (task) {
        task.syncStatus = 1;
        task.updateTime = now;
        await this.orm.save(task);
      }
    }
  }

  async upsertBatch(tasks: Task[]): Promise<void> {
    for (const task of tasks) {
      const existing = await this.queryById(task.id);
      if (existing) {
        if (task.updateTime > existing.updateTime) {
          task.syncStatus = 1;
          await this.orm.save(task);
        }
      } else {
        task.syncStatus = 1;
        await this.insert(task);
      }
    }
  }

  // ==================== 私有方法 ====================

  private async checkParentCompletion(parentId: number): Promise<void> {
    const children = await this.queryByParentId(parentId);
    const allCompleted = children.length > 0 && children.every(c => c.completed === 1);
    const parent = await this.queryById(parentId);
    if (parent) {
      parent.completed = allCompleted ? 1 : 0;
      parent.syncStatus = 0;
      parent.updateTime = DateUtil.getNow();
      await this.orm.save(parent);
    }
  }

  private async collectDescendantIds(parentId: number): Promise<number[]> {
    const ids: number[] = [];
    const children = await this.queryByParentId(parentId);
    for (const child of children) {
      ids.push(child.id);
      const grandIds = await this.collectDescendantIds(child.id);
      ids.push(...grandIds);
    }
    return ids;
  }
}
