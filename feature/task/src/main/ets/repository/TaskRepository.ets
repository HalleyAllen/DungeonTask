/**
 * 任务数据操作类
 * 支持层级拆分（parentId/level/sortOrder）和多端同步（deviceId/syncStatus）
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Task, SortOrderItem } from 'core.model';
import { DateUtil } from 'core.util';

export class TaskRepository {
  private readonly TABLE = 'task';

  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询指定日期的任务（按优先级降序，同级按 sortOrder 升序）
   */
  async queryByDate(date: string): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('date', date);
    predicates.orderByDesc('priority');
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询日期范围内的任务
   */
  async queryByDateRange(startDate: string, endDate: string): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.greaterThanOrEqualTo('date', startDate);
    predicates.lessThanOrEqualTo('date', endDate);
    predicates.orderByDesc('priority');
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询顶级任务（parentId=0）指定日期
   */
  async queryTopLevel(date: string): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('date', date);
    predicates.equalTo('parentId', 0);
    predicates.orderByDesc('priority');
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询子任务（按 parentId）
   */
  async queryByParentId(parentId: number): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('parentId', parentId);
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询所有任务
   */
  async queryAll(): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.orderByDesc('priority');
    predicates.orderByDesc('createTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询所有不重复标签
   */
  async queryTags(): Promise<string[]> {
    const all = await this.queryAll();
    const tagSet = new Set<string>();
    for (const t of all) {
      if (t.tag) {
        const tags = t.tag.split(',').map(s => s.trim()).filter(s => s);
        for (const tag of tags) {
          tagSet.add(tag);
        }
      }
    }
    const result: string[] = [];
    tagSet.forEach(tag => result.push(tag));
    return result;
  }

  /**
   * 按标签筛选任务（模糊匹配 tag 字段）
   */
  async queryByTag(tag: string): Promise<Task[]> {
    const all = await this.queryAll();
    return all.filter(t => t.tag.includes(tag));
  }

  /**
   * 重命名标签：更新所有包含 oldTag 的任务
   */
  async renameTag(oldTag: string, newTag: string): Promise<void> {
    const all = await this.queryAll();
    const store = this.getStore();
    const now = DateUtil.getNow();
    for (const t of all) {
      if (!t.tag) continue;
      const tags = t.tag.split(',').map(s => s.trim());
      const idx = tags.indexOf(oldTag);
      if (idx >= 0) {
        tags[idx] = newTag;
        const newTagStr = tags.join(',');
        const predicates = new relationalStore.RdbPredicates(this.TABLE);
        predicates.equalTo('id', t.id);
        const vb: relationalStore.ValuesBucket = {
          tag: newTagStr,
          syncStatus: 0,
          updateTime: now
        };
        await store.update(vb, predicates);
      }
    }
  }

  /**
   * 删除标签：从所有任务中移除该标签
   */
  async deleteTag(tag: string): Promise<void> {
    const all = await this.queryAll();
    const store = this.getStore();
    const now = DateUtil.getNow();
    for (const t of all) {
      if (!t.tag) continue;
      const tags = t.tag.split(',').map(s => s.trim());
      const idx = tags.indexOf(tag);
      if (idx >= 0) {
        tags.splice(idx, 1);
        const newTagStr = tags.join(',');
        const predicates = new relationalStore.RdbPredicates(this.TABLE);
        predicates.equalTo('id', t.id);
        const vb: relationalStore.ValuesBucket = {
          tag: newTagStr,
          syncStatus: 0,
          updateTime: now
        };
        await store.update(vb, predicates);
      }
    }
  }

  /**
   * 按ID查询
   */
  async queryById(id: number): Promise<Task | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);

    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 插入任务
   */
  async insert(task: Task): Promise<number> {
    const store = this.getStore();
    const now = DateUtil.getNow();
    const valueBucket: relationalStore.ValuesBucket = {
      title: task.title,
      content: task.content || '',
      date: task.date || DateUtil.getToday(),
      completed: task.completed || 0,
      priority: task.priority || 0,
      parentId: task.parentId || 0,
      level: task.level || 0,
      sortOrder: task.sortOrder || 0,
      tag: task.tag || '',
      deviceId: task.deviceId || '',
      syncStatus: 0,
      createTime: task.createTime || now,
      updateTime: now
    };
    return await store.insert(this.TABLE, valueBucket);
  }

  /**
   * 插入子任务（自动计算 level 和 sortOrder）
   */
  async insertChild(parentId: number, title: string, deviceId: string = ''): Promise<number> {
    const parent = await this.queryById(parentId);
    if (!parent) {
      throw new Error('父任务不存在');
    }
    if (parent.level >= 4) {
      throw new Error('已达到最大层级（5层）');
    }

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

  /**
   * 更新任务
   */
  async update(task: Task): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', task.id);

    const valueBucket: relationalStore.ValuesBucket = {
      title: task.title,
      content: task.content,
      date: task.date,
      completed: task.completed,
      priority: task.priority,
      parentId: task.parentId,
      level: task.level,
      sortOrder: task.sortOrder,
      tag: task.tag || '',
      deviceId: task.deviceId,
      syncStatus: 0,
      updateTime: DateUtil.getNow()
    };

    await store.update(valueBucket, predicates);
  }

  /**
   * 切换完成状态
   */
  async toggleComplete(id: number): Promise<void> {
    const task = await this.queryById(id);
    if (!task) return;

    task.completed = task.completed === 1 ? 0 : 1;
    await this.update(task);

    // 父任务：检查所有子任务是否都完成
    if (task.parentId > 0) {
      await this.checkParentCompletion(task.parentId);
    }
  }

  /**
   * 删除任务及其所有子任务
   */
  async delete(id: number): Promise<void> {
    const store = this.getStore();

    // 递归查询所有子任务ID
    const idsToDelete = await this.collectDescendantIds(id);
    idsToDelete.push(id);

    for (const deleteId of idsToDelete) {
      const predicates = new relationalStore.RdbPredicates(this.TABLE);
      predicates.equalTo('id', deleteId);
      await store.delete(predicates);
    }
  }

  /**
   * 批量更新优先级（拖拽排序后持久化）
   */
  async updateSortOrders(tasks: SortOrderItem[]): Promise<void> {
    const store = this.getStore();
    const now = DateUtil.getNow();
    for (const t of tasks) {
      const predicates = new relationalStore.RdbPredicates(this.TABLE);
      predicates.equalTo('id', t.id);
      const valueBucket: relationalStore.ValuesBucket = {
        sortOrder: t.sortOrder,
        priority: t.priority,
        syncStatus: 0,
        updateTime: now
      };
      await store.update(valueBucket, predicates);
    }
  }

  // ==================== 同步相关 ====================

  /**
   * 查询自某时间点后变更的记录（用于增量同步）
   */
  async queryChangedSince(sinceTime: number): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.greaterThan('updateTime', sinceTime);
    predicates.orderByAsc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 标记为已同步
   */
  async markSynced(ids: number[]): Promise<void> {
    const store = this.getStore();
    const now = DateUtil.getNow();
    for (const id of ids) {
      const predicates = new relationalStore.RdbPredicates(this.TABLE);
      predicates.equalTo('id', id);
      const valueBucket: relationalStore.ValuesBucket = {
        syncStatus: 1,
        updateTime: now
      };
      await store.update(valueBucket, predicates);
    }
  }

  /**
   * 批量 upsert（同步写入远端数据）
   */
  async upsertBatch(tasks: Task[]): Promise<void> {
    const store = this.getStore();
    for (const task of tasks) {
      const existing = await this.queryById(task.id);
      if (existing) {
        // 冲突解决：LWW，远端 updateTime 更新则覆盖
        if (task.updateTime > existing.updateTime) {
          const predicates = new relationalStore.RdbPredicates(this.TABLE);
          predicates.equalTo('id', task.id);
          const valueBucket: relationalStore.ValuesBucket = {
            title: task.title,
            content: task.content,
            date: task.date,
            completed: task.completed,
            priority: task.priority,
            parentId: task.parentId,
            level: task.level,
            sortOrder: task.sortOrder,
            tag: task.tag || '',
            deviceId: task.deviceId,
            syncStatus: 1,
            updateTime: task.updateTime
          };
          await store.update(valueBucket, predicates);
        }
      } else {
        task.syncStatus = 1;
        await this.insert(task);
      }
    }
  }

  // ==================== 私有方法 ====================

  /**
   * 检查父任务完成状态（所有子任务完成则自动完成）
   */
  private async checkParentCompletion(parentId: number): Promise<void> {
    const children = await this.queryByParentId(parentId);
    const allCompleted = children.length > 0 && children.every(c => c.completed === 1);
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', parentId);
    const valueBucket: relationalStore.ValuesBucket = {
      completed: allCompleted ? 1 : 0,
      syncStatus: 0,
      updateTime: DateUtil.getNow()
    };
    await store.update(valueBucket, predicates);
  }

  /**
   * 递归收集所有子孙任务ID
   */
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

  /**
   * 解析查询结果
   */
  private parseResult(result: relationalStore.ResultSet): Task[] {
    const list: Task[] = [];
    while (result.goToNextRow()) {
      const task = new Task();
      task.id = result.getLong(result.getColumnIndex('id'));
      task.title = result.getString(result.getColumnIndex('title'));
      task.content = result.getString(result.getColumnIndex('content'));
      task.date = result.getString(result.getColumnIndex('date'));
      task.completed = result.getLong(result.getColumnIndex('completed'));
      task.priority = result.getLong(result.getColumnIndex('priority'));
      task.parentId = result.getLong(result.getColumnIndex('parentId'));
      task.level = result.getLong(result.getColumnIndex('level'));
      task.sortOrder = result.getLong(result.getColumnIndex('sortOrder'));
      task.tag = result.getString(result.getColumnIndex('tag'));
      task.deviceId = result.getString(result.getColumnIndex('deviceId'));
      task.syncStatus = result.getLong(result.getColumnIndex('syncStatus'));
      task.createTime = result.getLong(result.getColumnIndex('createTime'));
      task.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(task);
    }
    result.close();
    return list;
  }
}
