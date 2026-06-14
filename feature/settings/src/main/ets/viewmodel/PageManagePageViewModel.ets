/**
 * 页面管理 ViewModel
 * 管理导航栏页面的排序与显隐控制
 */
import { preferences } from '@kit.ArkData';
import { Logger } from 'common.util';

const TAG = 'PageManageVM';
const PREF_NAME: string = 'dungeontask_settings';
const KEY_PAGE_ORDER: string = 'page_order';
const KEY_PAGE_VISIBLE: string = 'page_visible';

@Observed
export class PageManagePageViewModel {
  /** 页面配置列表 */
  pageConfigs: PageConfig[] = [];

  /**
   * 加载页面配置（排序与显隐）
   */
  async loadPageConfig(context: Context): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(context, PREF_NAME);
      const orderStr = await prefs.get(KEY_PAGE_ORDER, '') as string;
      const visibleStr = await prefs.get(KEY_PAGE_VISIBLE, '') as string;

      const savedOrder: string[] = orderStr ? orderStr.split(',') : [];

      // 合并默认值和保存值
      const allKeys = ['task', 'habit', 'collection', 'memo'];
      const orderSet = new Set(savedOrder);
      // 补充新增的页面到末尾
      allKeys.forEach((k: string) => {
        if (!orderSet.has(k)) {
          savedOrder.push(k);
        }
      });

      const configs: PageConfig[] = [];
      for (const key of savedOrder) {
        configs.push({
          key: key,
          label: getPageLabel(key),
          visible: getPageVisible(visibleStr, key)
        });
      }
      this.pageConfigs = configs;
    } catch (e) {
      Logger.error(TAG, 'loadPageConfig failed, using defaults', e);
      // 加载失败用默认值
      this.pageConfigs = DEFAULT_PAGE_CONFIGS.slice();
    }
  }

  /**
   * 保存页面配置
   */
  async savePageConfig(context: Context): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(context, PREF_NAME);
      const orderStr = this.pageConfigs.map((c: PageConfig) => c.key).join(',');
      const visibleStr = this.pageConfigs.map((c: PageConfig) => `${c.key}:${c.visible ? '1' : '0'}`).join(',');
      await prefs.put(KEY_PAGE_ORDER, orderStr);
      await prefs.put(KEY_PAGE_VISIBLE, visibleStr);
      await prefs.flush();
    } catch (e) {
      Logger.error(TAG, 'savePageConfig failed', e);
    }
  }

  /**
   * 上移页面
   */
  movePageUp(context: Context, index: number): void {
    if (index <= 0) return;
    const arr = [...this.pageConfigs];
    const tmp = arr[index - 1];
    arr[index - 1] = arr[index];
    arr[index] = tmp;
    this.pageConfigs = arr;
    this.savePageConfig(context);
  }

  /**
   * 下移页面
   */
  movePageDown(context: Context, index: number): void {
    if (index >= this.pageConfigs.length - 1) return;
    const arr = [...this.pageConfigs];
    const tmp = arr[index];
    arr[index] = arr[index + 1];
    arr[index + 1] = tmp;
    this.pageConfigs = arr;
    this.savePageConfig(context);
  }

  /**
   * 切换页面显隐
   */
  togglePageVisible(context: Context, index: number): void {
    const arr = [...this.pageConfigs];
    arr[index].visible = !arr[index].visible;
    this.pageConfigs = arr;
    this.savePageConfig(context);
  }

  /**
   * 按步长移动页面（拖拽排序用）
   * @param key  被拖拽项的 key
   * @param steps 正数向下、负数向上，每步换 1 位
   * @returns 新的 pageConfigs 引用（供 View 层 @State 刷新）
   */
  movePageBySteps(key: string, steps: number): PageConfig[] {
    if (steps === 0) {
      return this.pageConfigs;
    }
    const arr = [...this.pageConfigs];
    const idx = arr.findIndex((c: PageConfig) => c.key === key);
    if (idx < 0) {
      return this.pageConfigs;
    }
    const direction: number = steps > 0 ? 1 : -1;
    const count: number = Math.abs(steps);
    let current: number = idx;
    for (let i: number = 0; i < count; i++) {
      const target = current + direction;
      if (target < 0 || target >= arr.length) {
        break;
      }
      const tmp = arr[current];
      arr[current] = arr[target];
      arr[target] = tmp;
      current = target;
    }
    this.pageConfigs = arr;
    return arr;
  }

  /**
   * 持久化当前页面排序
   */
  commitPageOrder(context: Context): void {
    this.savePageConfig(context);
  }
}

/**
 * 页面配置项
 */
export interface PageConfig {
  key: string;
  label: string;
  visible: boolean;
}

const DEFAULT_PAGE_CONFIGS: PageConfig[] = [
  { key: 'task', label: '任务', visible: true },
  { key: 'habit', label: '习惯', visible: true },
  { key: 'collection', label: '收藏', visible: true },
  { key: 'memo', label: '备忘', visible: true }
];

function getPageLabel(key: string): string {
  if (key === 'task') return '任务';
  if (key === 'habit') return '习惯';
  if (key === 'collection') return '收藏';
  if (key === 'memo') return '备忘';
  return key;
}

function getPageVisible(visibleStr: string, key: string): boolean {
  if (!visibleStr) return true;
  const pairs: string[] = visibleStr.split(',');
  for (const pair of pairs) {
    const parts: string[] = pair.split(':');
    if (parts.length === 2 && parts[0] === key) {
      return parts[1] === '1';
    }
  }
  return true;
}
