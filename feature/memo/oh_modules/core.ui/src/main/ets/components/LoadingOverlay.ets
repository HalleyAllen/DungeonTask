/**
 * 加载遮罩组件
 */
@Component
export struct LoadingOverlay {
  @Prop isLoading: boolean = false;
  @Prop message: string = '加载中...';

  build() {
    if (this.isLoading) {
      Column() {
        LoadingProgress()
          .width(48)
          .height(48)
          .color('#1677FF');
        
        Text(this.message)
          .fontSize(14)
          .fontColor('#A6A6A6')
          .margin({ top: 16 });
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('rgba(255, 255, 255, 0.9)')
      .position({ x: 0, y: 0 })
    }
  }
}
