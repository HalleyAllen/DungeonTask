/**
 * 目标实体类（支持树形层级结构）
 */
export class Goal {
  /** 自增主键 */
  id: number = 0;
  /** 目标标题 */
  title: string = '';
  /** 类型：1=短期 2=长期 */
  type: number = 0;
  /** 进度 0-100（百分比） */
  progress: number = 0;
  /** 是否完成 0=进行中 1=已完成 */
  completed: number = 0;
  /** 父目标ID，0表示顶级 */
  parentId: number = 0;
  /** 层级深度 0-4（最大5层） */
  level: number = 0;
  /** 同级排序序号 */
  sortOrder: number = 0;
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
}
