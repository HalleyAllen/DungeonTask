/**
 * Copyright (C), 2026/06/13
 * @date 2026/06/13 12:06
 * @version 1.0
 * @description 统一日志工具（单例），带模块标签和时间戳
 *
 * Logger 提供四个等级的日志输出：DEBUG / INFO / WARN / ERROR。
 * 每条日志自动附加 [模块名] 前缀，方便按模块过滤排查。
 */
class Logger {
  /** 全局日志开关 */
  private enabled: boolean = true;

  /** 启用/禁用日志 */
  public setEnabled(on: boolean): void {
    this.enabled = on;
  }

  /**
   * 调试日志（仅开发阶段使用）
   */
  public debug(module: string, message: string, ...args: object[]): void {
    if (!this.enabled) return;
    const ts = this.timestamp();
    console.debug(`${ts} [${module}] DEBUG: ${message}`, ...args);
  }

  /**
   * 信息日志
   */
  public info(module: string, message: string, ...args: object[]): void {
    if (!this.enabled) return;
    const ts = this.timestamp();
    console.info(`${ts} [${module}] INFO: ${message}`, ...args);
  }

  /**
   * 警告日志
   */
  public warn(module: string, message: string, ...args: object[]): void {
    if (!this.enabled) return;
    const ts = this.timestamp();
    console.warn(`${ts} [${module}] WARN: ${message}`, ...args);
  }

  /**
   * 错误日志（自动提取异常信息）
   */
  public error(module: string, message: string, err?: Error | object): void {
    if (!this.enabled) return;
    const ts = this.timestamp();
    if (err instanceof Error) {
      console.error(`${ts} [${module}] ERROR: ${message} | ${err.name}: ${err.message}`);
    } else if (err) {
      console.error(`${ts} [${module}] ERROR: ${message}`, JSON.stringify(err));
    } else {
      console.error(`${ts} [${module}] ERROR: ${message}`);
    }
  }

  /** 格式化时间戳 HH:mm:ss.SSS */
  private timestamp(): string {
    const d = new Date();
    const hh = String(d.getHours()).padStart(2, '0');
    const mm = String(d.getMinutes()).padStart(2, '0');
    const ss = String(d.getSeconds()).padStart(2, '0');
    const ms = String(d.getMilliseconds()).padStart(3, '0');
    return `${hh}:${mm}:${ss}.${ms}`;
  }
}

const logger = new Logger();
export default logger as Logger;
