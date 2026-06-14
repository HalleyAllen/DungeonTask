/**
 * 任务数据操作类
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Task } from 'core.model';
import { DateUtil } from 'core.util';

export class TaskModel {
  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询指定日期的任务
   */
  async queryByDate(date: string): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('task');
    predicates.equalTo('date', date);
    predicates.orderByDesc('priority');
    predicates.orderByDesc('createTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询所有任务
   */
  async queryAll(): Promise<Task[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('task');
    predicates.orderByDesc('priority');
    predicates.orderByDesc('createTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 按ID查询
   */
  async queryById(id: number): Promise<Task | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('task');
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
    const valueBucket: relationalStore.ValuesBucket = {
      title: task.title,
      content: task.content || '',
      date: task.date || DateUtil.getToday(),
      completed: task.completed || 0,
      priority: task.priority || 0,
      parentId: task.parentId || 0,
      level: task.level || 0,
      sortOrder: task.sortOrder || 0,
      createTime: task.createTime || DateUtil.getNow(),
      updateTime: task.updateTime || DateUtil.getNow()
    };

    const result = await store.insert('task', valueBucket);
    return result;
  }

  /**
   * 更新任务
   */
  async update(task: Task): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('task');
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
      updateTime: DateUtil.getNow()
    };

    await store.update('task', valueBucket, predicates);
  }

  /**
   * 删除任务
   */
  async delete(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates('task');
    predicates.equalTo('id', id);

    await store.delete('task', predicates);
  }

  /**
   * 批量更新优先级（拖拽排序后持久化）
   */
  async updatePriorities(tasks: Task[]): Promise<void> {
    const store = this.getStore();
    for (const task of tasks) {
      const predicates = new relationalStore.RdbPredicates('task');
      predicates.equalTo('id', task.id);
      const valueBucket: relationalStore.ValuesBucket = {
        priority: task.priority,
        updateTime: DateUtil.getNow()
      };
      await store.update('task', valueBucket, predicates);
    }
  }

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
      task.createTime = result.getLong(result.getColumnIndex('createTime'));
      task.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(task);
    }
    result.close();
    return list;
  }
}
