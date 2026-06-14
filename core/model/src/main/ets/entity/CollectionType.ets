/**
 * 收藏类型实体
 * 支持内置类型（句子/词语/台词/知识点）+ 用户自定义类型
 */
export class CollectionType {
  /** 自增主键 */
  id: number = 0;
  /** 类型标识（如 sentence/word/quote/knowledge） */
  name: string = '';
  /** 显示名称 */
  label: string = '';
  /** 是否内置类型 1=是 0=否（用户自定义） */
  isBuiltIn: number = 0;
  /** 排序 */
  sortOrder: number = 0;
  /** 创建时间戳(ms) */
  createTime: number = 0;
}
