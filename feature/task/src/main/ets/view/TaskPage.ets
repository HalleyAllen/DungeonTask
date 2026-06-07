/**
 * 任务列表页
 */
import { HMRouter } from '@hadss/hmrouter';
import { Task } from 'core.model';
import { TaskViewModel } from '../viewmodel/TaskViewModel';
import { EmptyState } from 'core.ui';

@HMRouter({ pageUrl: 'TaskPage' })
@Component
export struct TaskPage {
  @State viewModel: TaskViewModel = new TaskViewModel();

  aboutToAppear() {
    this.viewModel.filterByDate('today');
    this.viewModel.loadFilterTags();
  }

  build() {
    Column() {
      this.titleBar()
      this.filterBar()
      this.taskList()
      // FAB：用绝对定位避免 Stack 层叠干扰 bindMenu
      Button() {
        Text('＋')
          .fontSize(24)
          .fontWeight(FontWeight.Regular)
          .fontColor('#FFFFFF')
      }
      .position({ right: 24, bottom: 32 })
      .width(48)
      .height(48)
      .backgroundColor('#1677FF')
      .borderRadius(24)
      .shadow({
        radius: 12,
        color: 'rgba(0, 0, 0, 0.15)',
        offsetX: 0,
        offsetY: 6
      })
      .onClick(() => {
        this.viewModel.goToEditPage();
      })
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

        Text('⚙')
          .fontSize(20)
          .fontColor('#A6A6A6')
        .width(40)
        .height(40)
        .bindMenu(this.SettingsMenuBuilder)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  filterBar() {
    List() {
      // 全部（固定第一项）
      ListItem() {
        Text('全部')
          .fontSize(14)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor(!this.viewModel.currentTag ? '#1677FF' : '#F5F5F5')
          .fontColor(!this.viewModel.currentTag ? '#FFFFFF' : '#1F1F1F')
          .borderRadius(16)
          .onClick(() => {
            this.viewModel.filterByTag('');
          })
      }

      // 标签筛选下拉
      ListItem() {
        Text('▼')
          .fontSize(10)
          .fontColor('#8C8C8C')
          .padding({ left: 8, right: 8, top: 6, bottom: 6 })
          .backgroundColor('#F5F5F5')
          .borderRadius(4)
      }
        .bindMenu(this.TagMenuBuilder)
        .margin({ left: 8 })

      ForEach(this.viewModel.filterTags, (tag: string) => {
        ListItem() {
          Text(tag)
            .fontSize(14)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.viewModel.currentTag === tag ? '#1677FF' : '#F5F5F5')
            .fontColor(this.viewModel.currentTag === tag ? '#FFFFFF' : '#1F1F1F')
            .borderRadius(16)
            .onClick(() => {
              this.viewModel.filterByTag(tag);
            })
        }
        .margin({ left: 12 })
      })
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .padding({ left: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  SettingsMenuBuilder() {
    Menu() {
      MenuItem({ content: '标签管理' })
        .onClick(() => {
          this.viewModel.goToTagManage();
        })
      MenuItem({ content: '排序' })
        .onClick(() => {
          if (!this.viewModel.isReordering) {
            this.viewModel.startReorder();
          } else {
            this.viewModel.finishReorder();
          }
        })
    }
  }

  @Builder
  TagMenuBuilder() {
    Menu() {
      ForEach(this.viewModel.filterTags, (tag: string) => {
        MenuItem({ content: tag })
          .onClick(() => {
            this.viewModel.filterByTag(tag);
          })
      })
    }
  }

  // ---- 列表 ----

  @Builder
  taskList() {
    if ((this.viewModel.isReordering ? this.viewModel.dragList : this.viewModel.taskList).length === 0) {
      EmptyState({ message: '暂无任务，点击下方按钮添加' })
    } else {
      List() {
        ForEach(this.viewModel.isReordering ? this.viewModel.dragList : this.viewModel.taskList,
          (task: Task, index: number) => {
            ListItem() {
              this.taskItem(task, index)
            }
          }, (task: Task) => task.id.toString())
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor("#f5f5f5")
      .padding({ left: 16, right: 16 })
    }
  }

  @Builder
  taskItem(task: Task, index: number) {
    Row() {
      if (this.viewModel.isReordering) {
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
                this.viewModel.moveItem(index, index - 1);
              }
            })

          Text('⬇')
            .fontSize(14)
            .fontColor(index < this.viewModel.dragList.length - 1 ? '#1677FF' : '#D9D9D9')
            .height(24)
            .width(32)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (index < this.viewModel.dragList.length - 1) {
                this.viewModel.moveItem(index, index + 1);
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

      if (!this.viewModel.isReordering) {
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
      if (!this.viewModel.isReordering) {
        this.viewModel.goToEditPage(task.id);
      }
    })
  }
}
