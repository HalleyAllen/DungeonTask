/**
 * 主页面 - 底部 Tab 导航
 */
import { router } from '@kit.ArkUI';
import { TaskPage } from 'feature.task';
import { HabitPage } from 'feature.habit';
import { CollectionPage } from 'feature.collection';
import { MemoPage } from 'feature.memo';

@Entry
@Component
export struct Index {
  @State currentTab: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
      TabContent() {
        TaskPage()
      }
      .tabBar(this.tabBarItem('任务', '📋', 0))

      TabContent() {
        HabitPage()
      }
      .tabBar(this.tabBarItem('习惯', '🔄', 1))

      TabContent() {
        CollectionPage()
      }
      .tabBar(this.tabBarItem('收藏', '📦', 2))

      TabContent() {
        MemoPage()
      }
      .tabBar(this.tabBarItem('备忘', '📝', 3))
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
