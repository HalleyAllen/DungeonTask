/**
 * 任务编辑页
 */
import { router, routerParams } from '@kit.ArkUI';
import { Task } from 'core.model';
import { TaskViewModel } from '../viewmodel/TaskViewModel';
import { DateUtil } from 'core.util';

@Entry
@Component
struct TaskEdit {
  @State title: string = '';
  @State content: string = '';
  @State date: string = DateUtil.getToday();
  @State isEdit: boolean = false;
  @State taskId: number = 0;

  private viewModel: TaskViewModel = new TaskViewModel();

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.isEdit = true;
      this.taskId = params.id;
      this.loadTask();
    }
  }

  async loadTask() {
    const task = await this.viewModel.getTaskById(this.taskId);
    if (task) {
      this.title = task.title;
      this.content = task.content;
      this.date = task.date;
    }
  }

  async save() {
    if (!this.title.trim()) {
      return;
    }

    if (this.isEdit) {
      const task = await this.viewModel.getTaskById(this.taskId);
      if (task) {
        task.title = this.title;
        task.content = this.content;
        task.date = this.date;
        await this.viewModel.updateTask(task);
      }
    } else {
      await this.viewModel.addTask(this.title, this.content, this.date);
    }

    router.back();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => router.back())

        Blank()

        Text(this.isEdit ? '编辑任务' : '新增任务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('保存')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => this.save())
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 表单
      Column() {
        Text('标题')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入任务标题', text: this.title })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.title = value;
          })

        Text('日期')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextInput({ placeholder: 'YYYY-MM-DD', text: this.date })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.date = value;
          })

        Text('内容')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextArea({ placeholder: '请输入任务内容（可选）', text: this.content })
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.content = value;
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
