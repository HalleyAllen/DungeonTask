/**
 * 页面管理 - 排序与显隐控制
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { SettingsViewModel, PageConfig } from '../viewmodel/SettingsViewModel';

@HMRouter({ pageUrl: 'PageManagePage' })
@Component
export struct PageManagePage {
  private vm: SettingsViewModel = new SettingsViewModel();
  @State pageConfigs: PageConfig[] = [];

  async aboutToAppear(): Promise<void> {
    await this.vm.loadPageConfig(getContext(this));
    this.pageConfigs = this.vm.pageConfigs;
  }

  build() {
    Column() {
      // 顶部导航栏
      this.titleBar()

      // 说明文字
      Text('拖拽排序前四个功能页面，关闭的页面将不在导航栏显示')
        .fontSize(13)
        .fontColor('#999999')
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })

      // 页面列表
      Scroll() {
        Column() {
          ForEach(this.pageConfigs, (config: PageConfig, index: number) => {
            this.pageRow(config, index)
          })

          Column().height(24)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  titleBar() {
    Row() {
      Row() {
        Text('‹')
          .fontSize(26)
          .fontColor('#1890FF')
          .margin({ right: 4 })

        Text('返回')
          .fontSize(16)
          .fontColor('#1890FF')
      }
      .onClick(() => HMRouterMgr.pop())

      Blank()

      Text('页面管理')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      Blank()

      Row().width(60)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  pageRow(config: PageConfig, index: number) {
    Column() {
      Row() {
        // 拖拽图标示意
        Text('☰')
          .fontSize(16)
          .fontColor('#CCCCCC')
          .margin({ right: 12 })

        // 排序按钮
        Column() {
          Button('▲')
            .fontSize(12)
            .width(32)
            .height(24)
            .fontColor(index === 0 ? '#CCCCCC' : '#999999')
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .enabled(index > 0)
            .onClick(() => {
              this.vm.movePageUp(getContext(this), index);
              this.pageConfigs = this.vm.pageConfigs;
            })

          Button('▼')
            .fontSize(12)
            .width(32)
            .height(24)
            .fontColor(index === this.pageConfigs.length - 1 ? '#CCCCCC' : '#999999')
            .backgroundColor('#F5F5F5')
            .borderRadius(4)
            .enabled(index < this.pageConfigs.length - 1)
            .onClick(() => {
              this.vm.movePageDown(getContext(this), index);
              this.pageConfigs = this.vm.pageConfigs;
            })
        }
        .margin({ right: 12 })

        // 页面名称 + 图标提示
        Text(config.label)
          .fontSize(16)
          .fontColor(config.visible ? '#333333' : '#CCCCCC')
          .layoutWeight(1)

        // 显示开关
        Toggle({ type: ToggleType.Switch, isOn: config.visible })
          .onChange((isOn: boolean) => {
            this.vm.togglePageVisible(getContext(this), index);
            this.pageConfigs = this.vm.pageConfigs;
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')

      // 分割线
      if (index < this.pageConfigs.length - 1) {
        Divider()
          .strokeWidth(0.5)
          .color('#F0F0F0')
          .margin({ left: 16 })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}
