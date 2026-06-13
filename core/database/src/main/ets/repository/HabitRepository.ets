import { Habit } from 'core.model';
import { getORM } from '@ibestservices/ibest-orm';

export class HabitRepository {
  async findAll(): Promise<Habit[]> {
    try {
      const orm = getORM();
      const result = await orm.query(Habit).find();
      return result as Habit[];
    } catch (e) {
      console.error('HabitRepository.findAll failed:', e);
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
      console.error('HabitRepository.findById failed:', e);
      return null;
    }
  }

  async insert(habit: Habit): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.insert(habit);
      return result as number;
    } catch (e) {
      console.error('HabitRepository.insert failed:', e);
      return 0;
    }
  }

  async update(habit: Habit): Promise<number> {
    try {
      const orm = getORM();
      const result = await orm.save(habit);
      return result as number;
    } catch (e) {
      console.error('HabitRepository.update failed:', e);
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
      console.error('HabitRepository.deleteById failed:', e);
      return 0;
    }
  }
}

export default new HabitRepository();
