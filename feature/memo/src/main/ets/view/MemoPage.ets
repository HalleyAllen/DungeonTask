/**
 * 备忘录列表页
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { Memo } from 'core.model';
import { DateUtil } from 'core.util';
import { EmptyState, FloatingActionButton } from 'core.ui';
import { MemoPageViewModel } from '../viewmodel/MemoPageViewModel';

@HMRouter({ pageUrl: 'MemoPage' })
@Component
export struct MemoPage {
  @State vm: MemoPageViewModel = new MemoPageViewModel();

  aboutToAppear() {
    this.vm.loadMemos();
  }

  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          Text('备忘录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')

        // 搜索栏
        Row() {
          TextInput({ placeholder: '搜索备忘录...', text: this.vm.searchText })
            .width('100%')
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(20)
            .onChange((value: string) => {
              this.vm.searchText = value;
              this.vm.loadMemos();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 12 })
        .backgroundColor('#FFFFFF')

        // 列表
        if (this.vm.memos.length === 0) {
          EmptyState({ message: this.vm.searchText ? '未找到相关备忘录' : '暂无备忘录，点击下方添加', icon: '📝' })
            .layoutWeight(1)
        } else {
          List() {
            ForEach(this.vm.memos, (memo: Memo) => {
              ListItem() {
                Column() {
                  Text(memo.content)
                    .fontSize(14)
                    .fontColor('#1F1F1F')
                    .width('100%')
                    .maxLines(3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  Row() {
                    Text(DateUtil.formatTimestamp(memo.createTime))
                      .fontSize(12)
                      .fontColor('#A6A6A6')

                    Blank()

                    Text('🗑️')
                      .fontSize(16)
                      .onClick(() => this.vm.deleteMemo(memo.id))
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .margin({ bottom: 8 })
                .onClick(() => {
                  HMRouterMgr.push({
                    pageUrl: 'MemoEdit',
                    param: { id: memo.id }
                  });
                })
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({ left: 16, right: 16 })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      FloatingActionButton({
        clickFun: () => {
          HMRouterMgr.push({ pageUrl: 'MemoEdit' });
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}
