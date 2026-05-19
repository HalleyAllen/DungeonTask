# DungeonTask 功能设计文档

> 版本：v1.1
> 创建日期：2026-05-19
> 更新时间：2026-05-19
> 参考项目：CoolMallArkTS（MVVM + 模块化架构）
> 对应需求文档：requirements.md

---

## 一、产品概述

DungeonTask 是一款面向 HarmonyOS 平台的日常记录与自我管理应用，帮助用户记录工作任务、管理健身计划、收集有趣句子和词语、追踪目标进度（支持树形层级支线）、随手记录想法。

### 核心模块

| 模块 | 核心功能 |
|------|----------|
| 任务清单 | 按日期记录每日工作，打卡完成 |
| 健身计划 | 设置周期性健身计划，打卡训练 |
| 句子收集 | 记录有意思的句子，快速浏览 |
| 词语收集 | 记录词语+拼音+释义，快速浏览 |
| 目标/愿望清单 | 设置短/长期目标，支持树形层级支线（最多5层），自动计算父目标进度 |
| 备忘录 | 快速记录临时想法，支持搜索 |

---

## 二、技术栈选型

| 技术项 | 选型 | 说明 |
|--------|------|------|
| 开发平台 | HarmonyOS SDK 6.0.2 | - |
| 开发语言 | ArkTS | - |
| UI 框架 | ArkUI | 声明式 UI |
| 架构模式 | MVVM | View + ViewModel + Model（参考 CoolMallArkTS） |
| 导航框架 | Navigation | 路由与页面导航管理 |
| 状态管理 | AppStorageV2 + @State | 应用级状态 + 页面状态 |
| 数据库 | IBest-ORM | 简化数据库操作（参考 CoolMallArkTS） |
| 文件导出 | @ohos.file.fs + @ohos.file.picker | - |
| 应用包名 | com.example.dungeontask | - |

---

## 三、总体架构设计

### 3.1 分层架构

采用 **MVVM + 模块化架构**（参考 CoolMallArkTS）：

```
┌─────────────────────────────────────────────────────────────┐
│                     entry（应用入口）                        │
├─────────────────────────────────────────────────────────────┤
│                     core（核心基础设施）                      │
│  ┌─────────┬─────────┬─────────┬─────────┬─────────┐       │
│  │  base   │  model  │   ui    │  util   │database │       │
│  │ (基类)  │ (数据模型)│(组件库) │(工具类) │ (数据库) │       │
│  └─────────┴─────────┴─────────┴─────────┴─────────┘       │
├─────────────────────────────────────────────────────────────┤
│                   feature（功能业务模块）                     │
│  ┌────────┬────────┬────────┬────────┬────────┬────────┐  │
│  │  task  │ fitness│ sentence│  word  │  goal  │  memo  │  │
│  └────────┴────────┴────────┴────────┴────────┴────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 MVVM 架构

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────┐
│    View     │ ←─→ │   ViewModel     │ ←─→ │    Model    │
│   (页面UI)   │     │  (状态/逻辑)    │     │   (数据)    │
└─────────────┘     └─────────────────┘     └─────────────┘
```

- **View（视图层）**：页面 UI，使用 @Component 装饰器
- **ViewModel（视图模型层）**：处理业务逻辑、状态管理、数据绑定
- **Model（模型层）**：数据模型定义、数据库操作

---

## 四、目录结构设计

### 4.1 整体目录

```
DungeonTask/
├── AppScope/                      # 应用配置
├── entry/                        # 应用入口模块
│   └── src/main/ets/
│       ├── entryability/          # 应用入口
│       └── MainAbility.ets        # 主Ability
├── core/                          # 核心基础设施（HAR）
│   ├── base/                      # 基础模块
│   │   ├── Index.ets
│   │   └── src/main/ets/
│   │       └── constants/         # 常量定义
│   ├── model/                     # 数据模型
│   │   ├── Index.ets
│   │   └── src/main/ets/
│   │       └── entity/            # 业务实体
│   ├── database/                  # 数据库层
│   │   ├── Index.ets
│   │   └── src/main/ets/
│   │       └── DbHelper.ets       # 数据库助手
│   ├── ui/                        # 通用UI组件
│   │   ├── Index.ets
│   │   └── src/main/ets/
│   │       └── components/        # 通用组件
│   ├── util/                      # 工具类
│   │   ├── Index.ets
│   │   └── src/main/ets/
│   │       ├── ExportUtil.ets     # 导出工具
│   │       └── DateUtil.ets       # 日期工具
│   └── navigation/                # 导航配置
│       └── Index.ets
└── feature/                       # 功能业务模块
    ├── task/                      # 任务模块
    ├── fitness/                   # 健身模块
    ├── sentence/                  # 句子模块
    ├── word/                      # 词语模块
    ├── goal/                      # 目标模块
    └── memo/                      # 备忘录模块
```

### 4.2 功能模块结构（每个模块相同）

以 `feature/task` 为例：

```
feature/task/
├── Index.ets                      # 模块入口
├── build-profile.json5
├── oh-package.json5
└── src/main/ets/
    ├── view/                      # 视图层
    │   ├── TaskPage.ets           # 任务列表页
    │   └── TaskEdit.ets           # 任务编辑页
    ├── viewmodel/                 # 视图模型层
    │   ├── TaskViewModel.ets      # 任务视图模型
    │   └── TaskEditViewModel.ets  # 任务编辑视图模型
    ├── model/                     # 模型层
    │   └── TaskModel.ets          # 任务数据操作
    ├── component/                 # 组件
    │   └── TaskItem.ets           # 任务列表项组件
    └── navigation/                # 路由配置
        └── TaskRouter.ets         # 任务模块路由
```

### 4.3 各功能模块详情

#### 任务模块 feature/task

```
feature/task/src/main/ets/
├── view/
│   ├── TaskPage.ets              # 任务列表页（支持日期筛选）
│   └── TaskEdit.ets              # 任务编辑/新增页
├── viewmodel/
│   ├── TaskViewModel.ets         # 任务列表状态管理
│   └── TaskEditViewModel.ets     # 编辑页状态管理
├── model/
│   └── TaskModel.ets             # 数据库操作
├── component/
│   ├── TaskItem.ets              # 任务列表项
│   ├── TaskFilterBar.ets         # 筛选栏
│   └── EmptyState.ets            # 空状态组件
└── navigation/
    └── TaskRouter.ets            # 路由配置
```

#### 健身模块 feature/fitness

```
feature/fitness/src/main/ets/
├── view/
│   ├── FitnessPage.ets           # 健身计划列表+日历视图
│   └── FitnessEdit.ets           # 计划编辑/新增页
├── viewmodel/
│   ├── FitnessViewModel.ets
│   └── FitnessEditViewModel.ets
├── model/
│   ├── FitnessPlanModel.ets      # 健身计划数据操作
│   └── FitnessCheckinModel.ets   # 健身打卡数据操作
├── component/
│   ├── FitnessItem.ets           # 计划列表项
│   ├── FitnessCalendar.ets       # 日历组件
│   └── CheckinButton.ets        # 打卡按钮
└── navigation/
    └── FitnessRouter.ets
```

#### 句子模块 feature/sentence

```
feature/sentence/src/main/ets/
├── view/
│   ├── SentencePage.ets          # 句子列表页
│   └── SentenceEdit.ets          # 句子编辑页
├── viewmodel/
│   ├── SentenceViewModel.ets
│   └── SentenceEditViewModel.ets
├── model/
│   └── SentenceModel.ets
├── component/
│   ├── SentenceCard.ets          # 句子卡片
│   └── SentenceList.ets          # 句子列表
└── navigation/
    └── SentenceRouter.ets
```

#### 词语模块 feature/word

```
feature/word/src/main/ets/
├── view/
│   ├── WordPage.ets              # 词语列表页
│   └── WordEdit.ets              # 词语编辑页
├── viewmodel/
│   ├── WordViewModel.ets
│   └── WordEditViewModel.ets
├── model/
│   └── WordModel.ets
├── component/
│   ├── WordItem.ets              # 词语列表项（可展开释义）
│   └── WordCard.ets              # 词语卡片
└── navigation/
    └── WordRouter.ets
```

#### 目标模块 feature/goal

```
feature/goal/src/main/ets/
├── view/
│   ├── GoalPage.ets              # 目标列表页（树形）
│   ├── GoalDetail.ets            # 目标详情页（子目标列表）
│   └── GoalEdit.ets             # 目标编辑/新增页
├── viewmodel/
│   ├── GoalViewModel.ets         # 树形数据状态管理
│   ├── GoalDetailViewModel.ets   # 详情页状态管理
│   └── GoalEditViewModel.ets
├── model/
│   └── GoalModel.ets             # 支持父子查询
├── component/
│   ├── GoalTreeItem.ets          # 树形目标项（展开/折叠）
│   ├── GoalProgressBar.ets       # 进度条组件
│   └── GoalContextMenu.ets      # 长按上下文菜单
└── navigation/
    └── GoalRouter.ets
```

#### 备忘录模块 feature/memo

```
feature/memo/src/main/ets/
├── view/
│   ├── MemoPage.ets              # 备忘录列表页（支持搜索）
│   └── MemoEdit.ets              # 备忘录编辑页
├── viewmodel/
│   ├── MemoViewModel.ets         # 支持搜索状态
│   └── MemoEditViewModel.ets
├── model/
│   └── MemoModel.ets
├── component/
│   ├── MemoItem.ets              # 备忘录列表项
│   └── MemoSearchBar.ets         # 搜索栏
└── navigation/
    └── MemoRouter.ets
```

---

## 五、数据模型设计

### 5.1 实体类定义（位于 core/model）

统一放在 `core/model/src/main/ets/entity/` 目录下：

```typescript
// core/model/src/main/ets/entity/Task.ets
export class Task {
  id: number = 0;
  title: string = '';
  content: string = '';
  date: string = '';           // YYYY-MM-DD
  completed: number = 0;      // 0=未完成 1=已完成
  createTime: number = 0;
  updateTime: number = 0;
}
```

```typescript
// core/model/src/main/ets/entity/FitnessPlan.ets
export class FitnessPlan {
  id: number = 0;
  name: string = '';
  weekDay: number = 0;         // 1-7 周一至周日
  exercises: string = '';      // JSON 训练项目数组
  createTime: number = 0;
  updateTime: number = 0;
}

// 健身打卡记录
export class FitnessCheckin {
  id: number = 0;
  planId: number = 0;
  date: string = '';           // YYYY-MM-DD
  completed: number = 0;       // 0=未完成 1=已完成
  createTime: number = 0;
}
```

```typescript
// core/model/src/main/ets/entity/Sentence.ets
export class Sentence {
  id: number = 0;
  content: string = '';
  source: string = '';         // 来源（可选）
  tag: string = '';            // 标签（可选）
  createTime: number = 0;
  updateTime: number = 0;
}
```

```typescript
// core/model/src/main/ets/entity/Word.ets
export class Word {
  id: number = 0;
  name: string = '';          // 词语名称
  pinyin: string = '';        // 拼音
  explanation: string = '';  // 释义
  createTime: number = 0;
  updateTime: number = 0;
}
```

```typescript
// core/model/src/main/ets/entity/Goal.ets
export class Goal {
  id: number = 0;
  title: string = '';
  type: number = 0;           // 1=短期 2=长期
  progress: number = 0;      // 0-100 进度百分比
  completed: number = 0;      // 0=进行中 1=已完成
  parentId: number = 0;       // 父目标ID，0=顶级
  level: number = 0;          // 层级深度 0-4（最大5层）
  sortOrder: number = 0;      // 同级排序序号
  createTime: number = 0;
  updateTime: number = 0;
}
```

```typescript
// core/model/src/main/ets/entity/Memo.ets
export class Memo {
  id: number = 0;
  content: string = '';
  createTime: number = 0;
  updateTime: number = 0;
}
```

### 5.2 数据库表结构（IBest-ORM）

使用 IBest-ORM 简化数据库操作，表结构定义在 `core/database/`：

```typescript
// core/database/src/main/ets/DbHelper.ets
import { IBestORM } from '@ibest/orm';

// 任务表
@Table('task')
export class TaskTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column()
  title: string = '';
  
  @Column()
  content: string = '';
  
  @Column({ index: true })
  date: string = '';
  
  @Column({ default: 0 })
  completed: number = 0;
  
  @Column()
  createTime: number = 0;
  
  @Column()
  updateTime: number = 0;
}

// 健身计划表
@Table('fitness_plan')
export class FitnessPlanTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column()
  name: string = '';
  
  @Column()
  weekDay: number = 0;
  
  @Column()
  exercises: string = '';
  
  @Column()
  createTime: number = 0;
  
  @Column()
  updateTime: number = 0;
}

// 健身打卡表
@Table('fitness_checkin')
export class FitnessCheckinTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column({ index: true })
  planId: number = 0;
  
  @Column({ index: true })
  date: string = '';
  
  @Column({ default: 0 })
  completed: number = 0;
  
  @Column()
  createTime: number = 0;
}

// 句子表
@Table('sentence')
export class SentenceTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column()
  content: string = '';
  
  @Column()
  source: string = '';
  
  @Column()
  tag: string = '';
  
  @Column()
  createTime: number = 0;
  
  @Column()
  updateTime: number = 0;
}

// 词语表
@Table('word')
export class WordTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column()
  name: string = '';
  
  @Column()
  pinyin: string = '';
  
  @Column()
  explanation: string = '';
  
  @Column()
  createTime: number = 0;
  
  @Column()
  updateTime: number = 0;
}

// 目标表（支持树形层级）
@Table('goal')
export class GoalTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column()
  title: string = '';
  
  @Column({ index: true })
  type: number = 0;
  
  @Column({ default: 0 })
  progress: number = 0;
  
  @Column({ default: 0 })
  completed: number = 0;
  
  @Column({ index: true })
  parentId: number = 0;
  
  @Column({ default: 0 })
  level: number = 0;
  
  @Column({ default: 0 })
  sortOrder: number = 0;
  
  @Column()
  createTime: number = 0;
  
  @Column()
  updateTime: number = 0;
}

// 备忘录表
@Table('memo')
export class MemoTable {
  @Column({ primaryKey: true, autoIncrement: true })
  id: number = 0;
  
  @Column()
  content: string = '';
  
  @Column({ index: true })
  createTime: number = 0;
  
  @Column()
  updateTime: number = 0;
}
```

---

## 六、ViewModel 设计

### 6.1 ViewModel 基类（可选）

位于 `core/base/src/main/ets/`，提供通用能力：

```typescript
// BaseViewModel.ets
export class BaseViewModel {
  // 加载状态
  @StorageV2.State isLoading: boolean = false;
  
  // 错误信息
  @StorageV2.State errorMessage: string = '';
  
  // 显示加载中
  showLoading(): void {
    this.isLoading = true;
  }
  
  // 隐藏加载中
  hideLoading(): void {
    this.isLoading = false;
  }
  
  // 显示错误
  showError(message: string): void {
    this.errorMessage = message;
  }
}
```

### 6.2 各模块 ViewModel 示例

#### 任务模块 TaskViewModel

```typescript
// feature/task/src/main/ets/viewmodel/TaskViewModel.ets
import { BaseViewModel } from '@ohos.base';
import { TaskModel } from '../model/TaskModel';
import { Task } from '@core/model';

export class TaskViewModel extends BaseViewModel {
  // 任务列表
  @State taskList: Task[] = [];
  
  // 当前筛选日期
  @State currentDate: string = '';
  
  private taskModel: TaskModel = new TaskModel();
  
  // 加载任务列表
  async loadTasks(date?: string): Promise<void> {
    this.showLoading();
    try {
      this.taskList = await this.taskModel.queryByDate(date);
    } catch (e) {
      this.showError('加载失败');
    } finally {
      this.hideLoading();
    }
  }
  
  // 新增任务
  async addTask(task: Task): Promise<void> {
    await this.taskModel.insert(task);
    await this.loadTasks(this.currentDate);
  }
  
  // 切换完成状态
  async toggleComplete(task: Task): Promise<void> {
    task.completed = task.completed === 1 ? 0 : 1;
    await this.taskModel.update(task);
    await this.loadTasks(this.currentDate);
  }
  
  // 删除任务
  async deleteTask(id: number): Promise<void> {
    await this.taskModel.delete(id);
    await this.loadTasks(this.currentDate);
  }
}
```

#### 目标模块 GoalViewModel（支持树形）

```typescript
// feature/goal/src/main/ets/viewmodel/GoalViewModel.ets
export class GoalViewModel extends BaseViewModel {
  // 顶级目标列表
  @State topLevelGoals: Goal[] = [];
  
  // 展开状态 Map
  @State expandedMap: Map<number, boolean> = new Map();
  
  // 分类筛选
  @State filterType: 'all' | 'active' | 'completed' = 'all';
  
  private goalModel: GoalModel = new GoalModel();
  
  // 最大层级常量
  readonly MAX_LEVEL = 4;
  
  // 加载顶级目标
  async loadGoals(): Promise<void> {
    this.showLoading();
    try {
      this.topLevelGoals = await this.goalModel.queryTopLevel(this.filterType);
      // 初始化展开状态
      this.topLevelGoals.forEach(g => {
        this.expandedMap.set(g.id, false);
      });
    } catch (e) {
      this.showError('加载失败');
    } finally {
      this.hideLoading();
    }
  }
  
  // 获取子目标
  async getChildren(parentId: number): Promise<Goal[]> {
    return await this.goalModel.queryByParentId(parentId);
  }
  
  // 切换展开状态
  toggleExpand(goalId: number): void {
    const current = this.expandedMap.get(goalId) ?? false;
    this.expandedMap.set(goalId, !current);
  }
  
  // 判断是否可添加子目标
  canAddChild(level: number): boolean {
    return level < this.MAX_LEVEL;
  }
  
  // 添加子目标
  async addChildGoal(parentId: number, title: string): Promise<void> {
    const parent = await this.goalModel.queryById(parentId);
    if (parent.level >= this.MAX_LEVEL) {
      this.showError('已达到最大层级');
      return;
    }
    const newGoal = new Goal();
    newGoal.title = title;
    newGoal.parentId = parentId;
    newGoal.level = parent.level + 1;
    await this.goalModel.insert(newGoal);
    // 更新父目标进度（平均值）
    await this.goalModel.updateParentProgress(parentId);
    await this.loadGoals();
  }
  
  // 更新目标进度
  async updateProgress(goal: Goal, progress: number): Promise<void> {
    goal.progress = progress;
    // 如果进度100%，标记完成
    if (progress >= 100) {
      goal.completed = 1;
    }
    await this.goalModel.update(goal);
    // 递归更新父目标
    await this.goalModel.updateParentProgressRecursive(goal.parentId);
    await this.loadGoals();
  }
}
```

---

## 七、页面结构设计

### 7.1 导航架构

使用 HarmonyOS Navigation 组件，参考 CoolMallArkTS 的导航设计：

```
App Navigation
├── entry: MainAbility
│   └── MainTabs (底部Tab容器)
│       ├── Tab1: 任务 (TaskPage)
│       ├── Tab2: 健身 (FitnessPage)
│       ├── Tab3: 句子 (SentencePage)
│       ├── Tab4: 词语 (WordPage)
│       ├── Tab5: 目标 (GoalPage)
│       └── Tab6: 备忘录 (MemoPage)
│
└── 各模块子页面跳转
    ├── TaskPage → TaskEdit
    ├── FitnessPage → FitnessEdit
    ├── SentencePage → SentenceEdit
    ├── WordPage → WordEdit
    ├── GoalPage → GoalDetail → GoalEdit
    └── MemoPage → MemoEdit
```

### 7.2 底部 Tab 设计

| Tab | 图标 | 标题 | 默认页 |
|-----|------|------|--------|
| 1 | calendar | 任务 | TaskPage |
| 2 | fitness | 健身 | FitnessPage |
| 3 | chat | 句子 | SentencePage |
| 4 | book | 词语 | WordPage |
| 5 | target | 目标 | GoalPage |
| 6 | note | 备忘录 | MemoPage |

### 7.3 各模块页面布局

#### 任务列表页 TaskPage

```
┌────────────────────────────────┐
│ 任务清单                    ⋮  │  ← 标题 + 更多菜单（导出）
├────────────────────────────────┤
│ [全部] [今日] [本周]           │  ← 日期筛选栏
├────────────────────────────────┤
│ ☐ 任务标题1          05-19 ✓  │
│ ☐ 任务标题2          05-19    │
│ ☑ 任务标题3(划线)    05-18 ✓  │
│                                │
│      （任务列表）               │
│                                │
├────────────────────────────────┤
│           ＋                    │  ← 悬浮新增按钮
└────────────────────────────────┘
```

#### 目标列表页 GoalPage（树形）

```
┌────────────────────────────────┐
│ 目标清单               [全部▼] │  ← 标题 + 分类筛选
├────────────────────────────────┤
│ ▼ 做炒青菜           100% ████│  ← 顶级目标（可展开）
│   └─ 买菜           100% ████│      （缩进 + 子目标）
│      ├─ 青菜           ✓     │
│      ├─ 蒜头           ✓     │
│      └─ 油盐           ✓     │
│   └─ 洗菜            50% ██░░│
│      ├─ 第一步         ✓     │
│      └─ 第二步          ○     │
├────────────────────────────────┤
│           ＋                    │
└────────────────────────────────┘
```

---

## 八、数据导出设计

### 8.1 导出格式

采用 JSON 格式，便于后续导入功能扩展：

```json
{
  "exportTime": "2026-05-19T10:00:00Z",
  "version": "1.0",
  "appName": "DungeonTask",
  "data": {
    "tasks": [...],
    "fitnessPlans": [...],
    "fitnessCheckins": [...],
    "sentences": [...],
    "words": [...],
    "goals": [...],
    "memos": [...]
  }
}
```

### 8.2 ExportUtil 设计

```typescript
// core/util/src/main/ets/ExportUtil.ets
export class ExportUtil {
  // 导出所有数据
  static async exportAll(context: Context): Promise<void>;
  
  // 导出单个模块
  static async exportModule(context: Context, moduleName: string): Promise<void>;
  
  // 生成 JSON 文件
  private static generateJSON(data: ExportData): string;
  
  // 保存到文件
  private static async saveToFile(context: Context, json: string): Promise<string>;
}
```

---

## 九、存储方案设计

### 9.1 存储分层

| 存储类型 | 技术方案 | 存储内容 |
|----------|----------|----------|
| 结构化数据 | IBest-ORM (RDB) | 任务、健身、句子、词语、目标、备忘录 |
| 轻量配置 | AppStorage | 主题、语言、用户偏好 |
| 文件存储 | @ohos.file.fs | 导出文件 |

### 9.2 数据库初始化

```typescript
// core/database/src/main/ets/DbHelper.ets
import { IBestORM } from '@ibest/orm';

export class DbHelper {
  private static instance: DbHelper;
  private db: IBestORM;
  
  static getInstance(): DbHelper;
  
  async init(context: Context): Promise<void>;
  
  getDatabase(): IBestORM;
}
```

---

## 十、实施计划

### Phase 1: 基础设施搭建
1. 创建 core 模块（model, database, util, base, ui）
2. 配置 IBest-ORM 数据库
3. 实现基础组件库

### Phase 2: 核心模块开发
1. 任务模块（完整 CRUD + 日期筛选）
2. 健身模块（计划 + 打卡）
3. 句子模块（列表 + 增删改查）
4. 词语模块（列表 + 增删改查）

### Phase 3: 高级模块开发
1. 目标模块（树形层级 + 进度计算）
2. 备忘录模块（搜索功能）

### Phase 4: 功能完善
1. 数据导出功能
2. 主页面 Tab 导航集成
3. UI 优化与适配

---

## 十一、后续迭代规划

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 搜索功能 | P1 | 各模块关键词搜索 |
| 标签/分类 | P2 | 为内容添加标签 |
| 主题切换 | P2 | 浅色/深色模式 |
| 数据导入 | P2 | 从 JSON 恢复数据 |
| 习惯打卡 | P3 | 通用习惯养成 |
| 桌面小组件 | P3 | widget 快速查看 |
| 打卡激励 | P4 | 连续打卡徽章 |

---

*文档结束*
