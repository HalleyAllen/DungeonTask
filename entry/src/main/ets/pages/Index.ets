/**
 * 主页面 - 底部 Tab 导航
 */
import { router } from '@kit.ArkUI';
// import { TaskPage } from 'feature.task';
// import { MemoPage } from 'feature.memo';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
      TabContent() {
      }
      .tabBar(this.tabBarItem('任务', '📋', 0))

      TabContent() {
      }
      .tabBar(this.tabBarItem('健身', '💪', 1))

      TabContent() {
      }
      .tabBar(this.tabBarItem('句子', '💬', 2))

      TabContent() {
      }
      .tabBar(this.tabBarItem('词语', '📖', 3))

      TabContent() {
      }
      .tabBar(this.tabBarItem('备忘', '📝', 4))
    }
    .width('100%')
    .height('100%')
    .barHeight(60)
    .onChange((index: number) => {
      this.currentTab = index;
    })
  }

  private tabController: TabsController = new TabsController();

  @Builder
  tabBarItem(title: string, icon: string, index: number) {
    Column() {
      Text(icon)
        .fontSize(24)
      
      Text(title)
        .fontSize(12)
        .fontColor(this.currentTab === index ? '#1890FF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(60)
    .backgroundColor('#FFFFFF')
  }
}
