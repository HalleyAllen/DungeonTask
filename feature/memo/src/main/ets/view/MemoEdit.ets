/**
 * 备忘录编辑页
 */
import { router } from '@kit.ArkUI';
import { Memo } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';

@Entry
@Component
struct MemoEdit {
  @State content: string = '';
  @State isEdit: boolean = false;
  @State memoId: number = 0;

  aboutToAppear() {
    const params = router.getParams() as Record<string, number>;
    if (params && params.id) {
      this.isEdit = true;
      this.memoId = params.id;
      this.loadMemo();
    }
  }

  async loadMemo() {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const result = await store.query(
        new relationalStore.RdbPredicates('memo').equalTo('id', this.memoId)
      );
      if (result.goToFirstRow()) {
        this.content = result.getString(result.getColumnIndex('content'));
      }
      result.close();
    } catch (e) {
      console.error('Load memo failed:', e);
    }
  }

  async save() {
    if (!this.content.trim()) return;

    try {
      const store = DbHelper.getInstance().getRdbStore();
      const valueBucket: relationalStore.ValuesBucket = {
        content: this.content,
        updateTime: DateUtil.getNow()
      };

      if (this.isEdit) {
        await store.update(
          'memo',
          valueBucket,
          new relationalStore.RdbPredicates('memo').equalTo('id', this.memoId)
        );
      } else {
        valueBucket['createTime'] = DateUtil.getNow();
        await store.insert('memo', valueBucket);
      }
      router.back();
    } catch (e) {
      console.error('Save memo failed:', e);
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

        Text(this.isEdit ? '编辑备忘录' : '新增备忘录')
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

      TextArea({ placeholder: '记录你的想法...', text: this.content })
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#FFFFFF')
        .onChange((value: string) => {
          this.content = value;
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
