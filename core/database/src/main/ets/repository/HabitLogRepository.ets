import { HabitLog } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';
import { Logger } from 'common.util';

const TAG = 'HabitLogRepo';

export class HabitLogRepository {
  async findAll(): Promise<HabitLog[]> {
    try {
      const orm = getORM();
      const result = await orm.query(HabitLog).find();
      return result as HabitLog[];
    } catch (e) {
      Logger.error(TAG, 'findAll failed', e);
      return [];
    }
  }

  async findByHabitId(habitId: number): Promise<HabitLog[]> {
    try {
      const orm = getORM();
      const result = await orm.query(HabitLog)
        .where({ habitId })
        .find();
      return result as HabitLog[];
    } catch (e) {
      Logger.error(TAG, `findByHabitId failed: habitId=${habitId}`, e);
      return [];
    }
  }

  async findById(id: number): Promise<HabitLog | null> {
    try {
      const orm = getORM();
      const result = await orm.query(HabitLog)
        .where({ id })
        .first();
      return result as HabitLog | null;
    } catch (e) {
      Logger.error(TAG, `findById failed: id=${id}`, e);
      return null;
    }
  }

  async insert(log: HabitLog): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(log);
      Logger.debug(TAG, `insert: id=${log.id}, habitId=${log.habitId}`);
      return result as number;
    } catch (e) {
      Logger.error(TAG, 'insert failed', e);
      return 0;
    }
  }

  async update(log: HabitLog): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(log);
      return result as number;
    } catch (e) {
      Logger.error(TAG, `update failed: id=${log.id}`, e);
      return 0;
    }
  }

  async findByDate(habitId: number, date: string): Promise<HabitLog | null> {
    try {
      const orm = getORM();
      const result = await orm.query(HabitLog)
        .where({ habitId, date })
        .first();
      return result as HabitLog | null;
    } catch (e) {
      Logger.error(TAG, `findByDate failed: habitId=${habitId}, date=${date}`, e);
      return null;
    }
  }

  async checkin(habitId: number, date: string, completed: boolean, actualSets: number, actualReps: number, actualDuration: number): Promise<number> {
    try {
      const existing = await this.findByDate(habitId, date);
      if (existing) {
        existing.completed = completed ? 1 : 0;
        existing.actualSets = actualSets;
        existing.actualReps = actualReps;
        existing.actualDuration = actualDuration;
        return await this.update(existing);
      }
      const log = new HabitLog();
      log.habitId = habitId;
      log.date = date;
      log.completed = completed ? 1 : 0;
      log.actualSets = actualSets;
      log.actualReps = actualReps;
      log.actualDuration = actualDuration;
      return await this.insert(log);
    } catch (e) {
      Logger.error(TAG, `checkin failed: habitId=${habitId}, date=${date}`, e);
      return 0;
    }
  }

  async deleteById(id: number): Promise<number> {
    try {
      const orm = getORM();
      const existing = await orm.query(HabitLog)
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

export default new HabitLogRepository();
