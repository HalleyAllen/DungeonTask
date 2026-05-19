/**
 * 目标列表页（树形展示）
 */
import { router } from '@kit.ArkUI';
import { Goal } from 'core.model';
import { GoalViewModel, TreeNode } from '../viewmodel/GoalViewModel';
import { EmptyState } from 'core.ui';

@Entry
@Component
struct GoalPage {
  @State viewModel: GoalViewModel = new GoalViewModel();

  aboutToAppear() {
    this.viewModel.loadGoals();
  }

  build() {
    Column() {
      // 标题栏
      this.titleBar()
      
      // 筛选栏
      this.filterBar()
      
      // 目标列表
      this.goalList()
      
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
      Text('目标清单')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
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
        .backgroundColor(this.viewModel.filterType === 'all' ? '#1890FF' : '#E8E8E8')
        .fontColor(this.viewModel.filterType === 'all' ? '#FFFFFF' : '#333333')
        .borderRadius(16)
        .onClick(() => {
          this.viewModel.filterType = 'all';
          this.viewModel.loadGoals();
        })

      Text('进行中')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.viewModel.filterType === 'active' ? '#1890FF' : '#E8E8E8')
        .fontColor(this.viewModel.filterType === 'active' ? '#FFFFFF' : '#333333')
        .borderRadius(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.viewModel.filterType = 'active';
          this.viewModel.loadGoals();
        })

      Text('已完成')
        .fontSize(14)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(this.viewModel.filterType === 'completed' ? '#1890FF' : '#E8E8E8')
        .fontColor(this.viewModel.filterType === 'completed' ? '#FFFFFF' : '#333333')
        .borderRadius(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.viewModel.filterType = 'completed';
          this.viewModel.loadGoals();
        })
    }
    .width('100%')
    .padding({ left: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  goalList() {
    if (this.viewModel.treeData.length === 0) {
      EmptyState({ message: '暂无目标，点击下方按钮添加' })
    } else {
      List() {
        ForEach(this.viewModel.treeData, (node: TreeNode, index: number) => {
          ListItem() {
            this.treeItem(node, [index])
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 8 })
    }
  }

  @Builder
  treeItem(node: TreeNode, indexPath: number[]) {
    Column() {
      // 主目标行
      Row() {
        // 展开/折叠图标
        if (node.children.length > 0) {
          Text(node.node.expanded ? '▼' : '▶')
            .fontSize(12)
            .fontColor('#999999')
            .width(20)
            .onClick(() => {
              this.viewModel.toggleExpand(indexPath);
            })
        } else {
          Text('  ')
            .width(20)
        }

        // 标题
        Text(node.goal.title)
          .fontSize(16)
          .fontColor(node.goal.completed === 1 ? '#999999' : '#333333')
          .layoutWeight(1)
          .margin({ left: 4 })

        // 进度条
        if (node.children.length > 0) {
          Row() {
            Progress({ value: node.goal.progress, total: 100 })
              .width(60)
              .height(4)
              .color('#1890FF')
            
            Text(`${node.goal.progress}%`)
              .fontSize(12)
              .fontColor('#666666')
              .margin({ left: 8 })
          }
        } else {
          Text(node.goal.completed === 1 ? '✓' : '○')
            .fontSize(16)
            .fontColor(node.goal.completed === 1 ? '#52C41A' : '#999999')
        }
      }
      .width('100%')
      .padding({ top: 12, bottom: 12, left: 12, right: 12 })
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .margin({ bottom: 8 })
      .onClick(() => {
        if (node.children.length > 0) {
          this.viewModel.toggleExpand(indexPath);
        } else {
          router.pushUrl({
            url: 'pages/goal/GoalDetail',
            params: { id: node.goal.id }
          });
        }
      })
      .onLongPress(() => {
        // TODO: 显示上下文菜单
      })

      // 子目标
      if (node.node.expanded && node.children.length > 0) {
        Column() {
          ForEach(node.children, (childNode: TreeNode, childIndex: number) => {
            this.treeItem(childNode, [...indexPath, childIndex])
          })
        }
        .padding({ left: 20 })
      }
    }
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
        router.pushUrl({ url: 'pages/goal/GoalEdit' });
      })
  }
}
