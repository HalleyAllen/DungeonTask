import { Table, PrimaryKey, Column, ColumnType } from '@ibestservices/ibest-orm';

/**
 * 收藏类型实体
 */
@Table({ name: 'collection_type' })
export class CollectionType {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;

  @Column({ type: ColumnType.TEXT, notNull: true })
  name: string = '';

  @Column({ type: ColumnType.TEXT, notNull: true })
  label: string = '';

  @Column({ type: ColumnType.INTEGER, defaultValue: 1 })
  isBuiltIn: number = 1;

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
