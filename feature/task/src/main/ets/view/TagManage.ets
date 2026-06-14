/**
 * 标签管理页面
 *
 * 支持标签的增删改查：
 * - 查：展示所有标签及引用计数、顶栏显示状态
 * - 增：右下角悬浮按钮 -> 弹窗输入名称创建
 * - 改：点击 ✏️ 图标 -> 弹窗输入新名称重命名（同步更新任务表中的引用）
 * - 删：点击 🗑️ 图标 -> 确认弹窗后删除（同时清除任务表中的引用）
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { EmptyState, TextInputDialog, TitleBar } from 'common.ui';
import { NotificationUtil } from 'common.util';
import { TagManageViewModel, TagStat } from '../viewmodel/TagManageViewModel';

@HMRouter({ pageUrl: 'TagManage' })
@Component
export struct TagManagePage {
  vm: TagManageViewModel = new TagManageViewModel();

  // ---- 新建标签弹窗 ----
  createDialogController: CustomDialogController = new CustomDialogController({
    builder: TextInputDialog({
      title: '新建标签',
      placeholder: '请输入标签名称',
      maxLength: 20,
      emptyError: '请输入标签名称',
      onConfirm: async (name: string): Promise<string> => {
        return await this.vm.createTag(name);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  // ---- 编辑标签弹窗 ----
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: TextInputDialog({
      title: '编辑标签',
      placeholder: '请输入新名称',
      maxLength: 20,
      emptyError: '请输入标签名称',
      onConfirm: async (name: string): Promise<string> => {
        return await this.vm.renameTag(this.vm.editTarget, name);
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  aboutToAppear() {
    this.vm.loadTags();
  }

  build() {
    Column() {
      TitleBar({ title: '标签管理', showBack: true, backCallback: () => HMRouterMgr.pop() })
      this.tagList()

      // 右下角新建按钮
      Button('+ 新建标签')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#1677FF')
        .borderRadius(24)
        .padding({
          left: 20,
          right: 20,
          top: 10,
          bottom: 10
        })
        .shadow({ radius: 8, color: 'rgba(22,119,255,0.3)' })
        .position({ right: 20, bottom: 30 })
        .onClick(() => {
          this.vm.editTarget = '';
          this.createDialogController.open();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
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
  tagItem(stat: TagStat, index: number) {
    Column() {
      // 标签名称 + 操作按钮
      Row() {
        // 标签名称
        Row() {
          Text(stat.tag)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1F1F1F')
        }
        .layoutWeight(1)

        // 已引用数量标识
        if (stat.taskCount > 0) {
          Text(`${stat.taskCount}`)
            .fontSize(12)
            .fontColor('#1677FF')
            .backgroundColor('rgba(22,119,255,0.08)')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .margin({ right: 12 })
        }

        // 编辑按钮
        Text('✏️')
          .fontSize(18)
          .padding({ left: 6, right: 6, top: 4, bottom: 4 })
          .borderRadius(6)
          .onClick(() => {
            this.vm.editTarget = stat.tag;
            this.editDialogController.open();
          })

        // 分隔线
        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color('#EEEEEE')
          .height(16)
          .margin({ left: 4, right: 4 })

        // 删除按钮
        Text('🗑️')
          .fontSize(18)
          .padding({ left: 6, right: 6, top: 4, bottom: 4 })
          .borderRadius(6)
          .onClick(() => {
            this.confirmDelete(stat.tag, stat.taskCount);
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 顶栏显示开关
      Row() {
        Text('在顶栏显示')
          .fontSize(13)
          .fontColor('#666666')

        Blank()

        Toggle({ type: ToggleType.Switch, isOn: stat.showInTopBar })
          .selectedColor('#1677FF')
          .onChange((isOn: boolean) => {
            this.vm.toggleShowInTopBar(stat.tag);
            NotificationUtil.toast(isOn ? '已开启顶栏显示' : '已关闭顶栏显示');
          })
      }
      .width('100%')
      .margin({ top: 10 })

      // 引用计数
      Row() {
        if (stat.taskCount > 0) {
          Text(`被 ${stat.taskCount} 个任务引用`)
            .fontSize(12)
            .fontColor('#999999')
        } else {
          Text('暂无任务引用')
            .fontSize(12)
            .fontColor('#CCCCCC')
        }
      }
      .width('100%')
      .margin({ top: 4 })
    }
    .width('100%')
    .padding({
      top: 14,
      bottom: 14,
      left: 16,
      right: 16
    })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }

  /**
   * 删除确认弹窗
   */
  confirmDelete(tag: string, taskCount: number) {
    let message = `确定要删除标签「${tag}」吗？`;
    if (taskCount > 0) {
      message += `\n\n该标签被 ${taskCount} 个任务引用，删除后将从这些任务中移除。`;
    }

    AlertDialog.show({
      title: '删除标签',
      message: message,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF4D4F',
        action: async () => {
          await this.vm.deleteTag(tag);
          NotificationUtil.toast('标签已删除');
        }
      }
    });
  }
}
