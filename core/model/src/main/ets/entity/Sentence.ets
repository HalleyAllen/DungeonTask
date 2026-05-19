/**
 * 句子实体类
 */
export class Sentence {
  /** 自增主键 */
  id: number = 0;
  /** 句子内容 */
  content: string = '';
  /** 来源（可选） */
  source: string = '';
  /** 标签（可选） */
  tag: string = '';
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
}
