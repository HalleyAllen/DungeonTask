/**
 * 任务列表页
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { Task } from 'core.model';
import { TaskViewModel } from '../viewmodel/TaskViewModel';
import { EmptyState, FloatingActionButton } from 'core.ui';
import { DateUtil } from 'core.util';

@HMRouter({ pageUrl: 'TaskPage' })
@Component
export struct TaskPage {
  @State viewModel: TaskViewModel = new TaskViewModel();
  @State currentTab: string = 'today';
  @State isReordering: boolean = false;
  // 拖拽过程中的临时列表
  @State dragList: Task[] = [];
  @State dragFrom: number = -1;
  @State dragTo: number = -1;

  aboutToAppear() {
    this.viewModel.loadTasks();
  }

  build() {
    Stack() {
      Column() {
        this.titleBar()
        this.filterBar()
        this.taskList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      FloatingActionButton({
        clickFun: () => {
          HMRouterMgr.push({ pageUrl: 'TaskEdit' });
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  titleBar() {
    Row() {
      Text('任务清单')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Blank()

      if (this.isReordering) {
        Text('完成')
          .fontSize(15)
          .fontColor('#1677FF')
          .onClick(() => {
            this.finishReorder();
          })
      } else {
        Text('排序')
          .fontSize(15)
          .fontColor('#1677FF')
          .margin({ right: 12 })
          .onClick(() => {
            this.startReorder();
          })
      }
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
        .backgroundColor(this.currentTab === 'all' ? '#1677FF' : '#F5F5F5')
        .fontColor(this.currentTab === 'all' ? '#FFFFFF' : '#1F1F1F')
        .borderRadius(16)
        .onClick(() => {
          this.currentTab = 'all';
          this.viewModel.loadAllTasks();
        })

      Text('今日')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.currentTab === 'today' ? '#1677FF' : '#F5F5F5')
        .fontColor(this.currentTab === 'today' ? '#FFFFFF' : '#1F1F1F')
        .borderRadius(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.currentTab = 'today';
          this.viewModel.loadTasks();
        })

      Text('本周')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.currentTab === 'week' ? '#1677FF' : '#F5F5F5')
        .fontColor(this.currentTab === 'week' ? '#FFFFFF' : '#1F1F1F')
        .borderRadius(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.currentTab = 'week';
          this.viewModel.loadTasks();
        })
    }
    .width('100%')
    .padding({ left: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  // ---- 拖拽排序 ----

  startReorder() {
    // 深拷贝当前列表用于拖拽操作
    this.dragList = this.viewModel.taskList.map(t => {
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
      copy.createTime = t.createTime;
      copy.updateTime = t.updateTime;
      return copy;
    });
    this.isReordering = true;
  }

  async finishReorder() {
    // 将最终顺序持久化：按数组位置分配 priority
    const count = this.dragList.length;
    for (let i = 0; i < count; i++) {
      this.dragList[i].priority = count - i; // 第0位 priority最高
    }
    await this.viewModel.saveOrder(this.dragList);
    this.isReordering = false;
    this.dragList = [];
  }

  moveItem(from: number, to: number) {
    if (from === to || from < 0 || to < 0 ||
      from >= this.dragList.length || to >= this.dragList.length) {
      return;
    }
    const item = this.dragList.splice(from, 1)[0];
    this.dragList.splice(to, 0, item);
  }

  // ---- 列表 ----

  @Builder
  taskList() {
    if ((this.isReordering ? this.dragList : this.viewModel.taskList).length === 0) {
      EmptyState({ message: '暂无任务，点击下方按钮添加' })
    } else {
      List() {
        ForEach(this.isReordering ? this.dragList : this.viewModel.taskList,
          (task: Task, index: number) => {
            ListItem() {
              this.taskItem(task, index)
            }
          }, (task: Task) => task.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  taskItem(task: Task, index: number) {
    Row() {
      if (this.isReordering) {
        // 拖拽手柄 + 上/下移动按钮
        Column() {
          Text('⬆')
            .fontSize(14)
            .fontColor(index > 0 ? '#1677FF' : '#D9D9D9')
            .height(24)
            .width(32)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (index > 0) {
                this.moveItem(index, index - 1);
              }
            })

          Text('⬇')
            .fontSize(14)
            .fontColor(index < this.dragList.length - 1 ? '#1677FF' : '#D9D9D9')
            .height(24)
            .width(32)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (index < this.dragList.length - 1) {
                this.moveItem(index, index + 1);
              }
            })
        }
        .margin({ right: 8 })
      } else {
        // 正常模式：复选框
        Checkbox()
          .select(task.completed === 1)
          .selectedColor('#1677FF')
          .onChange((value: boolean) => {
            this.viewModel.toggleComplete(task);
          })
      }

      Column() {
        Text(task.title)
          .fontSize(16)
          .fontColor(task.completed === 1 ? '#A6A6A6' : '#1F1F1F')
          // .decoration(task.completed === 1 ? TextDecorationType.LineThrough : TextDecorationType.None)

        Text(task.date)
          .fontSize(12)
          .fontColor('#A6A6A6')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)

      if (!this.isReordering) {
        Text('🗑️')
          .fontSize(18)
          .onClick(() => {
            this.viewModel.deleteTask(task.id);
          })
      }
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 12, right: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      if (!this.isReordering) {
        HMRouterMgr.push({
          pageUrl: 'TaskEdit',
          param: { id: task.id }
        });
      }
    })
  }
}
