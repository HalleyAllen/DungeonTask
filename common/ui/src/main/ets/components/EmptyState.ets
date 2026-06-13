/**
 * 空状态组件
 */
@Component
export struct EmptyState {
  @Prop message: string = '暂无数据';
  @Prop icon: string = '📋';

  build() {
    Column() {
      Text(this.icon)
        .fontSize(48)
        .margin({ bottom: 16 });
      
      Text(this.message)
        .fontSize(16)
        .fontColor('#A6A6A6')
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
