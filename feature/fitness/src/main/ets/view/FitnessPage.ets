/**
 * 健身计划列表页
 */
import { router } from '@kit.ArkUI';
import { FitnessPlan, FitnessCheckin } from 'core.model';
import { relationalStore } from '@kit.ArkData';
import { DbHelper } from 'core.database';
import { DateUtil } from 'core.util';
import { EmptyState } from 'core.ui';

@Entry
@Component
struct FitnessPage {
  @State plans: FitnessPlan[] = [];
  @State todayPlans: FitnessPlan[] = [];
  @State isLoading: boolean = false;

  aboutToAppear() {
    this.loadPlans();
  }

  async loadPlans() {
    this.isLoading = true;
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const predicates = new relationalStore.RdbPredicates('fitness_plan');
      predicates.orderByAsc('weekDay');
      
      const result = await store.query(predicates);
      this.plans = this.parsePlans(result);
      
      // 筛选今日计划
      const today = DateUtil.getTodayWeekDay();
      this.todayPlans = this.plans.filter(p => p.weekDay === today);
    } catch (e) {
      console.error('Load fitness plans failed:', e);
    } finally {
      this.isLoading = false;
    }
  }

  async checkin(planId: number) {
    try {
      const store = DbHelper.getInstance().getRdbStore();
      const today = DateUtil.getToday();
      
      // 检查今日是否已打卡
      const predicates = new relationalStore.RdbPredicates('fitness_checkin');
      predicates.equalTo('planId', planId);
      predicates.equalTo('date', today);
      
      const result = await store.query(predicates);
      if (result.goToFirstRow()) {
        // 已打卡，取消打卡
        const checkinId = result.getLong(result.getColumnIndex('id'));
        await store.delete('fitness_checkin', new relationalStore.RdbPredicates('fitness_checkin').equalTo('id', checkinId));
      } else {
        // 未打卡，添加打卡记录
        const valueBucket: relationalStore.ValuesBucket = {
          planId: planId,
          date: today,
          completed: 1,
          createTime: DateUtil.getNow()
        };
        await store.insert('fitness_checkin', valueBucket);
      }
      result.close();
      this.loadPlans();
    } catch (e) {
      console.error('Checkin failed:', e);
    }
  }

  private parsePlans(result: relationalStore.ResultSet): FitnessPlan[] {
    const list: FitnessPlan[] = [];
    while (result.goToNextRow()) {
      const plan = new FitnessPlan();
      plan.id = result.getLong(result.getColumnIndex('id'));
      plan.name = result.getString(result.getColumnIndex('name'));
      plan.weekDay = result.getLong(result.getColumnIndex('weekDay'));
      plan.exercises = result.getString(result.getColumnIndex('exercises'));
      list.push(plan);
    }
    result.close();
    return list;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('健身计划')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')

      // 今日计划
      Column() {
        Row() {
          Text('今日计划')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          Text(DateUtil.getWeekDayName(DateUtil.getTodayWeekDay()))
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')

        if (this.todayPlans.length === 0) {
          EmptyState({ message: '今日暂无健身计划', icon: '💪' })
            .height(120)
        } else {
          List() {
            ForEach(this.todayPlans, (plan: FitnessPlan) => {
              ListItem() {
                this.planItem(plan, true)
              }
            })
          }
          .padding({ left: 16, right: 16 })
        }
      }
      .margin({ top: 8 })

      // 全部计划
      Column() {
        Text('全部计划')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')

        if (this.plans.length === 0) {
          EmptyState({ message: '暂无健身计划，点击下方添加', icon: '🏋️' })
            .height(200)
        } else {
          List() {
            ForEach(this.plans, (plan: FitnessPlan) => {
              ListItem() {
                this.planItem(plan, false)
              }
            })
          }
          .padding({ left: 16, right: 16 })
        }
      }
      .layoutWeight(1)
      .margin({ top: 8 })

      // 悬浮按钮
      Button('＋')
        .width(56)
        .height(56)
        .fontSize(28)
        .fontColor('#FFFFFF')
        .backgroundColor('#1890FF')
        .borderRadius(28)
        .position({ x: '85%', y: '80%' })
        .onClick(() => {
          router.pushUrl({ url: 'pages/fitness/FitnessEdit' });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder
  planItem(plan: FitnessPlan, showCheckin: boolean) {
    Row() {
      Column() {
        Text(plan.name)
          .fontSize(16)
          .fontColor('#333333')
        
        Text(DateUtil.getWeekDayName(plan.weekDay))
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      if (showCheckin) {
        Button('打卡')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#52C41A')
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .onClick(() => this.checkin(plan.id))
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 8 })
  }
}
