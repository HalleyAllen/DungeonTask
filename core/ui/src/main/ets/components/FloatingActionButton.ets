/**
 * 悬浮操作按钮 - 遵循 Ant Design 5.x 规范
 * 主色 #1677FF，圆角阴影，固定右下角（基于 position 实现，不干扰触摸事件）
 */
@Component
export struct FloatingActionButton {
  /** 点击回调 */
  clickFun?: () => void;

  build() {
    Button() {
      Text('＋')
        .fontSize(24)
        .fontWeight(FontWeight.Regular)
        .fontColor('#FFFFFF')
    }
    .position({ right: 24, bottom: 32 })
    .width(48)
    .height(48)
    .backgroundColor('#1677FF')
    .borderRadius(24)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.15)',
      offsetX: 0,
      offsetY: 6
    })
    .onClick(() => {
      if (this.clickFun) {
        this.clickFun();
      }
    })
  }
}
