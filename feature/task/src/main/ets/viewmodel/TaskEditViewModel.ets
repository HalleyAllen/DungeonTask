/**
 * 任务编辑 ViewModel
 * 管理任务编辑页的状态和业务逻辑
 */
import { Task, EditPageParams } from 'core.model';
import { TaskRepository, TagRepository } from 'core.database';
import { DateUtil } from 'common.util';

@Observed
export class TaskEditViewModel {
  title: string = '';
  content: string = '';
  date: string = DateUtil.getToday();
  tag: string = '';
  isEdit: boolean = false;
  taskId: number = 0;
  /** 可选标签列表（从已持久化的 Tag 表加载） */
  tagOptions: string[] = [];

  private repo: TaskRepository = new TaskRepository();
  private tagRepo: TagRepository = new TagRepository();

  /**
   * 初始化（根据路由参数判断新增/编辑）
   */
  async init(params: EditPageParams | undefined): Promise<void> {
    await this.loadTagOptions();
    if (params && params.id) {
      this.isEdit = true;
      this.taskId = params.id;
      await this.loadTask();
    }
  }

  async loadTagOptions(): Promise<void> {
    try {
      this.tagOptions = await this.tagRepo.queryAllNames();
    } catch (e) {
      this.tagOptions = [];
    }
  }

  async loadTask(): Promise<void> {
    const task: Task | null = await this.repo.queryById(this.taskId);
    if (task) {
      this.title = task.title;
      this.content = task.content;
      this.date = task.date;
      this.tag = task.tag;
    }
  }

  /** 标签点击切换（多选，逗号分隔） */
  toggleTag(tagName: string): void {
    const tags = this.tag ? this.tag.split(',').map((s: string) => s.trim()).filter((s: string) => s.length > 0) : [];
    const idx = tags.indexOf(tagName);
    if (idx >= 0) {
      tags.splice(idx, 1);
    } else {
      tags.push(tagName);
    }
    this.tag = tags.join(',');
  }

  isTagSelected(tagName: string): boolean {
    if (!this.tag) return false;
    return this.tag.split(',').map((s: string) => s.trim()).includes(tagName);
  }

  async save(): Promise<boolean> {
    if (!this.title.trim()) return false;

    try {
      if (this.isEdit) {
        const task: Task | null = await this.repo.queryById(this.taskId);
        if (task) {
          task.title = this.title;
          task.content = this.content;
          task.date = this.date;
          task.tag = this.tag;
          await this.repo.update(task);
        }
      } else {
        const task = new Task();
        task.title = this.title;
        task.content = this.content;
        task.date = this.date;
        task.tag = this.tag;
        await this.repo.insert(task);
      }
      return true;
    } catch (e) {
      console.error('Save task failed:', e);
      return false;
    }
  }
}
