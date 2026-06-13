/**
 * 收藏编辑页（统一抽象）
 * 内置类型 + 用户自定义类型
 * 内置类型显示专属扩展字段，自定义类型使用通用描述字段
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { CollectionTypeItem, CollectionSubItem, EditPageParams } from 'core.model';
import { DatePickerModule } from 'common.ui';
import { CollectionEditViewModel } from '../viewmodel/CollectionEditViewModel';

@HMRouter({ pageUrl: 'CollectionEdit' })
@ComponentV2
export struct CollectionEdit {
  @Local vm: CollectionEditViewModel = new CollectionEditViewModel();

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
            .onClick(() => this.vm.goBack())

          Blank()

          Text(this.vm.isEdit ? '编辑收藏' : '添加收藏')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)

          Blank()

          Text('保存')
            .fontSize(16)
            .fontColor('#1677FF')
            .onClick(() => this.vm.handleSave())
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')

        Scroll() {
          Column() {
            // ===================== 记录样式 =====================
            Text('🎨 记录样式')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F1F1F')
              .width('100%')
              .margin({ bottom: 12 })

            // 类型选择
            Text('类型')
              .fontSize(13)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 6 })

            Scroll() {
              Row() {
                ForEach(this.vm.types, (t: CollectionTypeItem) => {
                  Text(t.label)
                    .fontSize(14)
                    .fontColor(this.vm.itemType === t.value ? '#FFFFFF' : '#1F1F1F')
                    .backgroundColor(this.vm.itemType === t.value ? '#1677FF' : '#F5F5F5')
                    .borderRadius(16)
                    .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                    .margin({ right: 8 })
                    .onClick(() => { this.vm.itemType = t.value; })
                })

                Text('＋')
                  .fontSize(14)
                  .fontColor('#1677FF')
                  .backgroundColor('#F5F5F5')
                  .borderRadius(16)
                  .padding({ left: 14, right: 14, top: 7, bottom: 7 })
                  .onClick(() => {
                    this.vm.showAddTypeDialog = true;
                  })
              }
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')

            // 类型提示
            Text(this.vm.getTypeHint())
              .fontSize(12)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ top: 6 })

            Divider().margin({ top: 16, bottom: 16 })

            // 标签选择
            Row() {
              Text('标签')
                .fontSize(13)
                .fontColor('#A6A6A6')

              Blank()

              Text('管理 →')
                .fontSize(12)
                .fontColor('#1677FF')
                .onClick(() => {
                  HMRouterMgr.push({ pageUrl: 'CollectionTagManage' });
                })
            }
            .width('100%')
            .margin({ bottom: 6 })

            // 已选标签
            if (this.vm.selectedTags.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.vm.selectedTags, (tag: string) => {
                  Row() {
                    Text(tag)
                      .fontSize(13)
                      .fontColor('#FFFFFF')
                    Text(' ×')
                      .fontSize(13)
                      .fontColor('rgba(255,255,255,0.7)')
                      .margin({ left: 4 })
                  }
                  .backgroundColor('#1677FF')
                  .borderRadius(12)
                  .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => this.vm.removeTag(tag))
                })
              }
              .width('100%')
              .margin({ bottom: 10 })
            }

            // 下拉选择标签
            Row() {
              Text('点击选择标签')
                .fontSize(15)
                .fontColor('#A6A6A6')
                .layoutWeight(1)

              Text('▼')
                .fontSize(12)
                .fontColor('#A6A6A6')
            }
            .width('100%')
            .height(44)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .bindMenu(this.TagMenuBuilder)

            // 自定义标签输入
            Row() {
              TextInput({ placeholder: '输入新标签', text: this.vm.tagInput })
                .layoutWeight(1)
                .height(40)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => { this.vm.tagInput = value; })
                .onSubmit(() => { this.vm.addCustomTag(); })

              Text('添加')
                .fontSize(14)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Medium)
                .margin({ left: 10 })
                .onClick(() => this.vm.addCustomTag())
            }
            .width('100%')
            .margin({ top: 10 })

            Divider().margin({ top: 24, bottom: 24 })

            // ===================== 内容区 =====================
            Text('📝 内容')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F1F1F')
              .width('100%')
              .margin({ bottom: 12 })

            // 标题（必填）
            Text('标题 *')
              .fontSize(13)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 6 })

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
              .fontSize(13)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ top: 20, bottom: 6 })

            TextArea({ placeholder: this.vm.getContentPlaceholder(), text: this.vm.content })
              .width('100%')
              .height(120)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.vm.content = value;
              })

            // ===================== 扩展字段（根据类型） =====================
            if (this.vm.itemType === 'word') {
              this.wordExtraFields()
            } else if (this.vm.itemType === 'sentence' || this.vm.itemType === 'quote') {
              this.sentenceExtraFields()
            } else {
              this.genericExtraFields()
            }

            Divider().margin({ top: 24, bottom: 24 })

            // ===================== 截止日期 & 子项 =====================
            Text('⚙ 其他')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1F1F1F')
              .width('100%')
              .margin({ bottom: 12 })

            // 截至日期
            Text('截至日期')
              .fontSize(13)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 6 })

            DatePickerModule({
              deadline: this.vm.deadline,
              deadlineText: this.vm.deadlineText,
              onConfirm: (timestamp: number) => {
                this.vm.setDeadline(timestamp);
              },
              onClear: () => {
                this.vm.clearDeadline();
              }
            })

            Divider().margin({ top: 20, bottom: 20 })

            // 子项
            Text('子项清单')
              .fontSize(13)
              .fontColor('#A6A6A6')
              .width('100%')
              .margin({ bottom: 6 })

            // 已有子项列表
            ForEach(this.vm.subItems, (sub: CollectionSubItem, index: number) => {
              Row() {
                Toggle({ type: ToggleType.Checkbox, isOn: sub.completed })
                  .width(24)
                  .height(24)
                  .onChange((value: boolean) => {
                    this.vm.toggleSubItem(index);
                  })

                TextInput({ text: sub.text })
                  .layoutWeight(1)
                  .height(42)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(6)
                  .margin({ left: 8, right: 8 })
                  .decoration({ type: sub.completed ? TextDecorationType.LineThrough : TextDecorationType.None })
                  .fontColor(sub.completed ? '#A6A6A6' : '#1F1F1F')
                  .onChange((value: string) => {
                    this.vm.updateSubItemText(index, value);
                  })

                Text('🗑')
                  .fontSize(18)
                  .onClick(() => this.vm.removeSubItem(index))
              }
              .width('100%')
              .margin({ bottom: 10 })
            })

            // 新增子项
            Row() {
              TextInput({ placeholder: '添加子项', text: this.vm.newSubItemText })
                .layoutWeight(1)
                .height(42)
                .backgroundColor('#F5F5F5')
                .borderRadius(8)
                .onChange((value: string) => { this.vm.newSubItemText = value; })
                .onSubmit(() => { this.vm.addSubItem(); })

              Text('添加')
                .fontSize(14)
                .fontColor('#1677FF')
                .fontWeight(FontWeight.Medium)
                .margin({ left: 10 })
                .onClick(() => this.vm.addSubItem())
            }
            .width('100%')
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
            .onClick(() => this.vm.dismissAddTypeDialog())

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
    .onClick(() => this.vm.dismissAddTypeDialog())
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

  /** 标签下拉菜单 */
  @Builder
  TagMenuBuilder() {
    if (this.vm.allTags.length > 0) {
      Menu() {
        ForEach(this.vm.allTags, (tag: string) => {
          MenuItem({ content: `${this.vm.isTagSelected(tag) ? '✓  ' : ''}${tag}` })
            .onClick(() => { this.vm.toggleTag(tag); })
        })
      }
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
