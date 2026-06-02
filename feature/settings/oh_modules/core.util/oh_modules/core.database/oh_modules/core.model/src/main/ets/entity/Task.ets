/**
 * 任务排序更新参数
 */
export interface SortOrderItem {
  id: number;
  sortOrder: number;
  priority: number;
}

/**
 * 任务实体类
 * 支持层级拆分（parentId/level/sortOrder）
 */
export class Task {
  /** 自增主键 */
  id: number = 0;
  /** 任务标题 */
  title: string = '';
  /** 任务内容/备注 */
  content: string = '';
  /** 所属日期 YYYY-MM-DD */
  date: string = '';
  /** 是否完成 0=未完成 1=已完成 */
  completed: number = 0;
  /** 排序优先级，数值越大越靠前 */
  priority: number = 0;
  /** 父任务ID，0=顶级任务 */
  parentId: number = 0;
  /** 层级深度 0-4 */
  level: number = 0;
  /** 同级排序序号 */
  sortOrder: number = 0;
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
  /** 同步：写入设备标识 */
  deviceId: string = '';
  /** 同步：0=未同步 1=已同步 */
  syncStatus: number = 0;
}
