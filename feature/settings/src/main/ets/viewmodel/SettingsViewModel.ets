/**
 * 设置页 ViewModel
 * 管理设置页状态和业务逻辑
 */
import { ExportUtil } from 'core.util';
import { DbHelper } from 'core.database';
import { systemDateTime } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import { HMRouter } from '@hadss/hmrouter';

const PREF_NAME: string = 'dungeontask_settings';
const KEY_PAGE_ORDER: string = 'page_order';
const KEY_PAGE_VISIBLE: string = 'page_visible';

@Observed
export class SettingsViewModel {
  /** 当前 app 版本 */
  appVersion: string = '1.0.0';
  /** 数据导出中状态 */
  exporting: boolean = false;
  /** 同步码 */
  syncCode: string = '';
  /** 同步中 */
  syncing: boolean = false;
  /** 页面配置列表 */
  pageConfigs: PageConfig[] = [];

  /**
   * 导出全部数据
   */
  async exportData(context: Context): Promise<void> {
    if (this.exporting) return;
    this.exporting = true;
    try {
      await ExportUtil.exportAll(context);
    } catch (e) {
      console.error('Export failed:', e);
    }
    this.exporting = false;
  }

  /**
   * 生成同步码
   */
  generateSyncCode(): void {
    const now = systemDateTime.getTime();
    const random = Math.floor(Math.random() * 9000) + 1000;
    this.syncCode = `DT-${now}-${random}`;
  }

  /**
   * 通过同步码导入数据
   */
  async importBySyncCode(context: Context, code: string): Promise<boolean> {
    if (this.syncing) return false;
    this.syncing = true;
    try {
      // TODO: 实际通过同步码从远端获取数据，当前使用本地导入作为占位
      return true;
    } catch (e) {
      console.error('Sync import failed:', e);
      return false;
    } finally {
      this.syncing = false;
    }
  }

  /**
   * 清除所有数据
   */
  async clearAllData(context: Context): Promise<void> {
    try {
      const dbHelper = DbHelper.getInstance();
      const store = dbHelper.getRdbStore();
      const tables = ['task', 'habit', 'habit_log', 'collection', 'memo'];
      for (const table of tables) {
        store.executeSql(`DELETE FROM ${table}`);
      }
    } catch (e) {
      console.error('Clear data failed:', e);
    }
  }

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
      console.error('Save page config failed:', e);
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
    const direction = steps > 0 ? 1 : -1;
    const count = Math.abs(steps);
    let current = idx;
    for (let i = 0; i < count; i++) {
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

  /**
   * 获取数据统计摘要（各模块记录数）
   */
  getDataSummary(): DataSummaryItem[] {
    // TODO: 后续接入各模块的实际统计
    return [
      { label: '任务', count: '--' },
      { label: '习惯', count: '--' },
      { label: '收藏', count: '--' },
      { label: '备忘', count: '--' }
    ];
  }

  /**
   * 设置列表项配置
   */
  getSettingsSections(): SettingsSection[] {
    return [
      {
        title: '同步与共享',
        items: [
          { label: '生成同步码', type: 'action', actionId: 'sync_generate' },
          { label: '通过同步码导入', type: 'action', actionId: 'sync_import' }
        ]
      },
      {
        title: '数据管理',
        items: [
          { label: '页面管理', type: 'nav', actionId: 'page_manage' },
          { label: '导出全部数据', type: 'action', actionId: 'export' },
          { label: '导入数据', type: 'action', actionId: 'import' },
          { label: '清除所有数据', type: 'danger', actionId: 'clear' }
        ]
      },
      {
        title: '关于',
        items: [
          { label: `版本 ${this.appVersion}`, type: 'info' },
          { label: '开源许可', type: 'nav' }
        ]
      }
    ];
  }
}

/**
 * 数据摘要项
 */
export interface DataSummaryItem {
  label: string;
  count: string;
}

/**
 * 设置区域
 */
export interface SettingsSection {
  title: string;
  items: SettingsItem[];
}

/**
 * 设置项
 */
export interface SettingsItem {
  label: string;
  type: 'action' | 'nav' | 'info' | 'danger';
  actionId?: string;
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
  const pairs = visibleStr.split(',');
  for (const pair of pairs) {
    const parts = pair.split(':');
    if (parts.length === 2 && parts[0] === key) {
      return parts[1] === '1';
    }
  }
  return true;
}
