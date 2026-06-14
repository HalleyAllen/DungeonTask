/**
 * 收藏类型选项
 */
export interface CollectionTypeItem {
  label: string;
  value: string;
  isBuiltIn: number;
}

/**
 * 收藏子项
 */
export interface CollectionSubItem {
  text: string;
  completed: boolean;
}

/**
 * 收藏扩展数据（extra JSON 解析后）
 */
export class CollectionExtra {
  pinyin?: string;
  explanation?: string;
  source?: string;
  author?: string;
  desc?: string;
  deadline?: number;
  subItems?: CollectionSubItem[];
}

/**
 * 收集实体类（统一抽象）
 * 统一管理句子、词语、台词、知识点等碎片收藏
 */
export class Collection {
  /** 自增主键 */
  id: number = 0;
  /** 类型：sentence/word/quote/knowledge… */
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
}
