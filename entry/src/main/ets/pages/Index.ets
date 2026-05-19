/**
 * 主页面 - 底部 Tab 导航
 */
import { router } from '@kit.ArkUI';
import { TaskPage } from 'feature.task';
import { FitnessPage } from 'feature.fitness';
import { SentencePage } from 'feature.sentence';
import { WordPage } from 'feature.word';
import { GoalPage } from 'feature.goal';
import { MemoPage } from 'feature.memo';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
      TabContent() {
        TaskPage()
      }
      .tabBar(this.tabBarItem('任务', '📋', 0))

      TabContent() {
        FitnessPage()
      }
      .tabBar(this.tabBarItem('健身', '💪', 1))

      TabContent() {
        SentencePage()
      }
      .tabBar(this.tabBarItem('句子', '💬', 2))

      TabContent() {
        WordPage()
      }
      .tabBar(this.tabBarItem('词语', '📖', 3))

      TabContent() {
        GoalPage()
      }
      .tabBar(this.tabBarItem('目标', '🎯', 4))

      TabContent() {
        MemoPage()
      }
      .tabBar(this.tabBarItem('备忘', '📝', 5))
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
