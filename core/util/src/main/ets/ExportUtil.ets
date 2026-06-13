import { util } from '@kit.ArkTS';
import picker from '@ohos.file.picker';
import { fileIo as fs } from '@kit.CoreFileKit';
import { getORM } from '@ibestservices/ibest-orm';
import { Task, Habit, HabitLog, Collection, Memo, ExportData } from 'core.model';
import { DateUtil } from 'common.util';

export class ExportUtil {
  private static readonly EXPORT_FILENAME: string = 'DungeonTask_Backup.txt';

  static async exportData(context: Context): Promise<boolean> {
    try {
      const docsDir = context.filesDir;
      const filePath = `${docsDir}/${ExportUtil.EXPORT_FILENAME}`;

      const exportData = await ExportUtil.buildExportData();
      const jsonStr = JSON.stringify(exportData, null, 2);

      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, jsonStr);
      fs.closeSync(file);

      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [ExportUtil.EXPORT_FILENAME];
      const documentViewPicker = new picker.DocumentViewPicker();
      await documentViewPicker.save(documentSaveOptions);

      return true;
    } catch (e) {
      console.error('Export data failed:', e);
      return false;
    }
  }

  static async importData(context: Context): Promise<boolean> {
    try {
      const documentSelectOptions = new picker.DocumentSelectOptions();
      const documentViewPicker = new picker.DocumentViewPicker();
      const uris = await documentViewPicker.select(documentSelectOptions);

      if (uris.length === 0) {
        return false;
      }

      const file = fs.openSync(uris[0], fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(file.fd);
      const buf = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buf);
      fs.closeSync(file);

      const decoder = new util.TextDecoder('utf-8');
      const content = decoder.decodeWithStream(new Uint8Array(buf));
      const exportData = JSON.parse(content) as ExportData;

      await ExportUtil.restoreData(exportData);
      return true;
    } catch (e) {
      console.error('Import data failed:', e);
      return false;
    }
  }

  private static async buildExportData(): Promise<ExportData> {
    const orm = getORM();
    const exportData: ExportData = {
      version: '1.0',
      exportTime: DateUtil.formatDate(new Date()),
      appName: 'DungeonTask',
      data: {
        tasks: await orm.query(Task).find() as Task[],
        habits: await orm.query(Habit).find() as Habit[],
        habitLogs: await orm.query(HabitLog).find() as HabitLog[],
        collections: await orm.query(Collection).find() as Collection[],
        memos: await orm.query(Memo).find() as Memo[]
      }
    };
    return exportData;
  }

  private static async clearAllTables(): Promise<void> {
    const orm = getORM();
    const allTasks = await orm.query(Task).find() as Task[];
    for (const item of allTasks) {
      await orm.delete(item);
    }
    const allHabits = await orm.query(Habit).find() as Habit[];
    for (const item of allHabits) {
      await orm.delete(item);
    }
    const allHabitLogs = await orm.query(HabitLog).find() as HabitLog[];
    for (const item of allHabitLogs) {
      await orm.delete(item);
    }
    const allCollections = await orm.query(Collection).find() as Collection[];
    for (const item of allCollections) {
      await orm.delete(item);
    }
    const allMemos = await orm.query(Memo).find() as Memo[];
    for (const item of allMemos) {
      await orm.delete(item);
    }
  }

  private static async insertAll(items: Object[]): Promise<void> {
    const orm = getORM();
    for (const item of items) {
      await orm.insert(item);
    }
  }

  private static async restoreData(exportData: ExportData): Promise<void> {
    await ExportUtil.clearAllTables();
    const data = exportData.data;
    await ExportUtil.insertAll(data.tasks);
    await ExportUtil.insertAll(data.habits);
    await ExportUtil.insertAll(data.habitLogs);
    await ExportUtil.insertAll(data.collections);
    await ExportUtil.insertAll(data.memos);
  }
}
