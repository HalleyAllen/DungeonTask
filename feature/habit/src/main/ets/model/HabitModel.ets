/**
 * 习惯模板数据操作类
 * 支持多端同步（deviceId/syncStatus）
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Habit } from 'core.model';
import { DateUtil } from 'core.util';

export class HabitModel {
  private readonly TABLE = 'habit';

  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询所有习惯（按 category + sortOrder 排序）
   */
  async queryAll(): Promise<Habit[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.orderByAsc('category');
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 按分类查询
   */
  async queryByCategory(category: string): Promise<Habit[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('category', category);
    predicates.orderByAsc('sortOrder');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询当天应做的习惯
   */
  async queryTodayHabits(): Promise<Habit[]> {
    const all = await this.queryAll();
    const todayWeekDay = DateUtil.getTodayWeekDay();
    return all.filter(h => {
      if (h.frequency === 1) return true; // 每天
      if (h.frequency === 2) {
        const days = h.weekDays.split(',').map(Number);
        return days.includes(todayWeekDay);
      }
      return false;
    });
  }

  /**
   * 按ID查询
   */
  async queryById(id: number): Promise<Habit | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);

    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 获取所有分类（去重）
   */
  async queryCategories(): Promise<string[]> {
    const all = await this.queryAll();
    return [...new Set(all.map(h => h.category))];
  }

  /**
   * 插入习惯
   */
  async insert(habit: Habit): Promise<number> {
    const store = this.getStore();
    const now = DateUtil.getNow();
    const valueBucket: relationalStore.ValuesBucket = {
      name: habit.name,
      category: habit.category || '其他',
      frequency: habit.frequency || 1,
      weekDays: habit.weekDays || '',
      targetSets: habit.targetSets || 0,
      targetReps: habit.targetReps || 0,
      targetDuration: habit.targetDuration || 0,
      icon: habit.icon || '',
      color: habit.color || '',
      sortOrder: habit.sortOrder || 0,
      deviceId: habit.deviceId || '',
      syncStatus: 0,
      createTime: habit.createTime || now,
      updateTime: now
    };
    return await store.insert(this.TABLE, valueBucket);
  }

  /**
   * 更新习惯
   */
  async update(habit: Habit): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', habit.id);

    const valueBucket: relationalStore.ValuesBucket = {
      name: habit.name,
      category: habit.category,
      frequency: habit.frequency,
      weekDays: habit.weekDays,
      targetSets: habit.targetSets,
      targetReps: habit.targetReps,
      targetDuration: habit.targetDuration,
      icon: habit.icon,
      color: habit.color,
      sortOrder: habit.sortOrder,
      deviceId: habit.deviceId,
      syncStatus: 0,
      updateTime: DateUtil.getNow()
    };

    await store.update(this.TABLE, valueBucket, predicates);
  }

  /**
   * 删除习惯
   */
  async delete(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    await store.delete(this.TABLE, predicates);
  }

  // ==================== 同步相关 ====================

  /**
   * 查询变更记录（增量同步）
   */
  async queryChangedSince(sinceTime: number): Promise<Habit[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.greaterThan('updateTime', sinceTime);
    predicates.orderByAsc('updateTime');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 标记已同步
   */
  async markSynced(ids: number[]): Promise<void> {
    const store = this.getStore();
    for (const id of ids) {
      const predicates = new relationalStore.RdbPredicates(this.TABLE);
      predicates.equalTo('id', id);
      const valueBucket: relationalStore.ValuesBucket = {
        syncStatus: 1,
        updateTime: DateUtil.getNow()
      };
      await store.update(this.TABLE, valueBucket, predicates);
    }
  }

  private parseResult(result: relationalStore.ResultSet): Habit[] {
    const list: Habit[] = [];
    while (result.goToNextRow()) {
      const h = new Habit();
      h.id = result.getLong(result.getColumnIndex('id'));
      h.name = result.getString(result.getColumnIndex('name'));
      h.category = result.getString(result.getColumnIndex('category'));
      h.frequency = result.getLong(result.getColumnIndex('frequency'));
      h.weekDays = result.getString(result.getColumnIndex('weekDays'));
      h.targetSets = result.getLong(result.getColumnIndex('targetSets'));
      h.targetReps = result.getLong(result.getColumnIndex('targetReps'));
      h.targetDuration = result.getLong(result.getColumnIndex('targetDuration'));
      h.icon = result.getString(result.getColumnIndex('icon'));
      h.color = result.getString(result.getColumnIndex('color'));
      h.sortOrder = result.getLong(result.getColumnIndex('sortOrder'));
      h.deviceId = result.getString(result.getColumnIndex('deviceId'));
      h.syncStatus = result.getLong(result.getColumnIndex('syncStatus'));
      h.createTime = result.getLong(result.getColumnIndex('createTime'));
      h.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(h);
    }
    result.close();
    return list;
  }
}
