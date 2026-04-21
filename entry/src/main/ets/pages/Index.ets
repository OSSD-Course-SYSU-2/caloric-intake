import { FoodItem, FoodStore } from '../model/FoodModel';
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State dailyCalories: number = 0;
  @State dailyGoal: number = 2000;
  @State foodList: FoodItem[] = [];
  @State progress: number = 0;
  
  private foodStore = FoodStore.getInstance();
  
  aboutToAppear() {
    this.loadFoodData();
    this.calculateDailyCalories();
  }
  
  loadFoodData() {
    this.foodList = this.foodStore.getTodayFoodItems();
  }
  
  calculateDailyCalories() {
    const todayStats = this.foodStore.getTodayStats();
    this.dailyCalories = todayStats.totalCalories;
    this.progress = todayStats.getProgressPercentage();
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Text($r('app.string.app_name'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Button($r('app.string.add_food'))
          .width(80)
          .height(40)
          .fontSize(14)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .margin({ left: 'auto' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddFood' });
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 20 })
      .backgroundColor('#F5F5F5')
      
      // 热量统计卡片
      Column() {
        Row() {
          Column() {
            Text($r('app.string.today_intake'))
              .fontSize(16)
              .fontColor('#666666')
            Text(`${this.dailyCalories}`)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#007DFF')
            Text($r('app.string.kcal'))
              .fontSize(14)
              .fontColor('#999999')
          }
          .margin({ right: 40 })
          
          Column() {
            Text($r('app.string.daily_goal'))
              .fontSize(16)
              .fontColor('#666666')
            Text(`${this.dailyGoal}`)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            Text($r('app.string.kcal'))
              .fontSize(14)
              .fontColor('#999999')
          }
        }
        .margin({ top: 20, bottom: 20 })
        
        // 进度条
        Stack() {
          // 背景条
          Row()
            .width('100%')
            .height(8)
            .backgroundColor('#E0E0E0')
            .borderRadius(4)
          
          // 进度条
          Row()
            .width(`${this.progress}%`)
            .height(8)
            .backgroundColor(this.progress > 100 ? '#FF3B30' : '#34C759')
            .borderRadius(4)
        }
        .width('100%')
        .margin({ bottom: 10 })
        
        // 进度文本
        Row() {
          Text(this.progress >= 100 ? '已超出目标' : `${this.progress.toFixed(1)}%`)
            .fontSize(14)
            .fontColor(this.progress >= 100 ? '#FF3B30' : '#666666')
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: '#000000', offsetX: 0, offsetY: 2 })
      .margin({ top: 10, bottom: 20 })
      
      // 今日食物列表标题
      Row() {
        Text($r('app.string.food_record'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Button($r('app.string.history'))
          .width(60)
          .height(30)
          .fontSize(12)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .margin({ left: 'auto' })
          .onClick(() => {
            router.pushUrl({ url: 'pages/History' });
          })
      }
      .width('90%')
      .margin({ bottom: 10 })
      
      // 食物列表
      List({ space: 10 }) {
        ForEach(this.foodList, (item: FoodItem) => {
          ListItem() {
            Row() {
              Column({ space: 5 }) {
                Text(item.name)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#333333')
                
                Row() {
                  Text(`${item.calories}千卡`)
                    .fontSize(12)
                    .fontColor('#666666')
                  Text('·')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ left: 5, right: 5 })
                  Text(`${item.quantity}${item.unit}`)
                    .fontSize(12)
                    .fontColor('#666666')
                }
              }
              
              Column({ space: 2 }) {
                Text(item.time)
                  .fontSize(12)
                  .fontColor('#999999')
                Text('')
                  .fontSize(12)
                  .fontColor('#999999')
              }
              .margin({ left: 'auto' })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .shadow({ radius: 4, color: '#000000', offsetX: 0, offsetY: 1 })
          }
        })
      }
      .width('90%')
      .height(300)
      .margin({ bottom: 20 })
      
      // 快速添加按钮
      Row() {
        Button(`+ ${$r('app.string.quick_add')}`)
          .width('100%')
          .height(50)
          .fontSize(16)
          .backgroundColor('#007DFF')
          .fontColor('#FFFFFF')
          .borderRadius(25)
          .onClick(() => {
            router.pushUrl({ url: 'pages/AddFood' });
          })
      }
      .width('90%')
      .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
    .alignItems(HorizontalAlign.Center)
  }
}