import { Task } from './Task';
import { Habit, HabitLog } from './Habit';
import { Collection } from './Collection';
import { Memo } from './Memo';

/** 导出数据内容 */
export interface ExportDataContent {
  tasks: Task[];
  habits: Habit[];
  habitLogs: HabitLog[];
  collections: Collection[];
  memos: Memo[];
}

/** 导出数据 */
export interface ExportData {
  exportTime: string;
  version: string;
  appName: string;
  data: ExportDataContent;
}
