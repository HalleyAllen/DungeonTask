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
      throw err;
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

    // 任务表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS task (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);

    // 健身计划表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS fitness_plan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        weekDay INTEGER NOT NULL,
        exercises TEXT,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);

    // 健身打卡表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS fitness_checkin (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planId INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        FOREIGN KEY (planId) REFERENCES fitness_plan(id)
      )
    `);

    // 句子表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS sentence (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        source TEXT,
        tag TEXT,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);

    // 词语表
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS word (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        pinyin TEXT NOT NULL,
        explanation TEXT NOT NULL,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);

    // 目标表（支持树形层级）
    await store.executeSql(`
      CREATE TABLE IF NOT EXISTS goal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type INTEGER NOT NULL,
        progress INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0,
        parentId INTEGER DEFAULT 0,
        level INTEGER DEFAULT 0,
        sortOrder INTEGER DEFAULT 0,
        createTime INTEGER NOT NULL,
        updateTime INTEGER NOT NULL
      )
    `);

    // 创建目标表索引
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_goal_parentId ON goal(parentId)');
    await store.executeSql('CREATE INDEX IF NOT EXISTS idx_goal_type ON goal(type)');

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
}
