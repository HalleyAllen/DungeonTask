import { ExportUtil } from 'core.util';
import { getORM } from '@ibestservices/ibest-orm';
import { Task, Habit, HabitLog, Collection, Memo, ExportData } from 'core.model';
import { util } from '@kit.ArkTS';
import { Logger } from 'common.util';

const TAG = 'SettingsVM';

/** 设置项 */
export interface SettingsItem {
  label: string;
  type: 'nav' | 'action' | 'info' | 'danger';
  actionId: string;
}

/** 设置分组 */
export interface SettingsSection {
  title: string;
  items: SettingsItem[];
}

export class SettingsViewModel {
  syncCode: string = '';
  exporting: boolean = false;

  /** 生成同步码（将全部数据编码为 base64） */
  generateSyncCode(): void {
    try {
      this.syncCode = '';
      this.buildSyncCode().then((code: string) => {
        this.syncCode = code;
      });
    } catch (e) {
      Logger.error(TAG, 'generateSyncCode failed', e);
    }
  }

  /** 通过同步码导入数据 */
  async importBySyncCode(context: Context, code: string): Promise<boolean> {
    try {
      const base64Helper = new util.Base64Helper();
      const decoded: Uint8Array = base64Helper.decodeSync(code);
      const decoder = new util.TextDecoder('utf-8');
      const jsonStr: string = decoder.decodeWithStream(decoded);
      const exportData: ExportData = JSON.parse(jsonStr);
      await this.restoreFromExport(exportData);
      return true;
    } catch (e) {
      Logger.error(TAG, 'importBySyncCode failed', e);
      return false;
    }
  }

  async clearAllData(context: Context): Promise<void> {
    try {
      const orm = getORM();
      await orm.query(Task).delete();
      await orm.query(Habit).delete();
      await orm.query(HabitLog).delete();
      await orm.query(Collection).delete();
      await orm.query(Memo).delete();
    } catch (e) {
      Logger.error(TAG, 'clearAllData failed', e);
    }
  }

  async exportData(context: Context): Promise<boolean> {
    this.exporting = true;
    try {
      const result = await ExportUtil.exportData(context);
      return result;
    } finally {
      this.exporting = false;
    }
  }

  async importData(context: Context): Promise<boolean> {
    return ExportUtil.importData(context);
  }

  getAppVersion(): string {
    return '1.0.0';
  }

  /** 构建设置菜单 */
  getSettingsSections(): SettingsSection[] {
    return [
      {
        title: '页面管理',
        items: [
          { label: '首页模块管理', type: 'nav', actionId: 'page_manage' }
        ]
      },
      {
        title: '数据同步',
        items: [
          { label: '生成同步码', type: 'action', actionId: 'sync_generate' },
          { label: '输入同步码导入', type: 'action', actionId: 'sync_import' }
        ]
      },
      {
        title: '数据管理',
        items: [
          { label: '导出数据到文件', type: 'action', actionId: 'export' },
          { label: '从文件导入数据', type: 'action', actionId: 'import' },
          { label: '清除所有数据', type: 'danger', actionId: 'clear' }
        ]
      },
      {
        title: '开发',
        items: [
          { label: '测试页面', type: 'nav', actionId: 'test_page' }
        ]
      },
      {
        title: '关于',
        items: [
          { label: `版本 ${this.getAppVersion()}`, type: 'info', actionId: 'version' }
        ]
      }
    ];
  }

  /** 构建同步码 */
  private async buildSyncCode(): Promise<string> {
    const orm = getORM();
    const exportData: ExportData = {
      version: '1.0',
      exportTime: new Date().toISOString(),
      appName: 'DungeonTask',
      data: {
        tasks: await orm.query(Task).find() as Task[],
        habits: await orm.query(Habit).find() as Habit[],
        habitLogs: await orm.query(HabitLog).find() as HabitLog[],
        collections: await orm.query(Collection).find() as Collection[],
        memos: await orm.query(Memo).find() as Memo[]
      }
    };
    const jsonStr = JSON.stringify(exportData);
    const encoder = new util.TextEncoder();
    const uint8Arr = encoder.encodeInto(jsonStr);
    const base64Helper = new util.Base64Helper();
    const base64Str = base64Helper.encodeToStringSync(uint8Arr);
    return base64Str;
  }

  /** 从导出数据恢复 */
  private async restoreFromExport(exportData: ExportData): Promise<void> {
    const orm = getORM();
    // 清空现有数据
    await orm.query(Task).delete();
    await orm.query(Habit).delete();
    await orm.query(HabitLog).delete();
    await orm.query(Collection).delete();
    await orm.query(Memo).delete();
    // 恢复数据
    const data = exportData.data;
    await orm.insert(data.tasks);
    await orm.insert(data.habits);
    await orm.insert(data.habitLogs);
    await orm.insert(data.collections);
    await orm.insert(data.memos);
  }
}

export default new SettingsViewModel();
