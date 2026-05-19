/**
 * 任务列表页
 */
import { router } from '@kit.ArkUI';
import { Task } from 'core.model';
import { TaskViewModel } from '../viewmodel/TaskViewModel';
import { EmptyState } from 'core.ui';
import { DateUtil } from 'core.util';

@Entry
@Component
struct TaskPage {
  @State viewModel: TaskViewModel = new TaskViewModel();
  @State currentTab: string = 'today';

  aboutToAppear() {
    this.viewModel.loadTasks();
  }

  build() {
    Column() {
      // 标题栏
      this.titleBar()
      
      // 筛选栏
      this.filterBar()
      
      // 任务列表
      this.taskList()
      
      // 悬浮按钮
      this.fab()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  titleBar() {
    Row() {
      Text('任务清单')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      
      Blank()
      
      Text('⋮')
        .fontSize(24)
        .onClick(() => {
          // 更多菜单（导出）
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  filterBar() {
    Row() {
      Text('全部')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.currentTab === 'all' ? '#1890FF' : '#E8E8E8')
        .fontColor(this.currentTab === 'all' ? '#FFFFFF' : '#333333')
        .borderRadius(16)
        .onClick(() => {
          this.currentTab = 'all';
          this.viewModel.loadAllTasks();
        })

      Text('今日')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.currentTab === 'today' ? '#1890FF' : '#E8E8E8')
        .fontColor(this.currentTab === 'today' ? '#FFFFFF' : '#333333')
        .borderRadius(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.currentTab = 'today';
          this.viewModel.loadTasks();
        })

      Text('本周')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.currentTab === 'week' ? '#1890FF' : '#E8E8E8')
        .fontColor(this.currentTab === 'week' ? '#FFFFFF' : '#333333')
        .borderRadius(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.currentTab = 'week';
          // TODO: 本周筛选
          this.viewModel.loadTasks();
        })
    }
    .width('100%')
    .padding({ left: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  taskList() {
    if (this.viewModel.taskList.length === 0) {
      EmptyState({ message: '暂无任务，点击下方按钮添加' })
    } else {
      List() {
        ForEach(this.viewModel.taskList, (task: Task) => {
          ListItem() {
            this.taskItem(task)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  taskItem(task: Task) {
    Row() {
      // 复选框
      Checkbox()
        .select(task.completed === 1)
        .selectedColor('#1890FF')
        .onChange((value: boolean) => {
          this.viewModel.toggleComplete(task);
        })

      Column() {
        Text(task.title)
          .fontSize(16)
          .fontColor(task.completed === 1 ? '#999999' : '#333333')
          .decoration(task.completed === 1 ? TextDecorationType.LineThrough : TextDecorationType.None)

        Text(task.date)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      // 删除按钮
      Text('🗑️')
        .fontSize(18)
        .onClick(() => {
          this.viewModel.deleteTask(task.id);
        })
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 12, right: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/task/TaskEdit',
        params: { id: task.id }
      });
    })
  }

  @Builder
  fab() {
    Button('＋')
      .width(56)
      .height(56)
      .fontSize(28)
      .fontColor('#FFFFFF')
      .backgroundColor('#1890FF')
      .borderRadius(28)
      .shadow({
        radius: 8,
        color: 'rgba(24, 144, 255, 0.3)',
        offsetX: 0,
        offsetY: 4
      })
      .position({ x: '85%', y: '80%' })
      .onClick(() => {
        router.pushUrl({ url: 'pages/task/TaskEdit' });
      })
  }
}
