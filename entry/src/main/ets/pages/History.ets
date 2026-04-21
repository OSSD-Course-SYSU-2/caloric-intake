import { CalorieStats, FoodStore, FoodItem } from '../model/FoodModel';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct History {
  @State historyStats: CalorieStats[] = [];
  @State selectedDate: string = '';
  @State foodItems: FoodItem[] = [];
  @State showDatePicker: boolean = false;
  @State selectedStats: CalorieStats | null = null;
  
  private foodStore = FoodStore.getInstance();
  
  aboutToAppear() {
    this.loadHistoryData();
  }
  
  loadHistoryData() {
    this.historyStats = this.foodStore.getHistoryStats();
    if (this.historyStats.length > 0) {
      this.selectedDate = this.historyStats[0].date;
      this.loadFoodItemsForDate(this.selectedDate);
      this.selectedStats = this.historyStats[0];
    }
  }
  
  loadFoodItemsForDate(date: string) {
    this.foodItems = this.foodStore.getFoodItemsByDate(date);
  }
  
  formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    const today = new Date();
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    
    if (date.toDateString() === today.toDateString()) {
      return '今天';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return '昨天';
    } else {
      const month = date.getMonth() + 1;
      const day = date.getDate();
      return `${month}月${day}日`;
    }
  }
  
  getWeekday(dateStr: string): string {
    const date = new Date(dateStr);
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[date.getDay()];
  }
  
  getProgressColor(progress: number): string {
    if (progress >= 100) {
      return '#FF3B30'; // 红色，超过目标
    } else if (progress >= 80) {
      return '#FF9500'; // 橙色，接近目标
    } else {
      return '#34C759'; // 绿色，正常
    }
  }
  
  build() {
    Stack() {
      Column() {
        // 标题栏
        Row() {
          Button($r('app.string.back'))
          .width(60)
          .height(40)
          .fontSize(14)
          .backgroundColor('transparent')
          .fontColor('#666666')
          .onClick(() => {
            router.back();
          })
        
        Text($r('app.string.history'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 'auto', right: 'auto' })
        
        Button($r('app.string.filter'))
          .width(60)
          .height(40)
          .fontSize(14)
          .backgroundColor('transparent')
          .fontColor('#007DFF')
          .onClick(() => {
            this.showDatePicker = true;
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor('#F5F5F5')
      
      if (this.historyStats.length === 0) {
        // 空状态
        Column() {
          // 使用文本代替图标
          Text('📊')
            .fontSize(60)
            .margin({ bottom: 20 })
          
          Text($r('app.string.no_history'))
            .fontSize(18)
            .fontColor('#999999')
            .margin({ bottom: 10 })
          
          Text($r('app.string.start_record'))
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          Column({ space: 16 }) {
            // 日期选择器
            Row() {
              Text(this.formatDate(this.selectedDate))
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              
              Text(this.getWeekday(this.selectedDate))
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 8 })
              
              // 使用文本代替图标
              Text('📅')
                .fontSize(18)
                .margin({ left: 'auto' })
                .onClick(() => {
                  this.showDatePicker = true;
                })
            }
            .width('90%')
            .padding({ top: 20 })
            
            // 热量统计卡片
            if (this.selectedStats) {
              Column() {
                Row() {
                  Column() {
                    Text($r('app.string.total_intake'))
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.selectedStats.totalCalories}`)
                      .fontSize(32)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#007DFF')
                    Text($r('app.string.kcal'))
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text($r('app.string.daily_goal'))
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.selectedStats.goalCalories}`)
                      .fontSize(32)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                    Text($r('app.string.kcal'))
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .layoutWeight(1)
                  
                  Column() {
                    Text($r('app.string.difference'))
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.selectedStats.totalCalories - this.selectedStats.goalCalories}`)
                      .fontSize(32)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.selectedStats.totalCalories > this.selectedStats.goalCalories ? '#FF3B30' : '#34C759')
                    Text($r('app.string.kcal'))
                      .fontSize(12)
                      .fontColor('#999999')
                  }
                  .layoutWeight(1)
                }
                .margin({ top: 16, bottom: 20 })
                
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
                    .width(`${this.selectedStats.getProgressPercentage()}%`)
                    .height(8)
                    .backgroundColor(this.getProgressColor(this.selectedStats.getProgressPercentage()))
                    .borderRadius(4)
                }
                .width('100%')
                .margin({ bottom: 8 })
                
                // 进度文本
                Row() {
                  Text(`${this.selectedStats.getProgressPercentage().toFixed(1)}%`)
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text(this.selectedStats.isGoalExceeded() ? '（已超出目标）' : '（未达目标）')
                    .fontSize(14)
                    .fontColor(this.selectedStats.isGoalExceeded() ? '#FF3B30' : '#34C759')
                    .margin({ left: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .width('90%')
              .padding(20)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .shadow({ radius: 8, color: '#000000', offsetX: 0, offsetY: 2 })
            }
            
            // 食物列表标题
            Row() {
              Text('食物记录')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              
              Text(`${this.foodItems.length}项`)
                .fontSize(14)
                .fontColor('#999999')
                .margin({ left: 8 })
            }
            .width('90%')
            .margin({ top: 20 })
            
            // 食物列表
            if (this.foodItems.length === 0) {
              Column() {
                // 使用文本代替图标
                Text('🍽️')
                  .fontSize(40)
                  .margin({ bottom: 16 })
                
                Text('该日期无食物记录')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('90%')
              .height(200)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
            } else {
              List({ space: 10 }) {
                ForEach(this.foodItems, (item: FoodItem, index: number) => {
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
                        // 使用文本代替图标
                        Text('🗑️')
                          .fontSize(14)
                          .onClick(() => {
                            // 删除食物项
                            this.foodStore.deleteFoodItem(item.id);
                            this.loadHistoryData();
                            promptAction.showToast({ message: '已删除', duration: 1500 });
                          })
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
            }
            
            // 历史日期列表
            Column({ space: 12 }) {
              Text('历史日期')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .width('90%')
                .textAlign(TextAlign.Start)
              
              ForEach(this.historyStats, (stats: CalorieStats) => {
                ListItem() {
                  Row() {
                    Column({ space: 2 }) {
                      Text(this.formatDate(stats.date))
                        .fontSize(16)
                        .fontColor('#333333')
                      
                      Text(this.getWeekday(stats.date))
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .layoutWeight(1)
                    
                    Column({ space: 2 }) {
                      Text(`${stats.totalCalories}千卡`)
                        .fontSize(16)
                        .fontColor(stats.isGoalExceeded() ? '#FF3B30' : '#34C759')
                      
                      Text(`${$r('app.string.daily_goal')}: ${stats.goalCalories}${$r('app.string.kcal')}`)
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    
                    // 使用文本代替图标
                    Text('➡️')
                      .fontSize(14)
                      .margin({ left: 12 })
                  }
                  .width('100%')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .backgroundColor('#FFFFFF')
                  .borderRadius(12)
                  .onClick(() => {
                    this.selectedDate = stats.date;
                    this.selectedStats = stats;
                    this.loadFoodItemsForDate(stats.date);
                  })
                }
              })
            }
            .width('90%')
            .margin({ top: 20, bottom: 40 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Off)
        .width('100%')
        .height('100%')
      }
    }
  }
  .width('100%')
  .height('100%')
  .backgroundColor('#F8F8F8')
  }
}