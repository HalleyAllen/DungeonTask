/**
 * 设置页 ViewModel
 * 管理设置页状态和业务逻辑
 */
import { ExportUtil } from 'core.util';
import { DbHelper } from 'core.database';
import { systemDateTime } from '@kit.BasicServicesKit';

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
