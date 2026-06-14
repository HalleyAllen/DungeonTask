/**
 * 习惯模板实体类（通用抽象，不限于健身）
 */
export class Habit {
  /** 自增主键 */
  id: number = 0;
  /** 习惯名称，如"晨跑"、"阅读" */
  name: string = '';
  /** 分类标签：运动/学习/健康/生活… */
  category: string = '';
  /** 频率：1=每天 2=每周指定日 */
  frequency: number = 1;
  /** 每周哪几天，如"1,3,5"（周一三五），frequency=2 时有效 */
  weekDays: string = '';
  /** 目标组数（运动类） */
  targetSets: number = 0;
  /** 每组目标次数（运动类） */
  targetReps: number = 0;
  /** 目标时长·分钟（阅读/冥想类） */
  targetDuration: number = 0;
  /** 图标/emoji */
  icon: string = '';
  /** 主题色 #HEX */
  color: string = '';
  /** 排序序号 */
  sortOrder: number = 0;
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
}

/**
 * 习惯打卡记录实体类
 */
export class HabitLog {
  /** 自增主键 */
  id: number = 0;
  /** 关联 Habit.id */
  habitId: number = 0;
  /** 打卡日期 YYYY-MM-DD */
  date: string = '';
  /** 是否完成 0=未完成 1=已完成 */
  completed: number = 0;
  /** 实际完成组数 */
  actualSets: number = 0;
  /** 实际每组次数 */
  actualReps: number = 0;
  /** 实际时长（分钟） */
  actualDuration: number = 0;
  /** 备注（当天感受） */
  note: string = '';
  /** 创建时间戳(ms) */
  createTime: number = 0;
}
