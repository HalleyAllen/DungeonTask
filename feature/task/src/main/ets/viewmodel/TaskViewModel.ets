/**
 * 任务列表 ViewModel
 */
import { Task } from 'core.model';
import { TaskModel } from '../model/TaskModel';
import { DateUtil } from 'core.util';

export class TaskViewModel {
  @State taskList: Task[] = [];
  @State currentDate: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  private taskModel: TaskModel = new TaskModel();

  /**
   * 加载任务列表
   */
  async loadTasks(date?: string): Promise<void> {
    this.isLoading = true;
    this.currentDate = date || DateUtil.getToday();
    
    try {
      this.taskList = await this.taskModel.queryByDate(this.currentDate);
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
      this.taskList = await this.taskModel.queryAll();
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
    
    await this.taskModel.insert(task);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 更新任务
   */
  async updateTask(task: Task): Promise<void> {
    await this.taskModel.update(task);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 切换完成状态
   */
  async toggleComplete(task: Task): Promise<void> {
    task.completed = task.completed === 1 ? 0 : 1;
    await this.taskModel.update(task);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 删除任务
   */
  async deleteTask(id: number): Promise<void> {
    await this.taskModel.delete(id);
    await this.loadTasks(this.currentDate);
  }

  /**
   * 按ID查询
   */
  async getTaskById(id: number): Promise<Task | null> {
    return await this.taskModel.queryById(id);
  }
}
