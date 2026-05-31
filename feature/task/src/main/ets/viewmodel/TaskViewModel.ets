/**
 * 任务列表 ViewModel
 */
import { Task, SortOrderItem } from 'core.model';
import { TaskRepository } from '../repository/TaskRepository';
import { DateUtil } from 'core.util';


@Observed
export class TaskViewModel {
  taskList: Task[] = [];
  currentDate: string = '';
  isLoading: boolean = false;
  errorMessage: string = '';

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
    const sortItems: SortOrderItem[] = tasks.map(t => ({
      id: t.id,
      sortOrder: t.sortOrder,
      priority: t.priority
    } as SortOrderItem));
    await this.taskRepository.updateSortOrders(sortItems);
    await this.loadTasks(this.currentDate);
  }
}
