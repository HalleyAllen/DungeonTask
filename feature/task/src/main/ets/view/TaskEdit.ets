/**
 * 任务编辑页
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { EditPageParams } from 'core.model';
import { TaskEditViewModel } from '../viewmodel/TaskEditViewModel';

@HMRouter({ pageUrl: 'TaskEdit' })
@Component
export struct TaskEdit {
  @State vm: TaskEditViewModel = new TaskEditViewModel();

  aboutToAppear() {
    const params = HMRouterMgr.getCurrentParam() as EditPageParams;
    this.vm.init(params);
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#1677FF')
          .onClick(() => HMRouterMgr.pop())

        Blank()

        Text(this.vm.isEdit ? '编辑任务' : '新增任务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('保存')
          .fontSize(16)
          .fontColor('#1677FF')
          .onClick(async () => {
            const ok = await this.vm.save();
            if (ok) HMRouterMgr.pop();
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 表单
      Column() {
        Text('标题')
          .fontSize(14)
          .fontColor('#A6A6A6')
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入任务标题', text: this.vm.title })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.vm.title = value;
          })

        Text('日期')
          .fontSize(14)
          .fontColor('#A6A6A6')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextInput({ placeholder: 'YYYY-MM-DD', text: this.vm.date })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.vm.date = value;
          })

        Text('内容')
          .fontSize(14)
          .fontColor('#A6A6A6')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextArea({ placeholder: '请输入任务内容（可选）', text: this.vm.content })
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.vm.content = value;
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
