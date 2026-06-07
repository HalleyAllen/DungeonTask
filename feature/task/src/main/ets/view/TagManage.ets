/**
 * 标签管理页面
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { EmptyState } from 'core.ui';
import { TagManageViewModel, TagStat } from '../viewmodel/TagManageViewModel';

@HMRouter({ pageUrl: 'TagManage' })
@Component
export struct TagManagePage {
  @State vm: TagManageViewModel = new TagManageViewModel();

  aboutToAppear() {
    this.vm.loadTags();
  }

  build() {
    Column() {
      this.titleBar()
      this.tagList()

      // 右下角新建按钮
      Button('+ 新建标签')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(24)
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
        .shadow({ radius: 8, color: 'rgba(22,119,255,0.3)' })
        .position({ right: 20, bottom: 30 })
        .onClick(() => {
          this.vm.showAddDialog = true;
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  titleBar() {
    Row() {
      Text('← 返回')
        .fontSize(16)
        .fontColor('#1677FF')
        .onClick(() => HMRouterMgr.pop())

      Blank()

      Text('标签管理')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)

      Blank()

      // 占位保持居中
      Row()
        .width(60)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
  }

  @Builder
  tagList() {
    if (this.vm.tagStats.length === 0 && !this.vm.isLoading) {
      EmptyState({ message: '暂无标签，点击下方按钮新建' })
    } else {
      List() {
        ForEach(this.vm.tagStats, (stat: TagStat, index: number) => {
          ListItem() {
            this.tagItem(stat, index)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, top: 12 })
      .divider({ strokeWidth: 0.5, color: '#E8E8E8' })
    }
  }

  @Builder
  tagItem(stat:TagStat, index: number) {
    Row() {
      Text(stat.tag)
        .fontSize(16)
        .fontColor('#1F1F1F')
        .layoutWeight(1)

      Text(`${stat.taskCount} 个任务`)
        .fontSize(13)
        .fontColor('#A6A6A6')

      Text('✏️')
        .fontSize(16)
        .margin({ left: 12 })
        .onClick(() => {
          this.vm.startEdit(stat.tag);
        })

      Text('🗑️')
        .fontSize(16)
        .margin({ left: 8 })
        .onClick(() => {
          this.vm.deleteTag(stat.tag);
        })
    }
    .width('100%')
    .padding({ top: 14, bottom: 14, left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }
}
