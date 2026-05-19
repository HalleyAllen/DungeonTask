/**
 * 词语编辑页
 */
import { router } from '@kit.ArkUI';
import { Word } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';

@Entry
@Component
struct WordEdit {
  @State name: string = '';
  @State pinyin: string = '';
  @State explanation: string = '';
  @State isEdit: boolean = false;
  @State wordId: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.isEdit = true;
      this.wordId = params.id;
      this.loadWord();
    }
  }

  async loadWord() {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const result = await store.query(
        new relationalStore.RdbPredicates('word').equalTo('id', this.wordId)
      );
      if (result.goToFirstRow()) {
        this.name = result.getString(result.getColumnIndex('name'));
        this.pinyin = result.getString(result.getColumnIndex('pinyin'));
        this.explanation = result.getString(result.getColumnIndex('explanation'));
      }
      result.close();
    } catch (e) {
      console.error('Load word failed:', e);
    }
  }

  async save() {
    if (!this.name.trim() || !this.pinyin.trim() || !this.explanation.trim()) return;

    try {
      const store = DbHelper.getInstance().getRdbStore();
      const valueBucket: relationalStore.ValuesBucket = {
        name: this.name,
        pinyin: this.pinyin,
        explanation: this.explanation,
        updateTime: DateUtil.getNow()
      };

      if (this.isEdit) {
        await store.update(
          'word',
          valueBucket,
          new relationalStore.RdbPredicates('word').equalTo('id', this.wordId)
        );
      } else {
        valueBucket['createTime'] = DateUtil.getNow();
        await store.insert('word', valueBucket);
      }
      router.back();
    } catch (e) {
      console.error('Save word failed:', e);
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

        Text(this.isEdit ? '编辑词语' : '添加词语')
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
        Text('词语')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ bottom: 8 })

        TextInput({ placeholder: '请输入词语', text: this.name })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.name = value;
          })

        Text('拼音')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextInput({ placeholder: '请输入拼音', text: this.pinyin })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.pinyin = value;
          })

        Text('释义')
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .margin({ top: 24, bottom: 8 })

        TextArea({ placeholder: '请输入释义', text: this.explanation })
          .width('100%')
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.explanation = value;
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
