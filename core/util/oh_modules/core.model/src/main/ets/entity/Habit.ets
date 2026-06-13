import { Table, PrimaryKey, Column, ColumnType } from '@ibestservices/ibest-orm';

/**
 * 习惯模板实体
 */
@Table({ name: 'habit' })
export class Habit {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;

  @Column({ type: ColumnType.TEXT, notNull: true })
  name: string = '';

  @Column({ type: ColumnType.TEXT, notNull: true })
  category: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 1 })
  frequency: number = 1;

  @Column({ type: ColumnType.TEXT })
  weekDays: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  targetSets: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  targetReps: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  targetDuration: number = 0;

  @Column({ type: ColumnType.TEXT })
  icon: string = '';

  @Column({ type: ColumnType.TEXT })
  color: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  sortOrder: number = 0;

  @Column({ type: ColumnType.TEXT, defaultValue: '' })
  deviceId: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  syncStatus: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  createTime: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  updateTime: number = 0;
}

/**
 * 习惯打卡实体
 */
@Table({ name: 'habit_log' })
export class HabitLog {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  habitId: number = 0;

  @Column({ type: ColumnType.TEXT, notNull: true })
  date: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  completed: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  actualSets: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  actualReps: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  actualDuration: number = 0;

  @Column({ type: ColumnType.TEXT })
  note: string = '';

  @Column({ type: ColumnType.TEXT, defaultValue: '' })
  deviceId: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  syncStatus: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  createTime: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  updateTime: number = 0;
}
