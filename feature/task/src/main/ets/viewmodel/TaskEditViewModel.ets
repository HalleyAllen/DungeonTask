/**
 * 任务编辑 ViewModel
 * 管理任务编辑页的状态和业务逻辑
 */
import { Task, EditPageParams } from 'core.model';
import { TaskRepository } from '../repository/TaskRepository';
import { DateUtil } from 'core.util';

@Observed
export class TaskEditViewModel {
  title: string = '';
  content: string = '';
  date: string = DateUtil.getToday();
  isEdit: boolean = false;
  taskId: number = 0;

  private repo: TaskRepository = new TaskRepository();

  /**
   * 初始化（根据路由参数判断新增/编辑）
   */
  async init(params: EditPageParams | undefined): Promise<void> {
    if (params && params.id) {
      this.isEdit = true;
      this.taskId = params.id;
      await this.loadTask();
    }
  }

  async loadTask(): Promise<void> {
    const task = await this.repo.queryById(this.taskId);
    if (task) {
      this.title = task.title;
      this.content = task.content;
      this.date = task.date;
    }
  }

  async save(): Promise<boolean> {
    if (!this.title.trim()) return false;

    try {
      if (this.isEdit) {
        const task = await this.repo.queryById(this.taskId);
        if (task) {
          task.title = this.title;
          task.content = this.content;
          task.date = this.date;
          await this.repo.update(task);
        }
      } else {
        const task = new Task();
        task.title = this.title;
        task.content = this.content;
        task.date = this.date;
        task.createTime = DateUtil.getNow();
        task.updateTime = DateUtil.getNow();
        await this.repo.insert(task);
      }
      return true;
    } catch (e) {
      console.error('Save task failed:', e);
      return false;
    }
  }
}
