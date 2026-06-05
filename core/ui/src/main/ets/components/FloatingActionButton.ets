/**
 * 悬浮操作按钮 - 固定在右下角
 */
@Component
export struct FloatingActionButton {
  /** 点击回调 */
  clickFun?: () => void;

  build() {
    Column() {
      Blank()
      Text('＋')
        .width(48)
        .height(48)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .backgroundColor('#1890FF')
        .borderRadius(24)
        .textAlign(TextAlign.Center)
        .margin({ right: 16, bottom: 16 })
        .alignSelf(ItemAlign.End)
        .shadow({
          radius: 8,
          color: 'rgba(24, 144, 255, 0.3)',
          offsetX: 0,
          offsetY: 4
        })
        .onClick(() => {
          if (this.clickFun) {
            this.clickFun();
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}
