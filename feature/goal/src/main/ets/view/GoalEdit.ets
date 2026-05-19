/**
 * 目标编辑页
 */
import { router } from '@kit.ArkUI';
import { Goal } from 'core.model';
import { GoalViewModel } from '../viewmodel/GoalViewModel';
import { Constants } from 'core.util';

@Entry
@Component
struct GoalEdit {
  @State title: string = '';
  @State goalType: number = Constants.GoalType.SHORT_TERM;
  @State progress: number = 0;
  @State isEdit: boolean = false;
  @State isChild: boolean = false;
  @State goalId: number = 0;
  @State parentId: number = 0;

  private viewModel: GoalViewModel = new GoalViewModel();

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params) {
      if (params.id) {
        this.isEdit = true;
        this.goalId = params.id;
        this.loadGoal();
      } else if (params.parentId) {
        this.isChild = true;
        this.parentId = params.parentId;
      }
    }
  }

  async loadGoal() {
    const goal = await this.viewModel.getGoalById(this.goalId);
    if (goal) {
      this.title = goal.title;
      this.goalType = goal.type;
      this.progress = goal.progress;
    }
  }

  async save() {
    if (!this.title.trim()) {
      return;
    }

    if (this.isEdit) {
      const goal = await this.viewModel.getGoalById(this.goalId);
      if (goal) {
        goal.title = this.title;
        goal.type = this.goalType;
        goal.progress = this.progress;
        await this.viewModel.updateGoal(goal);
      }
    } else if (this.isChild) {
      await this.viewModel.addChildGoal(this.parentId, this.title);
    } else {
      await this.viewModel.addGoal(this.title, this.goalType);
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

        Text(this.isChild ? '添加子目标' : (this.isEdit ? '编辑目标' : '新增目标'))
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
        Text('目标名称')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入目标名称', text: this.title })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.title = value;
          })

        if (!this.isChild) {
          Text('目标类型')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          Row() {
            Radio({ value: 'short', group: 'goalType' })
              .checked(this.goalType === Constants.GoalType.SHORT_TERM)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.goalType = Constants.GoalType.SHORT_TERM;
                }
              })

            Text('短期目标')
              .fontSize(14)
              .margin({ left: 8 })

            Radio({ value: 'long', group: 'goalType' })
              .checked(this.goalType === Constants.GoalType.LONG_TERM)
              .margin({ left: 24 })
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.goalType = Constants.GoalType.LONG_TERM;
                }
              })

            Text('长期目标')
              .fontSize(14)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
        }

        if (this.isEdit) {
          Text('进度')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          Row() {
            Slider({
              value: this.progress,
              min: 0,
              max: 100,
              step: 10,
              style: SliderStyle.OutSet
            })
              .layoutWeight(1)
              .onChange((value: number) => {
                this.progress = value;
              })

            Text(`${this.progress}%`)
              .fontSize(14)
              .fontColor('#333333')
              .margin({ left: 16 })
              .width(50)
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
