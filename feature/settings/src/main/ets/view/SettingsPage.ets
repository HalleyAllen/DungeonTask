/**
 * 设置页面
 * 提供数据管理、版本信息等功能
 */
import { promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { HMRouterMgr } from '@hadss/hmrouter';
import { SettingsViewModel, SettingsSection, SettingsItem } from '../viewmodel/SettingsViewModel';

// @Entry
@Component
export struct SettingsPage {
  @State vm: SettingsViewModel = new SettingsViewModel();
  @State showSyncCodeDialog: boolean = false;
  @State showImportDialog: boolean = false;
  @State showClearDialog: boolean = false;
  @State importCode: string = '';
  @State clearConfirmText: string = '';

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        this.headerBar()

        // 主体滚动区域
        Scroll() {
          Column() {
            // 应用信息卡片
            this.appInfoCard()

            // 设置项列表
            ForEach(this.vm.getSettingsSections(), (section: SettingsSection) => {
              this.sectionGroup(section)
            })

            // 底部留白
            Column().height(32)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .height('100%')

      // 同步码弹窗
      if (this.showSyncCodeDialog) {
        this.syncCodeDialog()
      }

      // 导入同步码弹窗
      if (this.showImportDialog) {
        this.importDialog()
      }

      // 清除确认弹窗
      if (this.showClearDialog) {
        this.clearDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  headerBar() {
    Row() {
      Text('设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  appInfoCard() {
    Column() {
      Text('🏰')
        .fontSize(48)
        .margin({ bottom: 12 })

      Text('DungeonTask')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 6 })

      Text('日常记录与自我管理')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .padding({ top: 32, bottom: 32 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ top: 12, left: 16, right: 16 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  sectionGroup(section: SettingsSection) {
    Column() {
      // Section 标题
      Text(section.title)
        .fontSize(13)
        .fontColor('#999999')
        .width('100%')
        .padding({ left: 4, top: 24, bottom: 10 })

      // Section 列表项
      Column() {
        ForEach(section.items, (item: SettingsItem, index: number) => {
          this.settingsRow(item, index < section.items.length - 1)
        })
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  settingsRow(item: SettingsItem, showDivider: boolean) {
    Column() {
      Row() {
        Text(item.label)
          .fontSize(16)
          .fontColor(item.type === 'danger' ? '#FF4D4F' :
            item.type === 'info' ? '#999999' : '#333333')
          .layoutWeight(1)

        if (item.type === 'nav') {
          Text('›')
            .fontSize(20)
            .fontColor('#CCCCCC')
        }

        if (item.type === 'action' && item.actionId === 'export') {
          if (this.vm.exporting) {
            LoadingProgress()
              .width(20)
              .height(20)
          } else {
            Text('导出')
              .fontSize(13)
              .fontColor('#1890FF')
          }
        }

        if (item.type === 'action' && item.actionId === 'sync_generate') {
          Text(this.vm.syncCode ? '已生成' : '生成')
            .fontSize(13)
            .fontColor(this.vm.syncCode ? '#52C41A' : '#1890FF')
        }

        if (item.type === 'action' && item.actionId === 'sync_import') {
          Text('导入')
            .fontSize(13)
            .fontColor('#1890FF')
        }
      }
      .width('100%')
      .height(52)
      .padding({ left: 16, right: 16 })
      .onClick(() => this.handleItemClick(item))

      if (showDivider) {
        Divider()
          .strokeWidth(0.5)
          .color('#F0F0F0')
          .margin({ left: 16 })
      }
    }
  }

  handleItemClick(item: SettingsItem): void {
    console.log("11111111")
    switch (item.actionId) {
      case 'page_manage':
        console.log("222222")
        HMRouterMgr.push({pageUrl: 'PageManagePage' });
        console.log("333333333")
        break;
      case 'sync_generate':
        this.vm.generateSyncCode();
        this.showSyncCodeDialog = true;
        break;
      case 'sync_import':
        this.importCode = '';
        this.showImportDialog = true;
        break;
      case 'export':
        this.vm.exportData(getContext(this));
        promptAction.showToast({ message: '数据导出请求已发起' });
        break;
      case 'import':
        promptAction.showToast({ message: '导入功能开发中' });
        break;
      case 'clear':
        this.clearConfirmText = '';
        this.showClearDialog = true;
        break;
    }
  }

  @Builder
  syncCodeDialog() {
    Column() {
      Column() {
        Text('同步码')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 6 })

        Text('复制下方同步码发送给对方，对方即可导入你的数据')
          .fontSize(13)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })

        // 同步码展示区
        Row() {
          Text(this.vm.syncCode)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1890FF')
            .fontFamily('monospace')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(48)
        .backgroundColor('#F0F7FF')
        .borderRadius(8)
        .margin({ bottom: 24 })

        // 操作按钮
        Row() {
          Button('复制同步码')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(() => {
              const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.vm.syncCode);
              const systemPasteboard = pasteboard.getSystemPasteboard();
              systemPasteboard.setData(pasteData);
              promptAction.showToast({ message: '同步码已复制' });
            })

          Button().width(12).backgroundColor(Color.Transparent)

          Button('关闭')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(() => {
              this.showSyncCodeDialog = false;
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)')
    .onClick(() => {
      this.showSyncCodeDialog = false;
    })
  }

  @Builder
  clearDialog() {
    Column() {
      Column() {
        Row() {
          Text('⚠')
            .fontSize(22)
            .margin({ right: 8 })

          Text('确认清除')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
        }
        .margin({ bottom: 8 })

        Text('此操作将清除所有本地数据，不可恢复')
          .fontSize(14)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })

        Text('请在下方输入「确认清除」以继续')
          .fontSize(13)
          .fontColor('#999999')
          .margin({ bottom: 12 })

        // 确认输入框
        TextInput({ text: this.clearConfirmText, placeholder: '确认清除' })
          .fontSize(14)
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.clearConfirmText = value;
          })
          .margin({ bottom: 24 })

        // 操作按钮
        Row() {
          Button('取消')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(() => {
              this.showClearDialog = false;
            })

          Button().width(12).backgroundColor(Color.Transparent)

          Button('确认清除')
            .fontSize(14)
            .backgroundColor(this.clearConfirmText === '确认清除' ? '#FF4D4F' : '#CCCCCC')
            .borderRadius(8)
            .layoutWeight(1)
            .enabled(this.clearConfirmText === '确认清除')
            .onClick(() => {
              if (this.clearConfirmText === '确认清除') {
                this.vm.clearAllData(getContext(this));
                promptAction.showToast({ message: '数据已清除' });
                this.showClearDialog = false;
              }
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .hitTestBehavior(HitTestMode.Block)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)')
    .onClick(() => {
      this.showClearDialog = false;
    })
  }

  @Builder
  importDialog() {
    Column() {
      Column() {
        Text('输入同步码')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 6 })

        Text('输入对方的同步码，即可导入对方的数据')
          .fontSize(13)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })

        // 输入框
        TextInput({ text: this.importCode, placeholder: '请输入同步码' })
          .fontSize(14)
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .padding({ left: 12, right: 12 })
          .onChange((value: string) => {
            this.importCode = value;
          })
          .margin({ bottom: 24 })

        // 操作按钮
        Row() {
          Button('取消')
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(() => {
              this.showImportDialog = false;
            })

          Button().width(12).backgroundColor(Color.Transparent)

          Button('确认导入')
            .fontSize(14)
            .backgroundColor('#1890FF')
            .borderRadius(8)
            .layoutWeight(1)
            .onClick(async () => {
              if (!this.importCode.trim()) {
                promptAction.showToast({ message: '请输入同步码' });
                return;
              }
              const success = await this.vm.importBySyncCode(getContext(this), this.importCode.trim());
              if (success) {
                promptAction.showToast({ message: '数据已同步导入' });
              } else {
                promptAction.showToast({ message: '同步失败，请检查同步码' });
              }
              this.showImportDialog = false;
            })
        }
        .width('100%')
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .hitTestBehavior(HitTestMode.Block)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)')
    .onClick(() => {
      this.showImportDialog = false;
    })
  }
}
