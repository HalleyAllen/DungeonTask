/**
 * 句子编辑页
 */
import { router } from '@kit.ArkUI';
import { Sentence } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';

@Entry
@Component
struct SentenceEdit {
  @State content: string = '';
  @State source: string = '';
  @State tag: string = '';
  @State isEdit: boolean = false;
  @State sentenceId: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.isEdit = true;
      this.sentenceId = params.id;
      this.loadSentence();
    }
  }

  async loadSentence() {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const result = await store.query(
        new relationalStore.RdbPredicates('sentence').equalTo('id', this.sentenceId)
      );
      if (result.goToFirstRow()) {
        this.content = result.getString(result.getColumnIndex('content'));
        this.source = result.getString(result.getColumnIndex('source'));
        this.tag = result.getString(result.getColumnIndex('tag'));
      }
      result.close();
    } catch (e) {
      console.error('Load sentence failed:', e);
    }
  }

  async save() {
    if (!this.content.trim()) return;

    try {
      const store = DbHelper.getInstance().getRdbStore();
      const valueBucket: relationalStore.ValuesBucket = {
        content: this.content,
        source: this.source,
        tag: this.tag,
        updateTime: DateUtil.getNow()
      };

      if (this.isEdit) {
        await store.update(
          'sentence',
          valueBucket,
          new relationalStore.RdbPredicates('sentence').equalTo('id', this.sentenceId)
        );
      } else {
        valueBucket['createTime'] = DateUtil.getNow();
        await store.insert('sentence', valueBucket);
      }
      router.back();
    } catch (e) {
      console.error('Save sentence failed:', e);
    }
  }

  build() {
    Column() {
      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => router.back())

        Blank()

        Text(this.isEdit ? '编辑句子' : '添加句子')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)

        Blank()

        Text('保存')
          .fontSize(16)
          .fontColor('#1890FF')
          .onClick(() => this.save())
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      Column() {
        Text('句子内容')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        TextArea({ placeholder: '请输入句子', text: this.content })
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.content = value;
          })

        Text('来源（可选）')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextInput({ placeholder: '如：某某书籍、某某电影', text: this.source })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.source = value;
          })

        Text('标签（可选）')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextInput({ placeholder: '如：励志、哲理', text: this.tag })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.tag = value;
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
