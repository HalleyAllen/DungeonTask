/**
 * 词语列表页
 */
import { router } from '@kit.ArkUI';
import { Word } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';
import { EmptyState } from 'core.ui';

@Entry
@Component
struct WordPage {
  @State words: Word[] = [];
  @State expandedId: number = -1;

  aboutToAppear() {
    this.loadWords();
  }

  async loadWords() {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates('word');
      predicates.orderByAsc('name');
      
      const result = await store.query(predicates);
      this.words = this.parseWords(result);
    } catch (e) {
      console.error('Load words failed:', e);
    }
  }

  async deleteWord(id: number) {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      await store.delete('word', new relationalStore.RdbPredicates('word').equalTo('id', id));
      this.loadWords();
    } catch (e) {
      console.error('Delete word failed:', e);
    }
  }

  private parseWords(result: relationalStore.ResultSet): Word[] {
    const list: Word[] = [];
    while (result.goToNextRow()) {
      const word = new Word();
      word.id = result.getLong(result.getColumnIndex('id'));
      word.name = result.getString(result.getColumnIndex('name'));
      word.pinyin = result.getString(result.getColumnIndex('pinyin'));
      word.explanation = result.getString(result.getColumnIndex('explanation'));
      word.createTime = result.getLong(result.getColumnIndex('createTime'));
      list.push(word);
    }
    result.close();
    return list;
  }

  build() {
    Column() {
      Row() {
        Text('词语收集')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      if (this.words.length === 0) {
        EmptyState({ message: '暂无词语，点击下方添加', icon: '📖' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.words, (word: Word) => {
            ListItem() {
              Column() {
                Row() {
                  Text(word.name)
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')

                  Text(word.pinyin)
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ left: 8 })

                  Blank()

                  Text(this.expandedId === word.id ? '▲' : '▼')
                    .fontSize(12)
                    .fontColor('#999999')
                    .onClick(() => {
                      this.expandedId = this.expandedId === word.id ? -1 : word.id;
                    })
                }
                .width('100%')

                if (this.expandedId === word.id) {
                  Column() {
                    Text(word.explanation)
                      .fontSize(14)
                      .fontColor('#666666')
                      .width('100%')
                      .margin({ top: 8 })

                    Row() {
                      Blank()

                      Text('编辑')
                        .fontSize(14)
                        .fontColor('#1890FF')
                        .onClick(() => {
                          router.pushUrl({
                            url: 'pages/word/WordEdit',
                            params: { id: word.id }
                          });
                        })

                      Text('删除')
                        .fontSize(14)
                        .fontColor('#FF4D4F')
                        .margin({ left: 16 })
                        .onClick(() => this.deleteWord(word.id))
                    }
                    .width('100%')
                    .margin({ top: 12 })
                  }
                  .padding({ top: 12 })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ bottom: 8 })
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
          router.pushUrl({ url: 'pages/word/WordEdit' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
