/**
 * 习惯列表页 ViewModel
 * 管理习惯列表数据加载、打卡、统计等业务逻辑
 */
import { Habit, HabitLog } from 'core.model';
import { HabitRepository, HabitLogRepository } from 'core.database';
import { DateUtil, Logger } from 'common.util';

const TAG = 'HabitPageVM';

@Observed
export class HabitPageViewModel {
  habits: Habit[] = [];
  todayChecked: Map<number, boolean> = new Map();
  todayLogs: Map<number, HabitLog> = new Map();
  isLoading: boolean = false;

  private habitRepo: HabitRepository = new HabitRepository();
  private logRepo: HabitLogRepository = new HabitLogRepository();

  async loadHabits(): Promise<void> {
    this.isLoading = true;
    try {
      this.habits = await this.habitRepo.findAll();
      await this.loadTodayCheckin();
    } catch (e) {
      Logger.error(TAG, 'loadHabits failed', e);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 页面可见时刷新
   */
  async refresh(): Promise<void> {
    await this.loadHabits();
  }

  async loadTodayCheckin(): Promise<void> {
    try {
      const today = DateUtil.getToday();
      const todayWeekDay = DateUtil.getTodayWeekDay();

      for (const habit of this.habits) {
        let isToday = false;
        if (habit.frequency === 1) {
          isToday = true;
        } else if (habit.frequency === 2 && habit.weekDays) {
          isToday = habit.weekDays.split(',').includes(String(todayWeekDay));
        }

        if (!isToday) continue;

        const log: HabitLog | null = await this.logRepo.findByDate(habit.id, today);
        if (log) {
          this.todayChecked.set(habit.id, log.completed === 1);
          this.todayLogs.set(habit.id, log);
        }
      }
    } catch (e) {
      Logger.error(TAG, 'loadTodayCheckin failed', e);
    }
  }

  async toggleCheckin(habit: Habit): Promise<void> {
    try {
      const today = DateUtil.getToday();
      const existing: HabitLog | null = await this.logRepo.findByDate(habit.id, today);

      if (existing) {
        await this.logRepo.checkin(
          habit.id,
          today,
          existing.completed !== 1,
          existing.actualSets,
          existing.actualReps,
          existing.actualDuration
        );
      } else {
        await this.logRepo.checkin(
          habit.id,
          today,
          true,
          habit.targetSets,
          habit.targetReps,
          habit.targetDuration
        );
      }
      await this.loadTodayCheckin();
    } catch (e) {
      Logger.error(TAG, 'toggleCheckin failed', e);
    }
  }

  /** 根据结构化字段生成目标描述文本 */
  targetText(h: Habit): string {
    const parts: string[] = [];
    if (h.targetSets > 0 && h.targetReps > 0) {
      parts.push(`${h.targetSets}组×${h.targetReps}次`);
    } else if (h.targetSets > 0) {
      parts.push(`${h.targetSets}组`);
    }
    if (h.targetDuration > 0) {
      parts.push(`${h.targetDuration}分钟`);
    }
    return parts.join(' · ');
  }

  /** 根据结构化字段生成本日实际完成描述 */
  actualText(log: HabitLog): string {
    const parts: string[] = [];
    if (log.actualSets > 0 && log.actualReps > 0) {
      parts.push(`${log.actualSets}组×${log.actualReps}次`);
    } else if (log.actualSets > 0) {
      parts.push(`${log.actualSets}组`);
    }
    if (log.actualDuration > 0) {
      parts.push(`${log.actualDuration}分钟`);
    }
    return parts.join(' · ');
  }

  /** 获取习惯分类（去重+排序） */
  get categories(): string[] {
    const set = new Set<string>();
    this.habits.forEach(h => {
      if (h.category) set.add(h.category);
    });
    return Array.from(set).sort();
  }

  /** 今天需要打卡的习惯 */
  get todayHabits(): Habit[] {
    const todayWeekDay = DateUtil.getTodayWeekDay();
    return this.habits.filter(h => {
      if (h.frequency === 1) return true;
      if (h.frequency === 2 && h.weekDays) {
        return h.weekDays.split(',').includes(String(todayWeekDay));
      }
      return false;
    });
  }

  weekDayNames(weekDays: string): string {
    return weekDays.split(',').map((d: string) =>
      ['', '一', '二', '三', '四', '五', '六', '日'][parseInt(d)]
    ).join(' ');
  }
}
