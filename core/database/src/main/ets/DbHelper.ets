/**
 * 数据库助手类
 * 负责数据库初始化和表创建
 */
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

const STORE_NAME: string = 'dungeontask.db';
const STORE_VERSION: number = 1;

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
      throw new Error('Database init failed: ' + error.message);
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
   * 创建数据表
   */
  private async createTables(): Promise<void> {
    const store = this.getRdbStore();

    // 任务表（支持层级拆分）
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
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_task_date ON task(date)');
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_task_parentId ON task(parentId)');

    // 习惯模板表（通用抽象）
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS habit (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency INTEGER NOT NULL DEFAULT 1,
        weekDays TEXT,
        targetSets INTEGER DEFAULT 0,
        targetReps INTEGER DEFAULT 0,
        targetDuration INTEGER DEFAULT 0,
        icon TEXT,
        color TEXT,
        sortOrder INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_habit_category ON habit(category)');

    // 习惯打卡表
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
        createTime INTEGER NOT NULL,
        FOREIGN KEY (habitId) REFERENCES habit(id)
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_habitlog_habitId ON habit_log(habitId)');
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_habitlog_date ON habit_log(date)');

    // 收藏类型表（内置+自定义）
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS collection_type (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        label TEXT NOT NULL,
        isBuiltIn INTEGER DEFAULT 1,
        sortOrder INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL
      )
    `);
    await this.seedCollectionTypes();

    // 收集表（统一抽象）
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        extra TEXT,
        tag TEXT,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_collection_type ON collection(type)');

    // 备忘录表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS memo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);

    // 创建备忘录表索引
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_memo_createTime ON memo(createTime)');
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

  /**
   * 种入内置收藏类型（不存在才插入，防止重复）
   */
  private async seedCollectionTypes(): Promise<void> {
    const store = this.getRdbStore();
    interface BuiltInType { name: string; label: string; sortOrder: number; }
    const builtIn: BuiltInType[] = [
      { name: 'sentence', label: '句子', sortOrder: 1 },
      { name: 'word', label: '词语', sortOrder: 2 },
      { name: 'quote', label: '台词', sortOrder: 3 },
      { name: 'knowledge', label: '知识点', sortOrder: 4 },
    ];
    const now = Date.now();
    for (const t of builtIn) {
      try {
        await store.executeSql(
          `INSERT OR IGNORE INTO collection_type (name, label, isBuiltIn, sortOrder, createTime)
           VALUES (?, ?, 1, ?, ?)`,
          [t.name, t.label, t.sortOrder, now]
        );
      } catch (e) {
        // 表已存在时忽略
      }
    }
  }
}
