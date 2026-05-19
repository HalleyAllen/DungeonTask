/**
 * 备忘录列表页
 */
import { router } from '@kit.ArkUI';
import { Memo } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';
import { EmptyState } from 'core.ui';

@Entry
@Component
struct MemoPage {
  @State memos: Memo[] = [];
  @State searchText: string = '';

  aboutToAppear() {
    this.loadMemos();
  }

  async loadMemos() {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates('memo');
      predicates.orderByDesc('createTime');
      
      const result = await store.query(predicates);
      this.memos = this.parseMemos(result);
      
      // 过滤搜索结果
      if (this.searchText) {
        this.memos = this.memos.filter(m => 
          m.content.toLowerCase().includes(this.searchText.toLowerCase())
        );
      }
    } catch (e) {
      console.error('Load memos failed:', e);
    }
  }

  async deleteMemo(id: number) {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      await store.delete('memo', new relationalStore.RdbPredicates('memo').equalTo('id', id));
      this.loadMemos();
    } catch (e) {
      console.error('Delete memo failed:', e);
    }
  }

  private parseMemos(result: relationalStore.ResultSet): Memo[] {
    const list: Memo[] = [];
    while (result.goToNextRow()) {
      const memo = new Memo();
      memo.id = result.getLong(result.getColumnIndex('id'));
      memo.content = result.getString(result.getColumnIndex('content'));
      memo.createTime = result.getLong(result.getColumnIndex('createTime'));
      memo.updateTime = result.getLong(result.getColumnIndex('updateTime'));
      list.push(memo);
    }
    result.close();
    return list;
  }

  build() {
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
        TextInput({ placeholder: '搜索备忘录...', text: this.searchText })
          .width('100%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .borderRadius(20)
          .onChange((value: string) => {
            this.searchText = value;
            this.loadMemos();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 列表
      if (this.memos.length === 0) {
        EmptyState({ message: this.searchText ? '未找到相关备忘录' : '暂无备忘录，点击下方添加', icon: '📝' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.memos, (memo: Memo) => {
            ListItem() {
              Column() {
                Text(memo.content)
                  .fontSize(14)
                  .fontColor('#333333')
                  .width('100%')
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                Row() {
                  Text(DateUtil.formatTimestamp(memo.createTime))
                    .fontSize(12)
                    .fontColor('#999999')

                  Blank()

                  Text('🗑️')
                    .fontSize(16)
                    .onClick(() => this.deleteMemo(memo.id))
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
                router.pushUrl({
                  url: 'pages/memo/MemoEdit',
                  params: { id: memo.id }
                });
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }

      Button('＋')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontColor('#FFFFFF')
        .backgroundColor('#1890FF')
        .borderRadius(28)
        .position({ x: '85%', y: '80%' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/memo/MemoEdit' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
