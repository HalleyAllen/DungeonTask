/**
 * 数据导出工具类
 */
import { filePicker } from '@kit.CoreFileKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { Task, FitnessPlan, FitnessCheckin, Sentence, Word, Goal, Memo } from 'core.model';
import { DateUtil, Constants } from './Constants';

interface ExportData {
  exportTime: string;
  version: string;
  appName: string;
  data: {
    tasks: Task[];
    fitnessPlans: FitnessPlan[];
    fitnessCheckins: FitnessCheckin[];
    sentences: Sentence[];
    words: Word[];
    goals: Goal[];
    memos: Memo[];
  };
}

export class ExportUtil {
  /**
   * 导出所有数据
   */
  static async exportAll(context: Context): Promise<string> {
    const data: ExportData = {
      exportTime: new Date().toISOString(),
      version: '1.0',
      appName: 'DungeonTask',
      data: {
        tasks: await ExportUtil.queryAll<Task>('task'),
        fitnessPlans: await ExportUtil.queryAll<FitnessPlan>('fitness_plan'),
        fitnessCheckins: await ExportUtil.queryAll<FitnessCheckin>('fitness_checkin'),
        sentences: await ExportUtil.queryAll<Sentence>('sentence'),
        words: await ExportUtil.queryAll<Word>('word'),
        goals: await ExportUtil.queryAll<Goal>('goal'),
        memos: await ExportUtil.queryAll<Memo>('memo')
      }
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
    const tableMap: Record<string, string> = {
      task: 'task',
      fitness: 'fitness_plan',
      sentence: 'sentence',
      word: 'word',
      goal: 'goal',
      memo: 'memo'
    };

    const tableName = tableMap[moduleName];
    if (!tableName) {
      throw new Error(`Unknown module: ${moduleName}`);
    }

    const data = await ExportUtil.queryAll(tableName);
    const exportData: ExportData = {
      exportTime: new Date().toISOString(),
      version: '1.0',
      appName: 'DungeonTask',
      data: {
        tasks: moduleName === 'task' ? data as Task[] : [],
        fitnessPlans: moduleName === 'fitness' ? data as FitnessPlan[] : [],
        fitnessCheckins: moduleName === 'fitness' ? [] : [],
        sentences: moduleName === 'sentence' ? data as Sentence[] : [],
        words: moduleName === 'word' ? data as Word[] : [],
        goals: moduleName === 'goal' ? data as Goal[] : [],
        memos: moduleName === 'memo' ? data as Memo[] : []
      }
    };

    const jsonStr = JSON.stringify(exportData, null, 2);
    const fileName = `dungeontask_${moduleName}_${DateUtil.getToday()}.json`;
    
    await ExportUtil.saveToFile(context, fileName, jsonStr);
    return fileName;
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
    const documentPicker = new filePicker.DocumentPicker(context);
    const saveOptions = new filePicker.DocumentSaveOptions();
    saveOptions.newFileNames = [fileName];
    saveOptions.defaultFilePathUri = '';
    
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
      throw e;
    }
  }
}
