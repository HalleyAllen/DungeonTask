/**
 * 备忘录实体类
 */
export class Memo {
  /** 自增主键 */
  id: number = 0;
  /** 备忘录内容 */
  content: string = '';
  /** 创建时间戳(ms)（用于倒序排序） */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
  /** 同步：写入设备标识 */
  deviceId: string = '';
  /** 同步：0=未同步 1=已同步 */
  syncStatus: number = 0;
}
