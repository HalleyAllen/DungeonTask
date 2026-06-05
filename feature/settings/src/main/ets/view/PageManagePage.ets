/**
 * 页面管理 - 排序与显隐控制
 * 长按 ☰ 手柄拖动排序
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { SettingsViewModel, PageConfig } from '../viewmodel/SettingsViewModel';

const ITEM_HEIGHT: number = 56;

@HMRouter({ pageUrl: 'PageManagePage' })
@Component
export struct PageManagePage {
  private vm: SettingsViewModel = new SettingsViewModel();
  @State pageConfigs: PageConfig[] = [];
  /** 当前被拖拽项的 key，空串表示无拖拽 */
  @State dragKey: string = '';
  /** 拖拽累计 Y 偏移（视觉用） */
  @State dragOffY: number = 0;
  /** 拖拽累计位移，用于计算换位阈值 */
  private accPanY: number = 0;
  /** 上次 PanGesture 的 offsetY，用于计算增量 */
  private lastOffY: number = 0;

  async aboutToAppear(): Promise<void> {
    await this.vm.loadPageConfig(getContext(this));
    this.pageConfigs = [...this.vm.pageConfigs];
  }

  build() {
    Column() {
      this.titleBar()

      Text('长按 ☰ 拖动排序，关闭的页面将不在导航栏显示')
        .fontSize(13)
        .fontColor('#A6A6A6')
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })

      Scroll() {
        Column() {
          ForEach(this.pageConfigs, (config: PageConfig, index: number) => {
            this.pageRow(config, index)
          }, (config: PageConfig): string => config.key)
        }
        .width('100%')
        .constraintSize({ minHeight: '100%', maxHeight: Infinity })
        .justifyContent(FlexAlign.Start)
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
          .fontColor('#1677FF')
          .margin({ right: 4 })
        Text('返回')
          .fontSize(16)
          .fontColor('#1677FF')
      }
      .onClick(() => HMRouterMgr.pop())

      Blank()

      Text('页面管理')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F1F1F')

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
        // 拖拽手柄：长按触发拖拽
        Row() {
          Text('☰')
            .fontSize(18)
            .fontColor(this.dragKey === config.key ? '#1677FF' : '#D9D9D9')
        }
        .width(36)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .hitTestBehavior(HitTestMode.Block)
        .gesture(
          GestureGroup(GestureMode.Sequence,
            LongPressGesture({ duration: 250, repeat: false })
              .onAction(() => {
                this.dragKey = config.key;
                this.accPanY = 0;
                this.dragOffY = 0;
                this.lastOffY = 0;
              }),
            PanGesture({ direction: PanDirection.Vertical, distance: 5 })
              .onActionUpdate((event: GestureEvent) => {
                if (this.dragKey === '') {
                  return;
                }
                // 计算本次回调的增量（offsetY 是累计值）
                const delta = event.offsetY - this.lastOffY;
                this.lastOffY = event.offsetY;
                this.accPanY += delta;
                this.dragOffY = this.accPanY;

                // 超过一行高度就换位
                const steps = Math.round(this.accPanY / ITEM_HEIGHT);
                if (steps !== 0) {
                  this.pageConfigs = this.vm.movePageBySteps(config.key, steps);
                  this.accPanY -= steps * ITEM_HEIGHT;
                  this.dragOffY = this.accPanY;
                }
              })
              .onActionEnd(() => {
                if (this.dragKey !== '') {
                  this.vm.commitPageOrder(getContext(this));
                }
                this.dragKey = '';
                this.dragOffY = 0;
                this.accPanY = 0;
                this.lastOffY = 0;
              })
              .onActionCancel(() => {
                this.dragKey = '';
                this.dragOffY = 0;
                this.accPanY = 0;
                this.lastOffY = 0;
              })
          )
        )
        .margin({ right: 8 })

        // 页面名称
        Text(config.label)
          .fontSize(16)
          .fontColor(config.visible ? '#1F1F1F' : '#D9D9D9')
          .layoutWeight(1)

        // 显示开关
        Toggle({ type: ToggleType.Switch, isOn: config.visible })
          .onChange((isOn: boolean) => {
            this.vm.togglePageVisible(getContext(this), index);
            this.pageConfigs = [...this.vm.pageConfigs];
          })
      }
      .width('100%')
      .height(ITEM_HEIGHT)
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor(
        this.dragKey === config.key ? '#E6F4FF' : '#FFFFFF'
      )
      .offset({ y: this.dragKey === config.key ? this.dragOffY : 0 })
      .zIndex(this.dragKey === config.key ? 10 : 0)
      .shadow(
        this.dragKey === config.key
          ? { radius: 8, color: '#00000020', offsetY: 2 }
          : { radius: 0 }
      )
      .animation({ duration: 100 })

      // 分割线
      if (index < this.pageConfigs.length - 1) {
        Divider()
          .strokeWidth(0.5)
          .color('#F0F0F0')
          .margin({ left: 16 })
      }
    }
    .width('100%')
  }

}
