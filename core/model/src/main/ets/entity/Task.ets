/**
 * 任务实体类
 */
export class Task {
  /** 自增主键 */
  id: number = 0;
  /** 任务标题 */
  title: string = '';
  /** 任务内容（可选） */
  content: string = '';
  /** 所属日期 YYYY-MM-DD */
  date: string = '';
  /** 是否完成 0=未完成 1=已完成 */
  completed: number = 0;
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
}
