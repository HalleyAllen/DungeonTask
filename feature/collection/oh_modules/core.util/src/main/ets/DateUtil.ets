/**
 * 日期工具类
 */
export class DateUtil {
  /**
   * 获取当前日期字符串 YYYY-MM-DD
   */
  static getToday(): string {
    const now = new Date();
    return DateUtil.formatDate(now);
  }

  /**
   * 格式化日期为 YYYY-MM-DD
   */
  static formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  /**
   * 获取当前时间戳(ms)
   */
  static getNow(): number {
    return Date.now();
  }

  /**
   * 获取本周开始日期
   */
  static getWeekStart(): string {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // 周一到周一
    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - diff);
    return DateUtil.formatDate(weekStart);
  }

  /**
   * 获取本周结束日期
   */
  static getWeekEnd(): string {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? 0 : 7 - dayOfWeek; // 周日到周日
    const weekEnd = new Date(now);
    weekEnd.setDate(now.getDate() + diff);
    return DateUtil.formatDate(weekEnd);
  }

  /**
   * 格式化时间戳为日期字符串
   */
  static formatTimestamp(timestamp: number): string {
    return DateUtil.formatDate(new Date(timestamp));
  }

  /**
   * 获取星期几的中文名称
   */
  static getWeekDayName(weekDay: number): string {
    const weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekDays[weekDay - 1] || '';
  }

  /**
   * 获取今天星期几 (1-7)
   */
  static getTodayWeekDay(): number {
    const day = new Date().getDay();
    return day === 0 ? 7 : day; // 周日=7
  }
}
