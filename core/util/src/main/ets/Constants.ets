/**
 * 常量定义
 */
export class Constants {
  /** 数据库名称 */
  static readonly DB_NAME: string = 'dungeontask.db';
  
  /** 数据库版本 */
  static readonly DB_VERSION: number = 1;

  /** 日期格式 */
  static readonly DATE_FORMAT: string = 'YYYY-MM-DD';

  /** 完成状态 */
  static readonly CompleteStatus = {
    UNCOMPLETED: 0,
    COMPLETED: 1
  } as const;

  /** 导出文件名 */
  static readonly EXPORT_FILE_PREFIX: string = 'dungeontask_backup_';

  /** 导出文件后缀 */
  static readonly EXPORT_FILE_SUFFIX: string = '.json';
}
