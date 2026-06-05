/**
 * 收藏编辑页（统一抽象）
 * 内置类型 + 用户自定义类型
 * 内置类型显示专属扩展字段，自定义类型使用通用描述字段
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { CollectionTypeItem, EditPageParams } from 'core.model';
import { CollectionEditViewModel } from '../viewmodel/CollectionEditViewModel';

@HMRouter({ pageUrl: 'CollectionEdit' })
@Component
export struct CollectionEdit {
  @State vm: CollectionEditViewModel = new CollectionEditViewModel();

  aboutToAppear() {
    const params = HMRouterMgr.getCurrentParam() as EditPageParams;
    this.vm.init(params);
  }

  build() {
    Stack() {
      Column() {
        // 顶部栏
        Row() {
          Text('取消')
            .fontSize(16)
            .fontColor('#1677FF')
            .onClick(() => HMRouterMgr.pop())

          Blank()

          Text(this.vm.isEdit ? '编辑收藏' : '添加收藏')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)

          Blank()

          Text('保存')
            .fontSize(16)
            .fontColor('#1677FF')
            .onClick(async () => {
              const ok = await this.vm.save();
              if (ok) {
                HMRouterMgr.pop();
              }
            })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            // 类型选择
            Text('类型')
              .fontSize(14)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 8 })

            Row() {
              ForEach(this.vm.types, (t: CollectionTypeItem) => {
                Text(t.label)
                  .fontSize(14)
                  .fontColor(this.vm.itemType === t.value ? '#FFFFFF' : '#1F1F1F')
                  .backgroundColor(this.vm.itemType === t.value ? '#1677FF' : '#F5F5F5')
                  .borderRadius(8)
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .margin({ right: 8 })
                  .onClick(() => { this.vm.itemType = t.value; })
              })
            }

            // 新建类型按钮
            Text('＋ 新建类型')
              .fontSize(14)
              .fontColor('#1677FF')
              .fontWeight(FontWeight.Medium)
              .margin({ top: 12 })
              .onClick(() => {
                this.vm.showAddTypeDialog = true;
              })

            Divider().margin({ top: 24, bottom: 24 })

            // 标题（必填）
            Text('标题 *')
              .fontSize(14)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 8 })

            TextInput({ placeholder: this.vm.getTitlePlaceholder(), text: this.vm.title })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.vm.title = value;
              })

            // 内容
            Text('内容')
              .fontSize(14)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ top: 24, bottom: 8 })

            TextArea({ placeholder: this.vm.getContentPlaceholder(), text: this.vm.content })
              .width('100%')
              .height(120)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.vm.content = value;
              })

            Divider().margin({ top: 24, bottom: 24 })

            // 根据类型显示不同扩展字段
            if (this.vm.itemType === 'word') {
              this.wordExtraFields()
            } else if (this.vm.itemType === 'sentence' || this.vm.itemType === 'quote') {
              this.sentenceExtraFields()
            } else {
              // 内置 knowledge 和自定义类型均显示通用描述字段
              this.genericExtraFields()
            }

            Divider().margin({ top: 24, bottom: 24 })

            // 标签
            Text('标签')
              .fontSize(14)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 8 })

            TextInput({ placeholder: '如：励志、哲理、生僻字', text: this.vm.tag })
              .width('100%')
              .height(48)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.vm.tag = value;
              })
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')

      // 新建类型弹窗
      if (this.vm.showAddTypeDialog) {
        this.addTypeDialog()
      }
    }
  }

  @Builder
  addTypeDialog() {
    Column() {
      Column() {
        Text('新建收藏类型')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 24 })

        Text('类型名称')
          .fontSize(14)
          .fontColor('#A6A6A6')
          .width('100%')
          .margin({ bottom: 8 })
        TextInput({ placeholder: '如：歌词、配方、代码片段', text: this.vm.newTypeLabel })
          .width('100%')
          .height(48)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => { this.vm.newTypeLabel = value; })

        Row() {
          Button('取消')
            .fontSize(16)
            .fontColor('#A6A6A6')
            .backgroundColor('#F5F5F5')
            .layoutWeight(1)
            .onClick(() => {
              this.vm.showAddTypeDialog = false;
              this.vm.newTypeLabel = '';
            })

          Button('创建')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor('#1677FF')
            .layoutWeight(1)
            .margin({ left: 12 })
            .enabled(this.vm.newTypeLabel.trim().length > 0)
            .onClick(() => this.vm.createNewType())
        }
        .width('100%')
        .margin({ top: 28 })
      }
      .width('80%')
      .padding(24)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('rgba(0,0,0,0.4)')
    .onClick(() => {
      this.vm.showAddTypeDialog = false;
      this.vm.newTypeLabel = '';
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        event.stopPropagation();
      }
    })
  }

  @Builder
  wordExtraFields() {
    Column() {
      Text('拼音')
        .fontSize(14)
        .fontColor('#A6A6A6')
        .width('100%')
        .margin({ bottom: 8 })
      TextInput({ placeholder: '请输入拼音', text: this.vm.wordPinyin })
        .width('100%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onChange((value: string) => { this.vm.wordPinyin = value; })

      Text('释义')
        .fontSize(14)
        .fontColor('#A6A6A6')
        .width('100%')
        .margin({ top: 24, bottom: 8 })
      TextArea({ placeholder: '请输入释义', text: this.vm.wordExplanation })
        .width('100%')
        .height(100)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onChange((value: string) => { this.vm.wordExplanation = value; })
    }
  }

  @Builder
  sentenceExtraFields() {
    Column() {
      Text('出处/来源')
        .fontSize(14)
        .fontColor('#A6A6A6')
        .width('100%')
        .margin({ bottom: 8 })
      TextInput({ placeholder: '如：《百年孤独》、某某电影', text: this.vm.textSource })
        .width('100%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onChange((value: string) => { this.vm.textSource = value; })

      Text('作者/角色')
        .fontSize(14)
        .fontColor('#A6A6A6')
        .width('100%')
        .margin({ top: 24, bottom: 8 })
      TextInput({ placeholder: '如：马尔克斯、张三', text: this.vm.textAuthor })
        .width('100%')
        .height(48)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onChange((value: string) => { this.vm.textAuthor = value; })
    }
  }

  /** 通用扩展字段——用于内置 knowledge 和所有自定义类型 */
  @Builder
  genericExtraFields() {
    Column() {
      Text('描述')
        .fontSize(14)
        .fontColor('#A6A6A6')
        .width('100%')
        .margin({ bottom: 8 })
      TextArea({ placeholder: '输入描述信息', text: this.vm.customDesc })
        .width('100%')
        .height(100)
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .onChange((value: string) => { this.vm.customDesc = value; })
    }
  }
}
