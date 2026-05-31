/**
 * 备忘录编辑页
 */
import { router } from '@kit.ArkUI';
import { EditPageParams } from 'core.model';
import { MemoEditViewModel } from '../viewmodel/MemoEditViewModel';

@Entry
@Component
export struct MemoEdit {
  @State vm: MemoEditViewModel = new MemoEditViewModel();

  aboutToAppear() {
    const params = router.getParams() as EditPageParams;
    this.vm.init(params);
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => router.back())

        Blank()

        Text(this.vm.isEdit ? '编辑备忘录' : '新增备忘录')
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

      TextArea({ placeholder: '记录你的想法...', text: this.vm.content })
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#FFFFFF')
        .onChange((value: string) => {
          this.vm.content = value;
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
