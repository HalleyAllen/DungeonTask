/**
 * 测试页面 - bindMenu 官方示例
 */
import { HMRouter } from '@hadss/hmrouter';

@HMRouter({ pageUrl: 'TestPage' })
@Component
export struct TestPage {
  @State select: boolean = true;

  @Builder
  SubMenu() {
    Menu() {
      MenuItem({ content: "复制", labelInfo: "Ctrl+C" })
      MenuItem({ content: "粘贴", labelInfo: "Ctrl+V" })
    }
  }

  @Builder
  MyMenu(){
    Menu() {
      MenuItem({  content: "菜单选项" })
      MenuItem({  content: "菜单选项" })
        .enabled(false)
      MenuItem({
        content: "菜单选项",
        builder: ():void=>this.SubMenu()
      })
      MenuItemGroup({ header: '小标题' }) {
        MenuItem({
          content: "菜单选项",
          builder: ():void=>this.SubMenu()
        })
        MenuItem({
          // startIcon: $r("app.media.app_icon"),
          content: "菜单选项",
          builder: ():void=>this.SubMenu()
        })
      }
      MenuItem({
        content: "菜单选项",
      })
    }
  }

  build() {
    Row() {
      Column() {
        Text('click to show menu')
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .bindMenu(this.MyMenu)
      .width('100%')
    }
    .height('100%')
  }
}
