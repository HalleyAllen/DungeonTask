import { Table, PrimaryKey, Column, ColumnType } from '@ibestservices/ibest-orm';

/**
 * 备忘录实体
 */
@Table({ name: 'memo' })
export class Memo {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;

  @Column({ type: ColumnType.TEXT, notNull: true })
  content: string = '';

  @Column({ type: ColumnType.TEXT, defaultValue: '' })
  deviceId: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 0 })
  syncStatus: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  createTime: number = 0;

  @Column({ type: ColumnType.INTEGER, notNull: true })
  updateTime: number = 0;
}
