/**
 * 健身计划实体类
 */
export class FitnessPlan {
  /** 自增主键 */
  id: number = 0;
  /** 计划名称，如"周一胸肌训练" */
  name: string = '';
  /** 星期几 1(周一)-7(周日) */
  weekDay: number = 0;
  /** 训练项目（JSON字符串数组） */
  exercises: string = '';
  /** 创建时间戳(ms) */
  createTime: number = 0;
  /** 更新时间戳(ms) */
  updateTime: number = 0;
}

/**
 * 健身打卡记录实体类
 */
export class FitnessCheckin {
  /** 自增主键 */
  id: number = 0;
  /** 关联 FitnessPlan.id */
  planId: number = 0;
  /** 打卡日期 YYYY-MM-DD */
  date: string = '';
  /** 是否完成 0=未完成 1=已完成 */
  completed: number = 0;
  /** 创建时间戳(ms) */
  createTime: number = 0;
}
