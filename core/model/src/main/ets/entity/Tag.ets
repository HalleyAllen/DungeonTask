import { Table, PrimaryKey, Column, ColumnType } from '@ibestservices/ibest-orm';

/**
 * 标签实体（独立持久化，与任务解耦）
 */
@Table({ name: 'tag' })
export class Tag {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;

  @Column({ type: ColumnType.TEXT, notNull: true })
  name: string = '';

  @Column({ type: ColumnType.INTEGER, notNull: true })
  createTime: number = 0;

  /** 是否在任务列表顶栏显示（1=是，0=否） */
  @Column({ type: ColumnType.INTEGER, defaultValue: 1 })
  showInTopBar: number = 1;
}
