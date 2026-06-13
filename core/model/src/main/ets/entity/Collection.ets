import { Column, ColumnType, PrimaryKey, Table } from '@ibestservices/ibest-orm';

/**
 * 收藏实体
 */
@Table({ name: 'collection' })
export class Collection {
  @PrimaryKey({ autoIncrement: true })
  id: number = 0;
  @Column({ type: ColumnType.TEXT, notNull: true })
  type: string = '';
  @Column({ type: ColumnType.TEXT, notNull: true })
  title: string = '';
  @Column({ type: ColumnType.TEXT })
  content: string = '';
  @Column({ type: ColumnType.TEXT })
  extra: string = '';
  @Column({ type: ColumnType.TEXT })
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

/** 收藏类型展示项 */
export class CollectionTypeItem {
  label: string = "";
  value: string = "";
  isBuiltIn: number = 0;
}
;

/** 收藏子项 */
export class CollectionSubItem {
  text: string = "";
  completed: boolean = false;
}
;

/** 收藏扩展字段 */
export class CollectionExtra {
  pinyin?: string;
  explanation?: string;
  source?: string;
  author?: string;
  desc?: string;
  deadline?: number;
  subItems?: CollectionSubItem[];
}
;
