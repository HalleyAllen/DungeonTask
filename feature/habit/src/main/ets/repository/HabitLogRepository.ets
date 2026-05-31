/**
 * 习惯打卡数据操作类
 * 支持多端同步（deviceId/syncStatus）
 */
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { HabitLog } from 'core.model';
import { DateUtil } from 'core.util';

export class HabitLogRepository {
  private readonly TABLE = 'habit_log';

  private getStore() {
    return DbHelper.getInstance().getRdbStore();
  }

  /**
   * 查询指定习惯的打卡记录
   */
  async queryByHabitId(habitId: number): Promise<HabitLog[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('habitId', habitId);
    predicates.orderByDesc('date');

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询指定日期某习惯的打卡记录
   */
  async queryByDate(habitId: number, date: string): Promise<HabitLog | null> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('habitId', habitId);
    predicates.equalTo('date', date);

    const result = await store.query(predicates);
    const list = this.parseResult(result);
    return list.length > 0 ? list[0] : null;
  }

  /**
   * 查询指定日期的所有打卡
   */
  async queryByDateAll(date: string): Promise<HabitLog[]> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('date', date);

    const result = await store.query(predicates);
    return this.parseResult(result);
  }

  /**
   * 查询一个月内的打卡统计（日期 -> 完成数）
   */
  async queryMonthStats(startDate: string, endDate: string): Promise<Map<string, number>> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.greaterThanOrEqualTo('date', startDate);
    predicates.lessThanOrEqualTo('date', endDate);
    predicates.equalTo('completed', 1);

    const result = await store.query(predicates);
    const map = new Map<string, number>();
    while (result.goToNextRow()) {
      const date = result.getString(result.getColumnIndex('date'));
      map.set(date, (map.get(date) || 0) + 1);
    }
    result.close();
    return map;
  }

  /**
   * 打卡（当天已有则更新，没有则新增）
   */
  async checkin(
    habitId: number,
    completed: boolean,
    actualSets: number = 0,
    actualReps: number = 0,
    actualDuration: number = 0,
    note: string = '',
    deviceId: string = ''
  ): Promise<void> {
    const today = DateUtil.getToday();
    const existing = await this.queryByDate(habitId, today);

    if (existing) {
      const store = this.getStore();
      const predicates = new relationalStore.RdbPredicates(this.TABLE);
      predicates.equalTo('id', existing.id);
      const valueBucket: relationalStore.ValuesBucket = {
        completed: completed ? 1 : 0,
        actualSets: actualSets,
        actualReps: actualReps,
        actualDuration: actualDuration,
        note: note,
        syncStatus: 0,
        updateTime: DateUtil.getNow()
      };
      await store.update(valueBucket, predicates);
    } else {
      const store = this.getStore();
      const now = DateUtil.getNow();
      const valueBucket: relationalStore.ValuesBucket = {
        habitId: habitId,
        date: today,
        completed: completed ? 1 : 0,
        actualSets: actualSets,
        actualReps: actualReps,
        actualDuration: actualDuration,
        note: note,
        deviceId: deviceId,
        syncStatus: 0,
        createTime: now,
        updateTime: now
      };
      await store.insert(this.TABLE, valueBucket);
    }
  }

  /**
   * 查询某习惯的连续打卡天数
   */
  async queryStreak(habitId: number): Promise<number> {
    const logs = await this.queryByHabitId(habitId);
    let streak = 0;
    const today = DateUtil.getToday();
    const todayDate = new Date(today);

    for (let i = 0; i < logs.length; i++) {
      const expected = new Date(todayDate);
      expected.setDate(todayDate.getDate() - i);
      const expectedStr = DateUtil.formatDate(expected);
      const hasLog = logs.some(l => l.date === expectedStr && l.completed === 1);
      if (hasLog) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /**
   * 删除打卡记录
   */
  async delete(id: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('id', id);
    await store.delete(predicates);
  }

  /**
   * 删除某习惯的所有打卡
   */
  async deleteByHabitId(habitId: number): Promise<void> {
    const store = this.getStore();
    const predicates = new relationalStore.RdbPredicates(this.TABLE);
    predicates.equalTo('habitId', habitId);
    await store.delete(predicates);
  }

  // ==================== 同步相关 ====================

  async queryChangedSince(sinceTime: number): Promise<HabitLog[]> {
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

  private parseResult(result: relationalStore.ResultSet): HabitLog[] {
    const list: HabitLog[] = [];
    while (result.goToNextRow()) {
      const log = new HabitLog();
      log.id = result.getLong(result.getColumnIndex('id'));
      log.habitId = result.getLong(result.getColumnIndex('habitId'));
      log.date = result.getString(result.getColumnIndex('date'));
      log.completed = result.getLong(result.getColumnIndex('completed'));
      log.actualSets = result.getLong(result.getColumnIndex('actualSets'));
      log.actualReps = result.getLong(result.getColumnIndex('actualReps'));
      log.actualDuration = result.getLong(result.getColumnIndex('actualDuration'));
      log.note = result.getString(result.getColumnIndex('note'));
      log.deviceId = result.getString(result.getColumnIndex('deviceId'));
      log.syncStatus = result.getLong(result.getColumnIndex('syncStatus'));
      log.createTime = result.getLong(result.getColumnIndex('createTime'));
      log.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(log);
    }
    result.close();
    return list;
  }
}
