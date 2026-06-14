/**
 * 备忘录实体类
 */
export class Memo {
  /** 自增主键 */
  id: number = 0;
  /** 备忘录内容 */
  content: string = '';
  /** 创建时间戳（用于倒序排序） */
  createTime: number = 0;
  /** 更新时间戳 */
  updateTime: number = 0;
}
