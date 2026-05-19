/**
 * 目标详情页
 */
import { router } from '@kit.ArkUI';
import { Goal } from 'core.model';
import { GoalViewModel } from '../viewmodel/GoalViewModel';
import { EmptyState } from 'core.ui';

@Entry
@Component
struct GoalDetail {
  @State viewModel: GoalViewModel = new GoalViewModel();
  @State goalId: number = 0;
  @State goal: Goal | null = null;
  @State children: Goal[] = [];

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.goalId = params.id;
      this.loadData();
    }
  }

  async loadData() {
    this.goal = await this.viewModel.getGoalById(this.goalId);
    this.children = await this.viewModel.getChildren(this.goalId);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('←')
          .fontSize(24)
          .onClick(() => router.back())

        Blank()

        Text('目标详情')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('编辑')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/goal/GoalEdit',
              params: { id: this.goalId }
            });
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      if (this.goal) {
        // 目标信息
        Column() {
          Text(this.goal.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .width('100%')

          Row() {
            Text(this.goal.type === 1 ? '短期目标' : '长期目标')
              .fontSize(12)
              .fontColor('#666666')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#E8E8E8')
              .borderRadius(4)

            Text(this.goal.completed === 1 ? '已完成' : '进行中')
              .fontSize(12)
              .fontColor(this.goal.completed === 1 ? '#52C41A' : '#1890FF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.goal.completed === 1 ? '#F6FFED' : '#E6F7FF')
              .borderRadius(4)
              .margin({ left: 8 })
          }
          .margin({ top: 12 })

          // 进度
          if (this.children.length > 0) {
            Row() {
              Text('进度')
                .fontSize(14)
                .fontColor('#666666')
              
              Blank()
              
              Text(`${this.goal.progress}%`)
                .fontSize(14)
                .fontColor('#1890FF')
            }
            .width('100%')
            .margin({ top: 16 })

            Progress({ value: this.goal.progress, total: 100 })
              .width('100%')
              .height(8)
              .margin({ top: 8 })
              .color('#1890FF')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .margin({ top: 8 })

        // 子目标列表
        Column() {
          Row() {
            Text('子目标')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)

            Blank()

            if (this.viewModel.canAddChild(this.goal.level)) {
              Text('＋ 添加子目标')
                .fontSize(14)
                .fontColor('#1890FF')
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/goal/GoalEdit',
                    params: { parentId: this.goalId }
                  });
                })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .margin({ top: 8 })

          if (this.children.length === 0) {
            EmptyState({ message: '暂无子目标' })
              .height(200)
          } else {
            List() {
              ForEach(this.children, (child: Goal) => {
                ListItem() {
                  this.childItem(child)
                }
              })
            }
            .padding({ left: 16, right: 16 })
          }
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  childItem(child: Goal) {
    Row() {
      Text(child.completed === 1 ? '✓' : '○')
        .fontSize(16)
        .fontColor(child.completed === 1 ? '#52C41A' : '#999999')
        .width(24)

      Text(child.title)
        .fontSize(16)
        .fontColor(child.completed === 1 ? '#999999' : '#333333')
        .decoration(child.completed === 1 ? TextDecorationType.LineThrough : TextDecorationType.None)
        .layoutWeight(1)

      Text(`${child.progress}%`)
        .fontSize(12)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/goal/GoalDetail',
        params: { id: child.id }
      });
    })
  }
}
