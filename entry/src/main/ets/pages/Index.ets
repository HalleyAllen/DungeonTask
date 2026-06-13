/**
 * 应用入口 - HMRouter 导航容器
 * 参考 keep_accounts 项目架构
 */
import { HMNavigation, HMDefaultGlobalAnimator, HMRouterMgr } from '@hadss/hmrouter';
import { MainPage } from './MainPage';
import { PageManagePage } from 'feature.settings';
import { AttributeUpdater } from '@kit.ArkUI';

/**
 * Navigation 属性配置器
 * 用于设置 Navigation 组件的显示属性
 */
class NavModifier extends AttributeUpdater<NavigationAttribute> {
  initializeModifier(instance: NavigationAttribute): void {
    instance.mode(NavigationMode.Stack);
    instance.navBarWidth('100%');
    instance.hideTitleBar(true);
    instance.hideToolBar(true);
  }
}

@Entry
@Component
struct Index {
  private modifier: NavModifier = new NavModifier();
  aboutToAppear(): void {
  }

  build() {
    Column() {
      HMNavigation({
        navigationId: 'mainNavigation',
        homePageUrl: 'MainPage',
        options: {
          standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
          dialogAnimator: HMDefaultGlobalAnimator.DIALOG_ANIMATOR,
          modifier: this.modifier
        }
      })
    }
    .width("100%")
    .height("100%")
  }
}
