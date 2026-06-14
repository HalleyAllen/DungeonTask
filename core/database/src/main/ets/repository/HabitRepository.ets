import { Habit } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';
import { Logger } from 'common.util';

const TAG = 'HabitRepo';

export class HabitRepository {
  async findAll(): Promise<Habit[]> {
    try {
      const orm = getORM();
      const result = await orm.query(Habit).find();
      return result as Habit[];
    } catch (e) {
      Logger.error(TAG, 'findAll failed', e);
      return [];
    }
  }

  async findById(id: number): Promise<Habit | null> {
    try {
      const orm = getORM();
      const result = await orm.query(Habit)
        .where({ id })
        .first();
      return result as Habit | null;
    } catch (e) {
      Logger.error(TAG, `findById failed: id=${id}`, e);
      return null;
    }
  }

  async insert(habit: Habit): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(habit);
      Logger.debug(TAG, `insert: id=${habit.id}`);
      return result as number;
    } catch (e) {
      Logger.error(TAG, 'insert failed', e);
      return 0;
    }
  }

  async update(habit: Habit): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(habit);
      return result as number;
    } catch (e) {
      Logger.error(TAG, `update failed: id=${habit.id}`, e);
      return 0;
    }
  }

  async deleteById(id: number): Promise<number> {
    try {
      const orm = getORM();
      const existing = await orm.query(Habit)
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

export default new HabitRepository();
