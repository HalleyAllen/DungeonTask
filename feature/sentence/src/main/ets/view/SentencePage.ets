/**
 * 句子列表页
 */
import { router } from '@kit.ArkUI';
import { Sentence } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';
import { EmptyState } from 'core.ui';

@Entry
@Component
struct SentencePage {
  @State sentences: Sentence[] = [];

  aboutToAppear() {
    this.loadSentences();
  }

  async loadSentences() {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates('sentence');
      predicates.orderByDesc('createTime');
      
      const result = await store.query(predicates);
      this.sentences = this.parseSentences(result);
    } catch (e) {
      console.error('Load sentences failed:', e);
    }
  }

  async deleteSentence(id: number) {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      await store.delete('sentence', new relationalStore.RdbPredicates('sentence').equalTo('id', id));
      this.loadSentences();
    } catch (e) {
      console.error('Delete sentence failed:', e);
    }
  }

  private parseSentences(result: relationalStore.ResultSet): Sentence[] {
    const list: Sentence[] = [];
    while (result.goToNextRow()) {
      const sentence = new Sentence();
      sentence.id = result.getLong(result.getColumnIndex('id'));
      sentence.content = result.getString(result.getColumnIndex('content'));
      sentence.source = result.getString(result.getColumnIndex('source'));
      sentence.tag = result.getString(result.getColumnIndex('tag'));
      sentence.createTime = result.getLong(result.getColumnIndex('createTime'));
      list.push(sentence);
    }
    result.close();
    return list;
  }

  build() {
    Column() {
      Row() {
        Text('句子收集')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      if (this.sentences.length === 0) {
        EmptyState({ message: '暂无句子，点击下方添加', icon: '💬' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.sentences, (sentence: Sentence) => {
            ListItem() {
              Column() {
                Text(sentence.content)
                  .fontSize(16)
                  .fontColor('#333333')
                  .width('100%')
                  .lineHeight(24)

                Row() {
                  if (sentence.source) {
                    Text(`—— ${sentence.source}`)
                      .fontSize(12)
                      .fontColor('#999999')
                  }

                  Blank()

                  Text('🗑️')
                    .fontSize(16)
                    .onClick(() => this.deleteSentence(sentence.id))
                }
                .width('100%')
                .margin({ top: 12 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .margin({ bottom: 8 })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/sentence/SentenceEdit',
                  params: { id: sentence.id }
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
          router.pushUrl({ url: 'pages/sentence/SentenceEdit' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
