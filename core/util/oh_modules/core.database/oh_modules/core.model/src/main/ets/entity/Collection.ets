/**
 * 收集实体类（统一抽象）
 * 统一管理句子、词语、台词、知识点等碎片收藏
 */
export class Collection {
  /** 自增主键 */
  id: number = 0;
  /** 类型标识，关联 collection_type.name */
  type: string = '';
  /** 标题（词语名 / 句子首句） */
  title: string = '';
  /** 主体内容（全文 / 释义…） */
  content: string = '';
  /** 扩展字段 JSON（拼音、出处等类型特有信息） */
  extra: string = '';
  /** 标签（逗号分隔） */
  tag: string = '';
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
  /** 同步：写入设备标识 */
  deviceId: string = '';
  /** 同步：0=未同步 1=已同步 */
  syncStatus: number = 0;
}

/** 收藏类型选项（用于UI展示） */
export interface CollectionTypeItem {
  label: string;
  value: string;
  isBuiltIn: number;
}

/** 收藏扩展数据（extra字段JSON结构） */
export interface CollectionExtra {
  pinyin?: string;
  explanation?: string;
  source?: string;
  author?: string;
  desc?: string;
}
