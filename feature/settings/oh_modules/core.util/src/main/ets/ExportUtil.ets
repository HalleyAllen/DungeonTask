/**
 * 数据导出工具类
 */
import picker from '@ohos.file.picker';
import { fileIo as fs } from '@kit.CoreFileKit';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Task, Habit, HabitLog, Collection, Memo, ExportData, ExportDataContent } from 'core.model';
import { DateUtil } from './DateUtil';
import { Constants } from './Constants';

export class ExportUtil {
  /**
   * 导出所有数据
   */
  static async exportAll(context: Context): Promise<string> {
    const dataContent: ExportDataContent = {
      tasks: await ExportUtil.queryAll<Task>('task'),
      habits: await ExportUtil.queryAll<Habit>('habit'),
      habitLogs: await ExportUtil.queryAll<HabitLog>('habit_log'),
      collections: await ExportUtil.queryAll<Collection>('collection'),
      memos: await ExportUtil.queryAll<Memo>('memo')
    };
    const data: ExportData = {
      exportTime: new Date().toISOString(),
      version: '1.0',
      appName: 'DungeonTask',
      data: dataContent
    };

    const jsonStr = JSON.stringify(data, null, 2);
    const fileName = `${Constants.EXPORT_FILE_PREFIX}${DateUtil.getToday()}${Constants.EXPORT_FILE_SUFFIX}`;
    
    await ExportUtil.saveToFile(context, fileName, jsonStr);
    return fileName;
  }

  /**
   * 导出单个模块数据
   */
  static async exportModule(context: Context, moduleName: string): Promise<string> {
    const tableName: string = ExportUtil.getTableName(moduleName);

    const data: Object[] = await ExportUtil.queryAll(tableName);
    const exportDataContent: ExportDataContent = {
      tasks: moduleName === 'task' ? data as Task[] : [],
      habits: moduleName === 'habit' ? data as Habit[] : [],
      habitLogs: moduleName === 'habit' ? [] : [],
      collections: moduleName === 'collection' ? data as Collection[] : [],
      memos: moduleName === 'memo' ? data as Memo[] : []
    };
    const exportData: ExportData = {
      exportTime: new Date().toISOString(),
      version: '1.0',
      appName: 'DungeonTask',
      data: exportDataContent
    };

    const jsonStr = JSON.stringify(exportData, null, 2);
    const fileName = `dungeontask_${moduleName}_${DateUtil.getToday()}.json`;
    
    await ExportUtil.saveToFile(context, fileName, jsonStr);
    return fileName;
  }

  /**
   * 模块名映射表名
   */
  private static getTableName(moduleName: string): string {
    if (moduleName === 'task') {
      return 'task';
    } else if (moduleName === 'habit') {
      return 'habit';
    } else if (moduleName === 'collection') {
      return 'collection';
    } else if (moduleName === 'memo') {
      return 'memo';
    } else {
      throw new Error(`Unknown module: ${moduleName}`);
    }
  }

  /**
   * 查询表中所有数据
   */
  private static async queryAll<T>(tableName: string): Promise<T[]> {
    try {
      const dbHelper = DbHelper.getInstance();
      const store = dbHelper.getRdbStore();
      const predicates = new relationalStore.RdbPredicates(tableName);
      const result = await store.query(predicates);
      
      const list: T[] = [];
      while (result.goToNextRow()) {
        const obj: Record<string, Object> = {};
        for (let i = 0; i < result.columnCount; i++) {
          const columnName = result.getColumnName(i);
          obj[columnName] = result.getValue(i) as Object;
        }
        list.push(obj as T);
      }
      result.close();
      return list;
    } catch (e) {
      console.error(`Query ${tableName} failed: ${e}`);
      return [];
    }
  }

  /**
   * 保存到文件
   */
  private static async saveToFile(context: Context, fileName: string, content: string): Promise<void> {
    // 使用文件选择器让用户选择保存位置
    const documentPicker = new picker.DocumentViewPicker(context);
    const saveOptions = new picker.DocumentSaveOptions();
    saveOptions.newFileNames = [fileName];
    
    try {
      const result = await documentPicker.save(saveOptions);
      if (result && result.length > 0) {
        const uri = result[0];
        const file = fs.openSync(uri, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE);
        fs.writeSync(file.fd, content);
        fs.closeSync(file);
        console.info(`File saved to: ${uri}`);
      }
    } catch (e) {
      console.error(`Save file failed: ${e}`);
      throw new Error(`Save file failed: ${e}`);
    }
  }
}
