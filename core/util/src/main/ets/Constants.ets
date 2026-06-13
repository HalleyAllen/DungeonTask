/**
 * 项目常量定义
 */

/** 完成状态 */
interface CompleteStatusType {
  UNCOMPLETED: number;
  COMPLETED: number;
}

/** 习惯频率 */
interface HabitFrequencyType {
  DAILY: number;
  WEEKLY: number;
}

/** 收集类型 */
interface CollectionTypeType {
  SENTENCE: string;
  WORD: string;
  QUOTE: string;
  KNOWLEDGE: string;
}

export class Constants {
  /** 数据库名称 */
  static readonly DB_NAME: string = 'dungeontask.db';
  
  /** 数据库版本 */
  static readonly DB_VERSION: number = 1;

  /** 日期格式 */
  static readonly DATE_FORMAT: string = 'YYYY-MM-DD';

  /** 完成状态 */
  static readonly CompleteStatus: CompleteStatusType = {
    UNCOMPLETED: 0,
    COMPLETED: 1
  };

  /** 习惯频率 */
  static readonly HabitFrequency: HabitFrequencyType = {
    DAILY: 1,   // 每天
    WEEKLY: 2   // 每周指定日
  };

  /** 收集类型 */
  static readonly CollectionType: CollectionTypeType = {
    SENTENCE: 'sentence',   // 句子
    WORD: 'word',           // 词语
    QUOTE: 'quote',         // 台词
    KNOWLEDGE: 'knowledge'  // 知识点
  };

  /** 导出文件名 */
  static readonly EXPORT_FILE_PREFIX: string = 'dungeontask_backup_';

  /** 导出文件后缀 */
  static readonly EXPORT_FILE_SUFFIX: string = '.json';
}
