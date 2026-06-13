/**
 * 数据库助手类（基于 ibest-orm）
 * ORM 生命周期由 IBestORMInit / getORM 管理
 */
import { IBestORMInit, getORM, ORM } from '@ibestservices/ibest-orm';

export class DbHelper {
  private static _instance: DbHelper | null = null;
  private _context: Context | null = null;

  private constructor() {}

  static getInstance(): DbHelper {
    if (!DbHelper._instance) {
      DbHelper._instance = new DbHelper();
    }
    return DbHelper._instance;
  }

  /** 初始化 ORM（首次安装建库，后续打开已有库） */
  async init(context: Context): Promise<void> {
    this._context = context;
    await IBestORMInit(context, {
      name: 'DungeonTask.db',
      debug: true
    });
  }

  /** 获取 ORM 实例（首次调用须在 init 之后） */
  getORM(): ORM {
    return getORM();
  }
}
