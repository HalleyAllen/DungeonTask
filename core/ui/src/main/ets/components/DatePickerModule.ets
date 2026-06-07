/**
 * 日期选择器公共组件
 * 点击展开年月日三列滚轮，支持确认/清除
 */
@Component
export struct DatePickerModule {
  /** 当前截至日期时间戳(ms)，0=未设置 */
  @Prop deadline: number = 0;
  /** 格式化后的日期文本 */
  @Prop deadlineText: string = '';
  /** 确认选择回调 */
  onConfirm?: (timestamp: number) => void;
  /** 清除回调 */
  onClear?: () => void;

  /** 选择器是否展开 */
  @State showPicker: boolean = false;

  /** 年份范围 */
  private yearRange: string[] = [];
  /** 月份范围 */
  private monthRange: string[] = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  /** 日期范围 */
  private dayRange: string[] = [];

  /** 当前选中年 */
  @State pickerYear: number = 0;
  /** 当前选中月 */
  @State pickerMonth: number = 0;
  /** 当前选中日 */
  @State pickerDay: number = 0;

  aboutToAppear(): void {
    // 构建范围
    for (let y = 2020; y <= 2035; y++) {
      this.yearRange.push(String(y));
    }
    for (let d = 1; d <= 31; d++) {
      this.dayRange.push(String(d));
    }
    this.initPicker();
  }

  /** 初始化选中值为当前deadline或今天 */
  private initPicker(): void {
    if (this.deadline > 0) {
      const d = new Date(this.deadline);
      this.pickerYear = d.getFullYear();
      this.pickerMonth = d.getMonth() + 1;
      this.pickerDay = d.getDate();
    } else {
      const now = new Date();
      this.pickerYear = now.getFullYear();
      this.pickerMonth = now.getMonth() + 1;
      this.pickerDay = now.getDate();
    }
  }

  /** 确认选择 */
  private confirm(): void {
    const date = new Date(this.pickerYear, this.pickerMonth - 1, this.pickerDay);
    const timestamp = date.getTime();
    if (this.onConfirm) {
      this.onConfirm(timestamp);
    }
    this.showPicker = false;
  }

  /** 清除 */
  private clear(): void {
    if (this.onClear) {
      this.onClear();
    }
    this.showPicker = false;
  }

  build() {
    Column() {
      // 触发行
      Row() {
        Text(this.deadlineText || '选择日期（可选）')
          .fontSize(15)
          .fontColor(this.deadlineText ? '#1F1F1F' : '#A6A6A6')
          .layoutWeight(1)

        if (this.deadlineText) {
          Text('清除')
            .fontSize(13)
            .fontColor('#FF4D4F')
            .margin({ right: 8 })
            .onClick(() => this.clear())
        }

        Text('📅')
          .fontSize(18)
      }
      .width('100%')
      .height(48)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .padding({ left: 12, right: 12 })
      .onClick(() => {
        this.initPicker();
        this.showPicker = !this.showPicker;
      })

      // 选择器面板
      if (this.showPicker) {
        Column() {
          Row() {
            TextPicker({ range: this.yearRange, selected: this.yearRange.indexOf(String(this.pickerYear)) })
              .layoutWeight(1)
              .onChange((value: string | string[]) => {
                this.pickerYear = parseInt(value as string);
              })

            TextPicker({ range: this.monthRange, selected: this.pickerMonth - 1 })
              .layoutWeight(1)
              .onChange((value: string | string[]) => {
                this.pickerMonth = parseInt(value as string);
              })

            TextPicker({ range: this.dayRange, selected: this.pickerDay - 1 })
              .layoutWeight(1)
              .onChange((value: string | string[]) => {
                this.pickerDay = parseInt(value as string);
              })
          }
          .width('100%')
          .height(160)
          .margin({ top: 12 })

          Row() {
            Text('不设截止')
              .fontSize(14)
              .fontColor('#A6A6A6')
              .onClick(() => this.clear())

            Blank()

            Text('确定')
              .fontSize(14)
              .fontColor('#1677FF')
              .fontWeight(FontWeight.Medium)
              .onClick(() => this.confirm())
          }
          .width('100%')
          .margin({ top: 12, bottom: 4 })
        }
      }
    }
  }
}
