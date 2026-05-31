/**
 * ViewModel 基类
 * 提供通用状态管理能力
 */

export abstract class BaseViewModel {
  /** 加载状态 */
  isLoading: boolean = false;

  /** 错误信息 */
  errorMessage: string = '';

  /** 显示加载中 */
  showLoading(): void {
    this.isLoading = true;
  }

  /** 隐藏加载中 */
  hideLoading(): void {
    this.isLoading = false;
  }

  /** 显示错误信息 */
  showError(message: string): void {
    this.errorMessage = message;
  }

  /** 清除错误信息 */
  clearError(): void {
    this.errorMessage = '';
  }
}
