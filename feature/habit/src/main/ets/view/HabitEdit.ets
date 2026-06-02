/**
 * 习惯编辑页（通用抽象：支持组数/次数/时长等结构化目标）
 */
import { router } from '@kit.ArkUI';
import { HabitEditViewModel } from '../viewmodel/HabitEditViewModel';

// @Entry
@Component
export struct HabitEdit {
  @State vm: HabitEditViewModel = new HabitEditViewModel();

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => router.back())

        Blank()

        Text('新增习惯')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('保存')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(async () => {
            const ok = await this.vm.save();
            if (ok) router.back();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column() {
          // 图标
          Text('图标')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            ForEach(['🏃', '📚', '🧘', '💧', '✍️', '🎸', '⭐', '💪', '🌱', '🎯'], (emoji: string) => {
              Text(emoji)
                .fontSize(28)
                .padding(8)
                .backgroundColor(this.vm.icon === emoji ? '#E6F7FF' : '#F5F5F5')
                .borderRadius(8)
                .margin({ right: 8 })
                .onClick(() => { this.vm.icon = emoji; })
            })
          }
          .width('100%')

          // 习惯名称
          Text('习惯名称')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          TextInput({ placeholder: '如：晨跑、阅读、冥想', text: this.vm.name })
            .width('100%')
            .height(48)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .onChange((value: string) => { this.vm.name = value; })

          // 分类
          Text('分类')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          Row() {
            ForEach(this.vm.categoryOptions, (cat: string) => {
              Text(cat)
                .fontSize(14)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor(this.vm.category === cat ? this.vm.getCategoryColor(cat) : '#E8E8E8')
                .fontColor(this.vm.category === cat ? '#FFFFFF' : '#333333')
                .borderRadius(16)
                .margin({ right: 8 })
                .onClick(() => { this.vm.category = cat; })
            })
          }
          .width('100%')

          // 频率
          Text('频率')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ top: 24, bottom: 8 })

          Row() {
            Button('每天')
              .fontSize(14)
              .fontColor(this.vm.frequency === 1 ? '#FFFFFF' : '#333333')
              .backgroundColor(this.vm.frequency === 1 ? '#1890FF' : '#E8E8E8')
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .onClick(() => { this.vm.frequency = 1; })

            Button('每周指定日')
              .fontSize(14)
              .fontColor(this.vm.frequency === 2 ? '#FFFFFF' : '#333333')
              .backgroundColor(this.vm.frequency === 2 ? '#1890FF' : '#E8E8E8')
              .borderRadius(8)
              .padding({ left: 20, right: 20, top: 10, bottom: 10 })
              .margin({ left: 8 })
              .onClick(() => { this.vm.frequency = 2; })
          }
          .width('100%')

          // 每周指定日选择
          if (this.vm.frequency === 2) {
            Row() {
              ForEach(['一', '二', '三', '四', '五', '六', '日'], (day: string, index: number) => {
                Text(day)
                  .fontSize(14)
                  .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                  .backgroundColor(this.vm.weekDays[index] ? '#1890FF' : '#E8E8E8')
                  .fontColor(this.vm.weekDays[index] ? '#FFFFFF' : '#333333')
                  .borderRadius(16)
                  .margin({ left: index === 0 ? 0 : 4 })
                  .onClick(() => {
                    this.vm.weekDays[index] = !this.vm.weekDays[index];
                  })
              })
            }
            .width('100%')
            .margin({ top: 12 })
          }

          Divider().margin({ top: 24, bottom: 24 })

          // 量化的目标设定
          Text('目标量化（可选）')
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .margin({ bottom: 4 })

          Text(this.vm.targetSummary)
            .fontSize(12)
            .fontColor('#999999')
            .width('100%')
            .margin({ bottom: 16 })

          // 组数 + 次数（运动类）
          Text('组数 × 次数（如俯卧撑、深蹲）')
            .fontSize(13)
            .fontColor('#999999')
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            Column() {
              Text('组数')
                .fontSize(12)
                .fontColor('#999999')
              Row() {
                Button('-')
                  .fontSize(18)
                  .width(36)
                  .height(36)
                  .borderRadius(4)
                  .onClick(() => { if (this.vm.targetSets > 0) this.vm.targetSets--; })
                Text(this.vm.targetSets.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .width(48)
                  .textAlign(TextAlign.Center)
                Button('+')
                  .fontSize(18)
                  .width(36)
                  .height(36)
                  .borderRadius(4)
                  .onClick(() => { this.vm.targetSets++; })
              }
            }
            .alignItems(HorizontalAlign.Center)

            Text('×')
              .fontSize(18)
              .fontColor('#999999')
              .margin({ left: 12, right: 12 })

            Column() {
              Text('次数')
                .fontSize(12)
                .fontColor('#999999')
              Row() {
                Button('-')
                  .fontSize(18)
                  .width(36)
                  .height(36)
                  .borderRadius(4)
                  .onClick(() => { if (this.vm.targetReps > 0) this.vm.targetReps--; })
                Text(this.vm.targetReps.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .width(48)
                  .textAlign(TextAlign.Center)
                Button('+')
                  .fontSize(18)
                  .width(36)
                  .height(36)
                  .borderRadius(4)
                  .onClick(() => { this.vm.targetReps++; })
              }
            }
            .alignItems(HorizontalAlign.Center)
          }

          Divider().margin({ top: 24, bottom: 24 })

          // 时长（阅读/冥想类）
          Text('时长（分钟）')
            .fontSize(13)
            .fontColor('#999999')
            .width('100%')
            .margin({ bottom: 8 })

          Row() {
            Button('-10')
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(4)
              .onClick(() => { this.vm.targetDuration = Math.max(0, this.vm.targetDuration - 10); })

            Button('-5')
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(4)
              .margin({ left: 4 })
              .onClick(() => { this.vm.targetDuration = Math.max(0, this.vm.targetDuration - 5); })

            Button('-1')
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(4)
              .margin({ left: 4 })
              .onClick(() => { if (this.vm.targetDuration > 0) this.vm.targetDuration--; })

            Text(`${this.vm.targetDuration} 分钟`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ left: 16, right: 16 })

            Button('+1')
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(4)
              .onClick(() => { this.vm.targetDuration++; })

            Button('+5')
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(4)
              .margin({ left: 4 })
              .onClick(() => { this.vm.targetDuration += 5; })

            Button('+10')
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .borderRadius(4)
              .margin({ left: 4 })
              .onClick(() => { this.vm.targetDuration += 10; })
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
