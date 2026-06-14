# DungeonTask 数据库设计文档

> 版本：v1.0  
> 创建日期：2026-05-23  
> 数据库：SQLite（通过 IBest-ORM 操作）  
> 对应需求：requirements.md

---

## 表概览

| 序号 | 表名 | 模块 | 说明 |
|------|------|------|------|
| 1 | task | 任务清单 | 每日任务记录，支持层级拆分 |
| 2 | habit | 习惯管理 | 通用习惯模板（健身/阅读/冥想…） |
| 3 | habit_log | 习惯打卡 | 每日打卡记录 |
| 4 | collection_type | 收藏类型 | 收藏类型定义（内置 + 用户自定义） |
| 5 | collection | 收集收藏 | 统一收藏（句子/词语/台词/知识点…） |
| 6 | memo | 备忘录 | 临时想法记录 |

---

## 1. task（任务表 · 支持层级拆分）

| 字段 | 类型 | 约束 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | - | 主键自增 |
| title | TEXT | NOT NULL | '' | 任务标题 |
| content | TEXT | - | '' | 任务内容/备注 |
| date | TEXT | NOT NULL INDEX | '' | 日期 YYYY-MM-DD |
| completed | INTEGER | - | 0 | 0=未完成 1=已完成 |
| priority | INTEGER | NOT NULL | 0 | 排序优先级，数值越大越靠前，默认0 |
| parentId | INTEGER | NOT NULL INDEX | 0 | 父任务ID，0=顶级任务 |
| level | INTEGER | NOT NULL | 0 | 层级深度 0-4（限制5层） |
| sortOrder | INTEGER | - | 0 | 同级排序序号 |
| createTime | INTEGER | NOT NULL | 0 | 创建时间戳 |
| updateTime | INTEGER | NOT NULL | 0 | 更新时间戳 |

**索引**：`idx_task_date` ON `(date)`, `idx_task_parentId` ON `(parentId)`

**排序规则**：
- `priority` 字段控制列表从上到下的显示顺序（数值越大越靠前）
- 通过拖拽排序（⬆/⬇）调整顺序，自动重算 priority 并持久化

**层级规则**：
- `parentId=0` → 顶级任务（如"吃饭"）
- `parentId=X` → X 的子任务（如"买菜"是"吃饭"的子任务）
- `level` 范围 0-4，超出拒绝添加
- 父任务 completed = 所有子任务均完成时为 1（自动计算）

**示例**：
```
▼ 吃饭 (已完成)
  ├─ 1. 买菜 ✓
  ├─ 2. 洗菜 ✓
  └─ 3. 做饭 ✓
```

---

## 2. habit（习惯模板表 · 通用抽象）

| 字段 | 类型 | 约束 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | - | 主键自增 |
| name | TEXT | NOT NULL | '' | 习惯名称（如"晨跑"、"阅读"） |
| category | TEXT | NOT NULL INDEX | '' | 分类标签：运动/学习/健康/生活… |
| frequency | INTEGER | NOT NULL | 1 | 频率：1=每天 2=每周指定日 |
| weekDays | TEXT | - | '' | 每周哪几天，如"1,3,5"（周一三五），frequency=2 时有效 |
| targetSets | INTEGER | - | 0 | 目标组数（运动类习惯） |
| targetReps | INTEGER | - | 0 | 每组目标次数（运动类习惯） |
| targetDuration | INTEGER | - | 0 | 目标时长·分钟（阅读/冥想类习惯） |
| icon | TEXT | - | '' | 图标/emoji |
| color | TEXT | - | '' | 主题色 #HEX |
| sortOrder | INTEGER | - | 0 | 排序序号 |
| createTime | INTEGER | NOT NULL | 0 | 创建时间戳 |
| updateTime | INTEGER | NOT NULL | 0 | 更新时间戳 |

**索引**：`idx_habit_category` ON `(category)`

**结构化目标示例**：
```
运动习惯：targetSets=3, targetReps=15  →  解读为"3组×15次"
阅读习惯：targetDuration=30           →  解读为"30分钟"
冥想习惯：targetDuration=20           →  解读为"20分钟"
任意习惯：三类字段均可为0，表示无具体量化目标
```

**category 示例**：
```
运动 ─ 晨跑、俯卧撑、瑜伽
学习 ─ 阅读、背单词、练字
健康 ─ 喝水、冥想、早睡
生活 ─ 记账、整理、浇花
```

---

## 3. habit_log（习惯打卡表）

| 字段 | 类型 | 约束 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | - | 主键自增 |
| habitId | INTEGER | NOT NULL INDEX | 0 | 关联 habit.id |
| date | TEXT | NOT NULL INDEX | '' | 打卡日期 YYYY-MM-DD |
| completed | INTEGER | - | 0 | 0=未完成 1=已完成 |
| actualSets | INTEGER | - | 0 | 实际完成组数 |
| actualReps | INTEGER | - | 0 | 实际每组次数 |
| actualDuration | INTEGER | - | 0 | 实际时长（分钟） |
| note | TEXT | - | '' | 备注（当天感受） |
| createTime | INTEGER | NOT NULL | 0 | 创建时间戳 |

**索引**：`idx_habitlog_habitId` ON `(habitId)`, `idx_habitlog_date` ON `(date)`

**打卡数据流**：
```
habit.target*=3,15       ← 模板定义目标（3组×15）
        ↓ 打卡时录入
habit_log.actual*=3,12   ← 当天实际（3组×12，第3组没做完）
```

---

## 4. collection_type（收藏类型表 · 内置+自定义）

| 字段 | 类型 | 约束 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | - | 主键自增 |
| name | TEXT | NOT NULL UNIQUE | '' | 类型标识（sentence/word/custom_xxx） |
| label | TEXT | NOT NULL | '' | 显示名称（"句子"/"歌词"...） |
| isBuiltIn | INTEGER | - | 1 | 1=内置类型 0=用户自定义 |
| sortOrder | INTEGER | - | 0 | 排序序号 |
| createTime | INTEGER | NOT NULL | 0 | 创建时间戳 |

**内置类型**（首次建库自动种入）：
```
句子     sentence
词语     word
台词     quote
知识点   knowledge
```

**自定义类型**：用户在编辑页点"＋ 新建类型"，输入名称即可创建，存为 `custom_<时间戳>`。

---

## 5. collection（收集表 · 统一抽象）

| 字段 | 类型 | 约束 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | - | 主键自增 |
| type | TEXT | NOT NULL INDEX | '' | 关联 collection_type.name |
| title | TEXT | NOT NULL | '' | 标题（词语名 / 句子首句） |
| content | TEXT | - | '' | 主体内容（句子全文 / 释义…） |
| extra | TEXT | - | '' | 扩展字段 JSON（拼音、出处等类型特有信息） |
| tag | TEXT | - | '' | 标签（逗号分隔） |
| createTime | INTEGER | NOT NULL | 0 | 创建时间戳 |
| updateTime | INTEGER | NOT NULL | 0 | 更新时间戳 |

**索引**：`idx_collection_type` ON `(type)`

**extra JSON 示例**：

内置 type=word 时：
```json
{"pinyin": "qióng", "explanation": "美玉，泛指精美的事物"}
```

内置 type=sentence/quote 时：
```json
{"source": "《百年孤独》", "author": "马尔克斯"}
```

内置 knowledge 或自定义类型时：
```json
{"desc": "关于……的一段描述"}
```

**type 分类示例**：
```
句子     ─ 书摘、台词、名言…（内置）
词语     ─ 生僻字、成语、外语…（内置）
知识点   ─ 一句话知识点…     （内置）
歌词     ─ 酷狗收藏…         （自定义）
代码片段 ─ 常用模板…         （自定义）
```

---

## 6. memo（备忘录表）

| 字段 | 类型 | 约束 | 默认值 | 说明 |
|------|------|------|--------|------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | - | 主键自增 |
| content | TEXT | NOT NULL | '' | 备忘录内容 |
| createTime | INTEGER | NOT NULL INDEX | 0 | 创建时间戳（倒序排列） |
| updateTime | INTEGER | NOT NULL | 0 | 更新时间戳 |

**索引**：`idx_memo_createTime` ON `(createTime)` — 按时间倒序浏览

---

## SQL 建表语句

```sql
-- 任务表（支持层级拆分）
CREATE TABLE IF NOT EXISTS task (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL DEFAULT '',
  content TEXT DEFAULT '',
  date TEXT NOT NULL DEFAULT '',
  completed INTEGER DEFAULT 0,
  priority INTEGER NOT NULL DEFAULT 0,
  parentId INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 0,
  sortOrder INTEGER DEFAULT 0,
  createTime INTEGER NOT NULL,
  updateTime INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_task_date ON task(date);
CREATE INDEX IF NOT EXISTS idx_task_parentId ON task(parentId);

-- 习惯模板表（通用抽象）
CREATE TABLE IF NOT EXISTS habit (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL DEFAULT '',
  category TEXT NOT NULL DEFAULT '',
  frequency INTEGER NOT NULL DEFAULT 1,
  weekDays TEXT DEFAULT '',
  targetSets INTEGER DEFAULT 0,
  targetReps INTEGER DEFAULT 0,
  targetDuration INTEGER DEFAULT 0,
  icon TEXT DEFAULT '',
  color TEXT DEFAULT '',
  sortOrder INTEGER DEFAULT 0,
  createTime INTEGER NOT NULL,
  updateTime INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_habit_category ON habit(category);

-- 习惯打卡表
CREATE TABLE IF NOT EXISTS habit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habitId INTEGER NOT NULL DEFAULT 0,
  date TEXT NOT NULL DEFAULT '',
  completed INTEGER DEFAULT 0,
  actualSets INTEGER DEFAULT 0,
  actualReps INTEGER DEFAULT 0,
  actualDuration INTEGER DEFAULT 0,
  note TEXT DEFAULT '',
  createTime INTEGER NOT NULL,
  FOREIGN KEY (habitId) REFERENCES habit(id)
);
CREATE INDEX IF NOT EXISTS idx_habitlog_habitId ON habit_log(habitId);
CREATE INDEX IF NOT EXISTS idx_habitlog_date ON habit_log(date);

-- 收藏类型表（内置+自定义）
CREATE TABLE IF NOT EXISTS collection_type (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE DEFAULT '',
  label TEXT NOT NULL DEFAULT '',
  isBuiltIn INTEGER DEFAULT 1,
  sortOrder INTEGER DEFAULT 0,
  createTime INTEGER NOT NULL
);

-- 内置类型种子数据（INSERT OR IGNORE 防止重复）
INSERT OR IGNORE INTO collection_type (name, label, isBuiltIn, sortOrder, createTime)
  VALUES ('sentence', '句子', 1, 1, 0);
INSERT OR IGNORE INTO collection_type (name, label, isBuiltIn, sortOrder, createTime)
  VALUES ('word', '词语', 1, 2, 0);
INSERT OR IGNORE INTO collection_type (name, label, isBuiltIn, sortOrder, createTime)
  VALUES ('quote', '台词', 1, 3, 0);
INSERT OR IGNORE INTO collection_type (name, label, isBuiltIn, sortOrder, createTime)
  VALUES ('knowledge', '知识点', 1, 4, 0);

-- 收集表（统一抽象）
CREATE TABLE IF NOT EXISTS collection (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL DEFAULT '',
  title TEXT NOT NULL DEFAULT '',
  content TEXT DEFAULT '',
  extra TEXT DEFAULT '',
  tag TEXT DEFAULT '',
  createTime INTEGER NOT NULL,
  updateTime INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_collection_type ON collection(type);

-- 备忘录表
CREATE TABLE IF NOT EXISTS memo (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  content TEXT NOT NULL DEFAULT '',
  createTime INTEGER NOT NULL,
  updateTime INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_memo_createTime ON memo(createTime);
```

---

## 通用字段说明

| 字段 | 说明 |
|------|------|
| id | 自增主键，唯一标识 |
| createTime | 记录创建时间，Unix 时间戳（毫秒） |
| updateTime | 记录最后更新时间，Unix 时间戳（毫秒） |
| TEXT 类型 | SQLite 中 TEXT 可存储任意长度字符串 |

---

> 💡 **修改指南**：直接编辑上方表格中的"字段"、"类型"、"约束"列即可调整表结构。调整完成后，需同步修改 `core/database/src/main/ets/DbHelper.ets` 中的 `IBest-ORM` 表定义。
