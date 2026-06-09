/**
 * 数据库助手类
 * 负责数据库初始化、表创建和种子数据
 */
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { CollectionType } from 'core.model';

const STORE_NAME: string = 'dungeontask.db';
const STORE_VERSION: number = 2;

export class DbHelper {
  private static instance: DbHelper;
  private rdbStore: relationalStore.RdbStore | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): DbHelper {
    if (!DbHelper.instance) {
      DbHelper.instance = new DbHelper();
    }
    return DbHelper.instance;
  }

  /**
   * 初始化数据库
   */
  async init(context: Context): Promise<void> {
    if (this.rdbStore) {
      return;
    }

    const config: relationalStore.StoreConfig = {
      name: STORE_NAME,
      securityLevel: relationalStore.SecurityLevel.S1
    };

    try {
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.createTables();
      console.info('Database initialized successfully');
    } catch (err) {
      const error = err as BusinessError;
      console.error('Database init failed: ' + error.message);
      throw new Error(`Database init failed: ${error.message}`);
    }
  }

  /**
   * 获取数据库实例
   */
  getRdbStore(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      throw new Error('Database not initialized, call init() first');
    }
    return this.rdbStore;
  }

  /**
   * 创建所有数据表
   * 统一包含 deviceId / syncStatus 字段以支持多端同步
   */
  private async createTables(): Promise<void> {
    const store = this.getRdbStore();

    // ==================== 1. 任务表 ====================
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 0,
        parentId INTEGER DEFAULT 0,
        level INTEGER DEFAULT 0,
        sortOrder INTEGER DEFAULT 0,
        tag TEXT DEFAULT '',
        deviceId TEXT DEFAULT '',
        syncStatus INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_task_date ON task(date)');
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_task_parentId ON task(parentId)');

    // ==================== 2. 习惯模板表 ====================
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS habit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency INTEGER DEFAULT 1,
        weekDays TEXT,
        targetSets INTEGER DEFAULT 0,
        targetReps INTEGER DEFAULT 0,
        targetDuration INTEGER DEFAULT 0,
        icon TEXT,
        color TEXT,
        sortOrder INTEGER DEFAULT 0,
        deviceId TEXT DEFAULT '',
        syncStatus INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_habit_category ON habit(category)');

    // ==================== 3. 习惯打卡表 ====================
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS habit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habitId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        actualSets INTEGER DEFAULT 0,
        actualReps INTEGER DEFAULT 0,
        actualDuration INTEGER DEFAULT 0,
        note TEXT,
        deviceId TEXT DEFAULT '',
        syncStatus INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habit(id)
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_habitlog_habitId ON habit_log(habitId)');
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_habitlog_date ON habit_log(date)');

    // ==================== 4. 收藏类型表 ====================
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS collection_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        label TEXT NOT NULL,
        isBuiltIn INTEGER DEFAULT 1,
        sortOrder INTEGER DEFAULT 0,
        deviceId TEXT DEFAULT '',
        syncStatus INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await this.seedCollectionTypes();

    // ==================== 5. 收集表 ====================
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        extra TEXT,
        tag TEXT,
        deviceId TEXT DEFAULT '',
        syncStatus INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_collection_type ON collection(type)');

    // ==================== 6. 备忘录表 ====================
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS memo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        deviceId TEXT DEFAULT '',
        syncStatus INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_memo_createTime ON memo(createTime)');
  }

  /**
   * 种入内置收藏类型（不存在才插入，防止重复）
   */
  private async seedCollectionTypes(): Promise<void> {
    const store = this.getRdbStore();
    const now = Date.now();
    const builtIn: CollectionType[] = [
      { name: 'sentence', label: '句子', sortOrder: 1, isBuiltIn: 1, createTime: now, updateTime: now } as CollectionType,
      { name: 'word', label: '词语', sortOrder: 2, isBuiltIn: 1, createTime: now, updateTime: now } as CollectionType,
      { name: 'quote', label: '台词', sortOrder: 3, isBuiltIn: 1, createTime: now, updateTime: now } as CollectionType,
      { name: 'knowledge', label: '知识点', sortOrder: 4, isBuiltIn: 1, createTime: now, updateTime: now } as CollectionType,
    ];
    for (const t of builtIn) {
      try {
        await store.executeSql(
          `INSERT OR IGNORE INTO collection_type (name, label, isBuiltIn, sortOrder, createTime, updateTime)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [t.name, t.label, t.isBuiltIn, t.sortOrder, t.createTime, t.updateTime]
        );
      } catch (e) {
        // 记录已存在时忽略
      }
    }
  }

  /**
   * 关闭数据库连接
   */
  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close();
      this.rdbStore = null;
    }
  }
}
