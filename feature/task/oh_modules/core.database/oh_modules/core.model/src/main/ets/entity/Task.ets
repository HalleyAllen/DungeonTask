import { Table, PrimaryKey, Column, ColumnType } from '@ibestservices/ibest-orm';

/**
 * 任务实体
 */
@Table({ name: 'task' })
export class Task {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;

  @Column({ type: ColumnType.TEXT, notNull: true })
  title: string = '';

  @Column({ type: ColumnType.TEXT })
  content: string = '';

  @Column({ type: ColumnType.TEXT, notNull: true })
  date: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  completed: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  priority: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  parentId: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  level: number = 0;

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  sortOrder: number = 0;

  @Column({ type: ColumnType.TEXT, defaultValue: '' })
  tag: string = '';

  @Column({ type: ColumnType.TEXT, defaultValue: '' })
  deviceId: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  syncStatus: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  createTime: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  updateTime: number = 0;
}

/** 排序更新项 */
export class SortOrderItem  {
  id: number=0;
  sortOrder: number=0;
  priority: number=0;
};
