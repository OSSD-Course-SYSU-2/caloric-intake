import { FoodItem, FoodStore } from '../model/FoodModel';
import router from '@ohos.router';
import prompt from '@ohos.promptAction';

class SelectOption {
  value: string;
  
  constructor(value: string) {
    this.value = value;
  }
}

class CommonFood {
  name: string;
  calories: number;
  
  constructor(name: string, calories: number) {
    this.name = name;
    this.calories = calories;
  }
}

@Entry
@Component
struct AddFood {
  @State foodName: string = '';
  @State calories: string = '';
  @State quantity: string = '1';
  @State unit: string = '份';
  @State selectedTime: string = '';
  @State showTimePicker: boolean = false;
  
  private foodStore = FoodStore.getInstance();
  private units: SelectOption[] = [
    new SelectOption('份'),
    new SelectOption('个'),
    new SelectOption('碗'),
    new SelectOption('克'),
    new SelectOption('毫升'),
    new SelectOption('杯'),
    new SelectOption('片'),
    new SelectOption('块')
  ];
  
  private commonFoods: CommonFood[] = [
    new CommonFood('苹果', 52),
    new CommonFood('香蕉', 89),
    new CommonFood('米饭', 130),
    new CommonFood('面条', 138),
    new CommonFood('鸡蛋', 78),
    new CommonFood('鸡胸肉', 165),
    new CommonFood('牛肉', 250),
    new CommonFood('牛奶', 42),
    new CommonFood('面包', 265),
    new CommonFood('蔬菜沙拉', 35)
  ];
  
  aboutToAppear() {
    this.setCurrentTime();
  }
  
  setCurrentTime() {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    this.selectedTime = `${hours}:${minutes}`;
  }
  
  saveFood() {
    if (!this.foodName.trim()) {
      prompt.showToast({ message: '请输入食物名称', duration: 2000 });
      return;
    }
    
    if (!this.calories.trim() || isNaN(Number(this.calories))) {
      prompt.showToast({ message: '请输入有效的热量值', duration: 2000 });
      return;
    }
    
    const foodItem = new FoodItem(
      Date.now().toString(),
      this.foodName.trim(),
      Number(this.calories),
      Number(this.quantity) || 1,
      this.unit,
      this.selectedTime,
      new Date().toISOString().split('T')[0]
    );
    
    this.foodStore.addFoodItem(foodItem);
    prompt.showToast({ message: '食物添加成功', duration: 1500 });
    
    // 返回上一页
    setTimeout(() => {
      router.back();
    }, 1500);
  }
  
  resetForm() {
    this.foodName = '';
    this.calories = '';
    this.quantity = '1';
    this.unit = '份';
    this.setCurrentTime();
  }
  
  cancel() {
    router.back();
  }
  
  build() {
    Column() {
      // 标题栏
      Row() {
        Button($r('app.string.cancel'))
          .width(60)
          .height(40)
          .fontSize(14)
          .backgroundColor('transparent')
          .fontColor('#666666')
          .onClick(() => this.cancel())
        
        Text($r('app.string.add_food'))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 'auto', right: 'auto' })
        
        Button($r('app.string.save'))
          .width(60)
          .height(40)
          .fontSize(14)
          .backgroundColor('transparent')
          .fontColor('#007DFF')
          .onClick(() => this.saveFood())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor('#F5F5F5')
      
      // 表单内容
      Scroll() {
        Column({ space: 20 }) {
          // 食物名称
          Column({ space: 8 }) {
            Text($r('app.string.food_name'))
              .fontSize(16)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .width('100%')
            
            TextInput({ placeholder: '请输入食物名称，如：苹果、米饭' })
              .width('100%')
              .height(48)
              .fontSize(16)
              .borderRadius(8)
              .backgroundColor('#FFFFFF')
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.foodName = value;
              })
          }
          .width('90%')
          
          // 热量输入
          Column({ space: 8 }) {
            Text($r('app.string.calories'))
              .fontSize(16)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .width('100%')
            
            TextInput({ placeholder: '请输入热量值，如：52' })
              .width('100%')
              .height(48)
              .fontSize(16)
              .borderRadius(8)
              .backgroundColor('#FFFFFF')
              .padding({ left: 12, right: 12 })
              .type(InputType.Number)
              .onChange((value: string) => {
                this.calories = value;
              })
          }
          .width('90%')
          
          // 数量和单位
          Row({ space: 12 }) {
            Column({ space: 8 }) {
              Text($r('app.string.quantity'))
                .fontSize(16)
                .fontColor('#333333')
                .textAlign(TextAlign.Start)
                .width('100%')
              
              TextInput({ placeholder: '1' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .borderRadius(8)
                .backgroundColor('#FFFFFF')
                .padding({ left: 12, right: 12 })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.quantity = value;
                })
            }
            .layoutWeight(1)
            
            Column({ space: 8 }) {
              Text($r('app.string.unit'))
                .fontSize(16)
                .fontColor('#333333')
                .textAlign(TextAlign.Start)
                .width('100%')
              
              Select(this.units)
                .selected(0)
                .value(this.unit)
                .width('100%')
                .height(48)
                .borderRadius(8)
                .backgroundColor('#FFFFFF')
                .padding({ left: 12, right: 12 })
                .onSelect((index: number) => {
                  this.unit = this.units[index].value;
                })
            }
            .layoutWeight(1)
          }
          .width('90%')
          
          // 时间选择
          Column({ space: 8 }) {
            Text($r('app.string.meal_time'))
              .fontSize(16)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .width('100%')
            
            Row() {
              Text(this.selectedTime)
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)
              
              Text('🕐')
                .fontSize(20)
                .onClick(() => {
                  // 简化处理，直接设置当前时间
                  const now = new Date();
                  const hours = now.getHours().toString().padStart(2, '0');
                  const minutes = now.getMinutes().toString().padStart(2, '0');
                  this.selectedTime = `${hours}:${minutes}`;
                })
            }
            .width('100%')
            .height(48)
            .borderRadius(8)
            .backgroundColor('#FFFFFF')
            .padding({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center)
          }
          .width('90%')
          
          // 常见食物参考
          Column({ space: 12 }) {
            Text($r('app.string.food_reference'))
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .textAlign(TextAlign.Start)
              .width('100%')
            
            // 常见食物列表
            Column({ space: 8 }) {
              ForEach(this.commonFoods, (food: CommonFood, index: number) => {
                Row() {
                  Text(food.name)
                    .fontSize(14)
                    .fontColor('#333333')
                    .layoutWeight(1)
                  
                  Text(`${food.calories}千卡`)
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text('+')
                    .fontSize(20)
                    .fontColor('#007DFF')
                    .margin({ left: 12 })
                    .onClick(() => {
                      this.foodName = food.name;
                      this.calories = food.calories.toString();
                      prompt.showToast({ message: `已填充 ${food.name}`, duration: 1500 });
                    })
                }
                .width('100%')
                .height(44)
                .padding({ left: 12, right: 12 })
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .alignItems(VerticalAlign.Center)
                .shadow({ radius: 2, color: '#000000', offsetX: 0, offsetY: 1 })
              })
            }
          }
          .width('90%')
        }
        .width('100%')
        .padding({ top: 20, bottom: 40 })
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      
      // 底部保存按钮
      Button($r('app.string.save'))
        .width('90%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .fontColor('#FFFFFF')
        .borderRadius(25)
        .margin({ bottom: 30 })
        .onClick(() => this.saveFood())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}