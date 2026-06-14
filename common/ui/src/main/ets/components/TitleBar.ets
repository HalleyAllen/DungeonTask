/**
 * 通用标题栏组件
 *
 * 两种模式：
 * 1. 默认：标题左对齐 + 右侧自定义内容（trailing）
 *    TitleBar({ title: '任务清单' }) { /* 右侧图标等 * / }
 *
 * 2. 返回模式：左侧返回按钮 + 标题居中 + 右侧自定义内容
 *    TitleBar({ title: '标签管理', showBack: true, backLabel: '取消', backCallback: () => HMRouterMgr.pop() })
 */
@Component
export struct TitleBar {
  /** 标题文字 */
  @Prop title: string = '';

  /** 是否显示返回按钮（左侧按钮 + 标题居中） */
  @Prop showBack: boolean = false;

  /** 返回按钮文字（默认 "返回"） */
  @Prop backLabel: string = '返回';

  /** 返回按钮点击回调 */
  backCallback?: () => void;

  /** 右侧自定义内容 */
  @BuilderParam trailing: () => void = this.defaultTrailing;

  @Builder
  defaultTrailing() {
  }

  build() {
    Row() {
      if (this.showBack) {
        Text(`← ${this.backLabel}`)
          .fontSize(16)
          .fontColor('#1677FF')
          .onClick(() => {
            if (this.backCallback) {
              this.backCallback();
            }
          })

        Blank()
      }

      Text(this.title)
        .fontSize(this.showBack ? 18 : 20)
        .fontWeight(FontWeight.Bold)

      Blank()

      this.trailing()
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }
}
