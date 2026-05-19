/**
 * 词语实体类
 */
export class Word {
  /** 自增主键 */
  id: number = 0;
  /** 词语名称 */
  name: string = '';
  /** 拼音 */
  pinyin: string = '';
  /** 释义 */
  explanation: string = '';
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
}
