/**
 * 通用文本输入弹窗
 *
 * onConfirm 返回值：空字符串表示成功并关闭弹窗，非空字符串作为错误提示显示
 */
@CustomDialog
export struct TextInputDialog {
  controller: CustomDialogController;
  /** 弹窗标题，默认「请输入」 */
  title: string = '请输入';
  /** 输入框占位提示 */
  placeholder: string = '';
  /** 最大输入长度 */
  maxLength: number = 20;
  /** 输入框空值时的错误提示 */
  emptyError: string = '请输入内容';
  /** 确认回调，返回空字符串=成功关闭，返回非空=显示错误 */
  onConfirm?: (value: string) => string;
  @State inputValue: string = '';
  @State errorText: string = '';

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ top: 20, bottom: 16 })

      TextInput({ placeholder: this.placeholder, text: this.inputValue })
        .defaultFocus(true)
        .maxLength(this.maxLength)
        .width('100%')
        .height(44)
        .fontSize(16)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding({ left: 12, right: 12 })
        .onChange((value: string) => {
          this.inputValue = value;
          this.errorText = '';
        })
        .onSubmit(() => {
          this.tryConfirm();
        })

      if (this.errorText) {
        Text(this.errorText)
          .fontSize(13)
          .fontColor('#FF4D4F')
          .width('100%')
          .margin({ top: 8 })
      }

      Row() {
        Button('取消')
          .fontSize(15)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .width('45%')
          .height(40)
          .borderRadius(8)
          .onClick(() => this.controller.close())

        Button('✓ 确认')
          .fontSize(15)
          .fontColor('#FFFFFF')
          .backgroundColor('#1677FF')
          .width('45%')
          .height(40)
          .borderRadius(8)
          .onClick(() => {
            this.tryConfirm();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 16 })
    }
    .padding({ left: 20, right: 20, bottom: 20 })
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  tryConfirm(): void {
    const value = this.inputValue.trim();
    if (!value) {
      this.errorText = this.emptyError;
      return;
    }
    if (this.onConfirm) {
      const err = this.onConfirm(value);
      if (!err) {
        this.errorText = '';
        this.controller.close();
      } else {
        this.errorText = err;
      }
    } else {
      this.controller.close();
    }
  }
}
