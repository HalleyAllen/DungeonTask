import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getORM } from '@ibestservices/ibest-orm';
import { DbHelper } from 'core.database';
import { Task, Habit, HabitLog, Collection, CollectionType, Memo } from 'core.model';
import { HMRouterMgr } from '@hadss/hmrouter';

const DOMAIN = 0x0000;

class  BuiltInTypeItem {
  name: string = "";
  label: string = "";
  sortOrder: number =0
};

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }

    HMRouterMgr.init({ context: this.context });
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'HMRouter initialized');
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化数据库
    try {
      await DbHelper.getInstance().init(this.context);
      await this.migrateAndSeed();
      hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Database initialized successfully');
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to init database: %{public}s', JSON.stringify(err));
    }

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'EntryAbility', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'Ability onBackground');
  }

  /**
   * 迁移表结构 + 种子数据（首次安装建表、升级自动加字段）
   */
  private async migrateAndSeed(): Promise<void> {
    const orm = getORM();

    // 迁移所有实体（自动处理建表/加字段）
    await orm.migrate(Task);
    await orm.migrate(Habit);
    await orm.migrate(HabitLog);
    await orm.migrate(CollectionType);
    await orm.migrate(Collection);
    await orm.migrate(Memo);

    hilog.info(DOMAIN, 'EntryAbility', '%{public}s', 'All tables migrated');

    // 种子数据：内置收藏类型
    await this.seedCollectionTypes();
  }

  /** 种入内置收藏类型（不存在才插入） */
  private async seedCollectionTypes(): Promise<void> {
    const orm = getORM();
    const now = Date.now();
    const builtIn: BuiltInTypeItem[] = [
      { name: 'sentence', label: '句子', sortOrder: 1 } as BuiltInTypeItem,
      { name: 'word', label: '词语', sortOrder: 2 }as BuiltInTypeItem,
      { name: 'quote', label: '台词', sortOrder: 3 }as BuiltInTypeItem,
      { name: 'knowledge', label: '知识点', sortOrder: 4 }as BuiltInTypeItem,
    ];

    for (const t of builtIn) {
      const existing = orm.query(CollectionType).where({ name: t.name }).find();
      if (existing.length === 0) {
        const ct = new CollectionType();
        ct.name = t.name;
        ct.label = t.label;
        ct.isBuiltIn = 1;
        ct.sortOrder = t.sortOrder;
        ct.createTime = now;
        ct.updateTime = now;
        orm.insert(ct);
      }
    }
  }
}
