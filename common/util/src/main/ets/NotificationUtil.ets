/**
 * Copyright (C), 2026/06/13
 * @author HalleyAllen
 * @date 2026/06/13 11:42
 * @version 1.0
 * @description 消息通知工具，封装 HarmonyOS promptAction API
 *
 * NotificationUtil 是一个基于 promptAction 的单例实现，提供了统一的 Toast 提示能力。
 * 适用于应用内各模块、页面或服务之间的统一消息提示。
 */
import { promptAction } from '@kit.ArkUI';

class NotificationUtil {
  /**
   * 显示 Toast 提示
   * @param message 提示文本
   * @param duration 显示时长(ms)，默认 2000
   */
  public toast(message: string, duration: number = 2000): void {
    promptAction.showToast({
      message: message,
      duration: duration
    });
  }
}

// 创建单例实例
const notificationUtil = new NotificationUtil();

// 导出单例实例
export default notificationUtil as NotificationUtil;
