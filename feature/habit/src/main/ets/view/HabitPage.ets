/**
 * 习惯管理列表页（通用抽象：健身房/阅读/冥想… + 结构化打卡）
 */
import { router } from '@kit.ArkUI';
import { HMRouter } from '@hadss/hmrouter';
import { Habit, HabitLog } from 'core.model';
import { DateUtil } from 'core.util';
import { EmptyState, FloatingActionButton } from 'core.ui';
import { HabitPageViewModel } from '../viewmodel/HabitPageViewModel';

@HMRouter({ pageUrl: 'HabitPage' })
@Component
export struct HabitPage {
  @State vm: HabitPageViewModel = new HabitPageViewModel();

  aboutToAppear() {
    this.vm.loadHabits();
  }

  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          Text('习惯')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')

        // 今日打卡
        Column() {
          Row() {
            Text('今日打卡')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
            Text(DateUtil.getWeekDayName(DateUtil.getTodayWeekDay()))
              .fontSize(14)
              .fontColor('#666666')
              .margin({ left: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')

          if (this.vm.todayHabits.length === 0) {
            EmptyState({ message: '今天没有需要打卡的习惯', icon: '🔄' })
              .height(120)
          } else {
            List() {
              ForEach(this.vm.todayHabits, (habit: Habit) => {
                ListItem() { this.habitItem(habit, true) }
              })
            }
            .padding({ left: 16, right: 16 })
          }
        }
        .margin({ top: 8 })

        // 全部习惯（按分类分组）
        Column() {
          Text('全部习惯')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')

          if (this.vm.habits.length === 0) {
            EmptyState({ message: '还没有习惯，点击下方添加', icon: '⭐' })
              .height(200)
          } else {
            List() {
              ForEach(this.vm.categories, (cat: string) => {
                ListItem() {
                  Column() {
                    Text(cat)
                      .fontSize(14)
                      .fontColor('#999999')
                      .padding({ left: 16, top: 12, bottom: 4 })
                      .width('100%')
                  }
                }

                ForEach(this.vm.habits.filter(h => h.category === cat), (habit: Habit) => {
                  ListItem() { this.habitItem(habit, false) }
                })
              })
            }
            .padding({ left: 16, right: 16 })
          }
        }
        .layoutWeight(1)
        .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      FloatingActionButton({
        clickFun: () => {
          router.pushUrl({ url: 'pages/habit/HabitEdit' });
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  habitItem(habit: Habit, showCheckin: boolean) {
    Row() {
      Column() {
        Text(`${habit.icon || '⭐'} ${habit.name}`)
          .fontSize(16)
          .fontColor('#333333')

        Row() {
          Text(habit.category || '未分类')
            .fontSize(11)
            .fontColor('#FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor(habit.color || '#999999')
            .borderRadius(4)

          // 目标摘要
          if (this.vm.targetText(habit)) {
            Text(`🎯 ${this.vm.targetText(habit)}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 6 })
          }

          if (habit.frequency === 2 && habit.weekDays) {
            Text(`· 周${this.vm.weekDayNames(habit.weekDays)}`)
              .fontSize(12)
              .fontColor('#999999')
              .margin({ left: 6 })
          }
        }
        .margin({ top: 4 })

        // 今日打卡详情（实际值）
        if (showCheckin) {
          if (this.vm.todayLogs.get(habit.id)) {
            Text(`✅ ${this.vm.actualText(this.vm.todayLogs.get(habit.id)!)}`)
              .fontSize(12)
              .fontColor('#52C41A')
              .margin({ top: 4 })
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (showCheckin) {
        Button((this.vm.todayChecked.get(habit.id) ?? false) ? '✓ 已打卡' : '打卡')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor((this.vm.todayChecked.get(habit.id) ?? false) ? '#8C8C8C' : '#52C41A')
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => this.vm.toggleCheckin(habit))
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }
}
