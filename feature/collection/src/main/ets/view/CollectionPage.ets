/**
 * 收藏列表页（统一抽象）
 * 支持按类型筛选：内置类型 + 用户自定义类型
 */
import { router } from '@kit.ArkUI';
import { Collection } from 'core.model';
import { DateUtil } from 'core.util';
import { EmptyState } from 'core.ui';
import { CollectionPageViewModel, TypeOption } from '../viewmodel/CollectionPageViewModel';

@Component
export struct CollectionPage {
  @State vm: CollectionPageViewModel = new CollectionPageViewModel();

  aboutToAppear() {
    this.vm.loadTypes();
    this.vm.loadCollections();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('📦 收藏夹')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 类型筛选（横向滚动支持多个自定义类型）
      Scroll() {
        Row() {
          ForEach(this.vm.typeOptions, (option: TypeOption) => {
            Text(option.label)
              .fontSize(13)
              .fontColor(this.vm.selectedType === option.value ? '#FFFFFF' : '#333333')
              .backgroundColor(this.vm.selectedType === option.value ? '#1890FF' : '#F5F5F5')
              .borderRadius(14)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .margin({ right: 8 })
              .onClick(() => {
                this.vm.selectedType = option.value;
                this.vm.loadCollections();
              })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ top: 8, bottom: 12 })
      .backgroundColor('#FFFFFF')

      // 列表
      if (this.vm.collections.length === 0) {
        EmptyState({ message: '暂无收藏，点击右下角添加', icon: '📦' })
          .layoutWeight(1)
      } else {
        List() {
          ForEach(this.vm.collections, (item: Collection) => {
            ListItem() {
              Column() {
                Row() {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .layoutWeight(1)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  // 类型标签
                  Text(this.vm.getTypeLabel(item.type))
                    .fontSize(11)
                    .fontColor('#1890FF')
                    .backgroundColor('#E6F7FF')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
                .width('100%')

                // 内容预览
                if (item.content) {
                  Text(item.content)
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('100%')
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 8 })
                }

                // 标签
                if (item.tag) {
                  Text(item.tag)
                    .fontSize(11)
                    .fontColor('#1890FF')
                    .backgroundColor('#E6F7FF')
                    .borderRadius(4)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .margin({ top: 8 })
                }

                // 展开区
                if (this.vm.expandedId === item.id) {
                  Divider()
                    .margin({ top: 12, bottom: 8 })

                  // 扩展信息
                  if (this.vm.getExtraText(item.extra, item.type)) {
                    Text(this.vm.getExtraText(item.extra, item.type)!)
                      .fontSize(13)
                      .fontColor('#999999')
                      .width('100%')
                  }

                  Row() {
                    Blank()
                    Text('删除')
                      .fontSize(14)
                      .fontColor('#FF4D4F')
                      .onClick(() => this.vm.deleteCollection(item.id))
                  }
                  .width('100%')
                  .margin({ top: 12 })
                }

                // 展开/收起按钮
                Row() {
                  Blank()
                  Text(this.vm.expandedId === item.id ? '▲ 收起' : '▼ 展开')
                    .fontSize(12)
                    .fontColor('#999999')
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
                this.vm.expandedId = this.vm.expandedId === item.id ? -1 : item.id;
              })
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
      }

      // 添加按钮
      Button('＋')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontColor('#FFFFFF')
        .backgroundColor('#1890FF')
        .borderRadius(28)
        .position({ x: '85%', y: '80%' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/sentence/CollectionEdit' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
