/**
 * 习惯编辑 ViewModel
 * 管理习惯编辑页的状态和业务逻辑
 */
import { Habit } from 'core.model';
import { HabitRepository } from 'core.database';
import { DateUtil, Logger } from 'common.util';

const TAG = 'HabitEditVM';

const CATEGORY_OPTIONS: string[] = ['运动', '学习', '健康', '生活', '其他'];
const CATEGORY_COLORS: Record<string, string> = {
  '运动': '#F5222D',
  '学习': '#1890FF',
  '健康': '#52C41A',
  '生活': '#FA8C16',
  '其他': '#8C8C8C'
};

@Observed
export class HabitEditViewModel {
  name: string = '';
  category: string = '运动';
  frequency: number = 1;
  weekDays: boolean[] = [false, false, false, false, false, false, false];
  targetSets: number = 0;
  targetReps: number = 0;
  targetDuration: number = 0;
  icon: string = '⭐';

  private repo: HabitRepository = new HabitRepository();

  get categoryOptions(): string[] {
    return CATEGORY_OPTIONS;
  }

  getCategoryColor(cat: string): string {
    return CATEGORY_COLORS[cat] || '#8C8C8C';
  }

  get targetSummary(): string {
    const parts: string[] = [];
    if (this.targetSets > 0 && this.targetReps > 0) {
      parts.push(`${this.targetSets}组×${this.targetReps}次`);
    } else if (this.targetSets > 0) {
      parts.push(`${this.targetSets}组`);
    }
    if (this.targetDuration > 0) {
      parts.push(`${this.targetDuration}分钟`);
    }
    return parts.join(' · ') || '无量化目标';
  }

  async save(): Promise<boolean> {
    if (!this.name.trim()) return false;

    try {
      const selectedDaysArr: string[] = [];
      for (let i: number = 0; i < 7; i++) {
        if (this.weekDays[i]) {
          selectedDaysArr.push(String(i + 1));
        }
      }

      const habit = new Habit();
      habit.name = this.name;
      habit.category = this.category;
      habit.frequency = this.frequency;
      habit.weekDays = this.frequency === 2 ? selectedDaysArr.join(',') : '';
      habit.targetSets = this.targetSets;
      habit.targetReps = this.targetReps;
      habit.targetDuration = this.targetDuration;
      habit.icon = this.icon;
      habit.color = CATEGORY_COLORS[this.category] || '#8C8C8C';
      habit.sortOrder = 0;
      habit.createTime = DateUtil.getNow();
      habit.updateTime = DateUtil.getNow();

      await this.repo.insert(habit);
      return true;
    } catch (e) {
      Logger.error(TAG, 'save failed', e);
      return false;
    }
  }
}
