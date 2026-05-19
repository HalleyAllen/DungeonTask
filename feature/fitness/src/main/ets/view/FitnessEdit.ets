/**
 * 健身计划编辑页
 */
import { router } from '@kit.ArkUI';
import { FitnessPlan } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';

@Entry
@Component
struct FitnessEdit {
  @State name: string = '';
  @State weekDay: number = 1;
  @State exercises: string = '';

  async save() {
    if (!this.name.trim()) return;

    try {
      const store = DbHelper.getInstance().getRdbStore();
      const valueBucket: relationalStore.ValuesBucket = {
        name: this.name,
        weekDay: this.weekDay,
        exercises: this.exercises,
        createTime: DateUtil.getNow(),
        updateTime: DateUtil.getNow()
      };
      await store.insert('fitness_plan', valueBucket);
      router.back();
    } catch (e) {
      console.error('Save fitness plan failed:', e);
    }
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => router.back())

        Blank()

        Text('新增健身计划')
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

      Column() {
        Text('计划名称')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '如：周一胸肌训练', text: this.name })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.name = value;
          })

        Text('安排在')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        Row() {
          ForEach([1, 2, 3, 4, 5, 6, 7], (day: number) => {
            Text(DateUtil.getWeekDayName(day).substring(1))
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor(this.weekDay === day ? '#1890FF' : '#E8E8E8')
              .fontColor(this.weekDay === day ? '#FFFFFF' : '#333333')
              .borderRadius(16)
              .margin({ left: day === 1 ? 0 : 4 })
              .onClick(() => {
                this.weekDay = day;
              })
          })
        }
        .width('100%')

        Text('训练项目')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextArea({ placeholder: '请输入训练项目（每行一个）', text: this.exercises })
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.exercises = value;
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
