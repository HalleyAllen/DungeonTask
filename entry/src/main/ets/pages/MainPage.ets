/**
 * 主 Tab 页面 - 底部导航
 * 作为 HMRouter 首页加载
 */
import { HMRouter } from '@hadss/hmrouter';
import { preferences } from '@kit.ArkData';
import { TaskPage } from 'feature.task';
import { HabitPage } from 'feature.habit';
import { CollectionPage } from 'feature.collection';
import { MemoPage } from 'feature.memo';
import { SettingsPage } from 'feature.settings';

const DEFAULT_TAB_ORDER: string[] = ['task', 'habit', 'collection', 'memo', 'settings'];

interface TabItem {
  key: string;
  label: string;
  icon: Resource;
}

function getTabLabel(key: string): string {
  if (key === 'task') return '任务';
  if (key === 'habit') return '习惯';
  if (key === 'collection') return '收藏';
  if (key === 'memo') return '备忘';
  if (key === 'settings') return '设置';
  return key;
}

function getTabIcon(key: string): Resource {
  if (key === 'task') return $r('app.media.ic_tab_task');
  if (key === 'habit') return $r('app.media.ic_tab_habit');
  if (key === 'collection') return $r('app.media.ic_tab_collection');
  if (key === 'memo') return $r('app.media.ic_tab_memo');
  return $r('app.media.ic_tab_settings');
}

function getPageVisible(visibleStr: string, key: string): boolean {
  if (!visibleStr) return true;
  const pairs = visibleStr.split(',');
  for (const pair of pairs) {
    const parts = pair.split(':');
    if (parts.length === 2 && parts[0] === key) {
      return parts[1] === '1';
    }
  }
  return true;
}

function buildDefaultTabs(): TabItem[] {
  const result: TabItem[] = [];
  for (const key of DEFAULT_TAB_ORDER) {
    result.push({ key: key, label: getTabLabel(key), icon: getTabIcon(key) });
  }
  return result;
}

@HMRouter({ pageUrl: 'MainPage' })
@Component
export struct MainPage {
  @State currentTab: number = 0;
  @State tabs: TabItem[] = [];
  private tabController: TabsController = new TabsController();

  async aboutToAppear(): Promise<void> {
    await this.loadTabConfig();
  }

  async loadTabConfig(): Promise<void> {
    try {
      const dataPrefs = await preferences.getPreferences(getContext(this), 'dungeontask_settings');
      const orderStr = await dataPrefs.get('page_order', '') as string;
      const visibleStr = await dataPrefs.get('page_visible', '') as string;

      const savedOrder: string[] = orderStr ? orderStr.split(',') : [];

      const allKeys = ['task', 'habit', 'collection', 'memo'];
      const orderSet = new Set(savedOrder);
      allKeys.forEach((k: string) => {
        if (!orderSet.has(k)) {
          savedOrder.push(k);
        }
      });

      const result: TabItem[] = [];
      for (const key of savedOrder) {
        const visible = getPageVisible(visibleStr, key);
        if (visible) {
          result.push({
            key: key,
            label: getTabLabel(key),
            icon: getTabIcon(key)
          });
        }
      }

      // 设置 tab 始终在最后，始终可见
      result.push({
        key: 'settings',
        label: getTabLabel('settings'),
        icon: getTabIcon('settings')
      });

      this.tabs = result;
    } catch (e) {
      this.tabs = buildDefaultTabs();
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
      ForEach(this.tabs, (tab: TabItem, index: number) => {
        TabContent() {
          this.pageContent(tab.key)
        }
        .tabBar(this.tabBarItem(tab.label, tab.icon, index))
      })
    }
    .width('100%')
    .height('100%')
    .barHeight(60)
    .onChange((index: number) => {
      this.currentTab = index;
    })
  }

  @Builder
  pageContent(key: string) {
    if (key === 'task') {
      TaskPage()
    } else if (key === 'habit') {
      HabitPage()
    } else if (key === 'collection') {
      CollectionPage()
    } else if (key === 'memo') {
      MemoPage()
    } else if (key === 'settings') {
      SettingsPage()
    }
  }

  @Builder
  tabBarItem(title: string, icon: Resource, index: number) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(this.currentTab === index ? '#1890FF' : '#999999')

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
