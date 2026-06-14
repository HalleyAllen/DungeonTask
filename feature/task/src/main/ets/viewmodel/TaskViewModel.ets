/**
 * 任务列表 ViewModel
 */
import { Task, SortOrderItem } from 'core.model';
import { TaskRepository } from 'core.database';
import { DateUtil } from 'common.util';
import { HMRouterMgr } from '@hadss/hmrouter';


@Observed
export class TaskViewModel {
  taskList: Task[] = [];
  /** 筛选标签列表 */
  filterTags: string[] = ["全部"];
  /** 当前选中标签（'' 表示全部） */
  currentTag: string = '';
  /** 日期筛选：'all' | 'today' | 'week' */
  currentDateFilter: string = 'today';
  currentDate: string = '';
  isLoading: boolean = false;
  errorMessage: string = '';

  // ---- 拖拽排序 ----
  isReordering: boolean = false;
  dragList: Task[] = [];

  private taskRepository: TaskRepository = new TaskRepository();

  /**
   * 加载任务列表
   */
  async loadTasks(date?: string): Promise<void> {
    this.isLoading = true;
    this.currentDate = date || DateUtil.getToday();

    try {
      this.taskList = await this.taskRepository.queryByDate(this.currentDate);
    } catch (e) {
      this.errorMessage = '加载失败';
      console.error('Load tasks failed:', e);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 加载全部任务
   */
  async loadAllTasks(): Promise<void> {
    this.isLoading = true;
    this.currentDate = '';

    try {
      this.taskList = await this.taskRepository.queryAll();
    } catch (e) {
      this.errorMessage = '加载失败';
      console.error('Load all tasks failed:', e);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 按日期范围筛选
   */
  async filterByDate(type: string): Promise<void> {
    this.currentDateFilter = type;
    if (type === 'all') {
      await this.loadAllTasks();
    } else if (type === 'week') {
      this.isLoading = true;
      this.currentDate = '';
      try {
        this.taskList = await this.taskRepository.queryByDateRange(
          DateUtil.getWeekStart(), DateUtil.getWeekEnd()
        );
      } catch (e) {
        this.errorMessage = '加载失败';
        console.error('Load week tasks failed:', e);
      } finally {
        this.isLoading = false;
      }
    } else {
      // today
      await this.loadTasks(DateUtil.getToday());
    }
  }

  /**
   * 加载筛选标签列表
   */
  async loadFilterTags(): Promise<void> {
    try {
      this.filterTags = await this.taskRepository.queryTags();
    } catch (e) {
      console.error('Load tags failed:', e);
      this.filterTags = [];
    }
  }

  /**
   * 按标签筛选（空字符串 = 全部）
   */
  async filterByTag(tag: string): Promise<void> {
    this.currentTag = tag;
    this.isLoading = true;
    try {
      if (!tag) {
        this.taskList = await this.taskRepository.queryAll();
      } else {
        this.taskList = await this.taskRepository.queryByTag(tag);
      }
    } catch (e) {
      this.errorMessage = '加载失败';
      console.error('Filter by tag failed:', e);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 新增任务
   */
  async addTask(title: string, content?: string, date?: string): Promise<void> {
    const task = new Task();
    task.title = title;
    task.content = content || '';
    task.date = date || this.currentDate || DateUtil.getToday();
    task.createTime = DateUtil.getNow();
    task.updateTime = DateUtil.getNow();

    await this.taskRepository.insert(task);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 更新任务
   */
  async updateTask(task: Task): Promise<void> {
    await this.taskRepository.update(task);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 切换完成状态
   */
  async toggleComplete(task: Task): Promise<void> {
    task.completed = task.completed === 1 ? 0 : 1;
    await this.taskRepository.update(task);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 删除任务
   */
  async deleteTask(id: number): Promise<void> {
    await this.taskRepository.delete(id);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 按ID查询
   */
  async getTaskById(id: number): Promise<Task | null> {
    return await this.taskRepository.queryById(id);
  }

  /**
   * 保存排序结果
   */
  async saveOrder(tasks: Task[]): Promise<void> {
    const sortItems: SortOrderItem[] = tasks.map((t: Task): SortOrderItem => {
      return { id: t.id, sortOrder: t.sortOrder, priority: t.priority };
    });
    await this.taskRepository.updateSortOrders(sortItems);
    await this.loadTasks(this.currentDate);
  }

  // ---- 拖拽排序 ----

  /**
   * 深拷贝任务列表，进入排序模式
   */
  deepCopyTask(t: Task): Task {
    const copy = new Task();
    copy.id = t.id;
    copy.title = t.title;
    copy.content = t.content;
    copy.date = t.date;
    copy.completed = t.completed;
    copy.priority = t.priority;
    copy.parentId = t.parentId;
    copy.level = t.level;
    copy.sortOrder = t.sortOrder;
    copy.tag = t.tag;
    copy.createTime = t.createTime;
    copy.updateTime = t.updateTime;
    return copy;
  }

  startReorder(): void {
    this.dragList = this.taskList.map(t => this.deepCopyTask(t));
    this.isReordering = true;
  }

  /**
   * 完成排序：按数组位置分配优先级，持久化
   */
  async finishReorder(): Promise<void> {
    const count = this.dragList.length;
    for (let i: number = 0; i < count; i++) {
      this.dragList[i].priority = count - i;
    }
    await this.saveOrder(this.dragList);
    this.isReordering = false;
    this.dragList = [];
  }

  /**
   * 移动排序项
   */
  moveItem(from: number, to: number): void {
    if (from === to || from < 0 || to < 0 ||
      from >= this.dragList.length || to >= this.dragList.length) {
      return;
    }
    const item = this.dragList.splice(from, 1)[0];
    this.dragList.splice(to, 0, item);
  }

  // ---- 导航 ----

  goToEditPage(taskId?: number): void {
    if (taskId) {
      HMRouterMgr.push({ pageUrl: 'TaskEdit', param: { id: taskId } });
    } else {
      HMRouterMgr.push({ pageUrl: 'TaskEdit' });
    }
  }

  goToTagManage(): void {
    HMRouterMgr.push({ pageUrl: 'TagManage' });
  }
}
