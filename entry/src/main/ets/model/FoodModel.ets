// 食物项数据模型
export class FoodItem {
  id: string = '';
  name: string = '';
  calories: number = 0; // 热量（千卡）
  quantity: number = 1; // 数量
  unit: string = '份'; // 单位
  time: string = ''; // 时间 HH:mm
  date: string = ''; // 日期 YYYY-MM-DD
  
  constructor(id: string, name: string, calories: number, quantity: number = 1, unit: string = '份', time: string = '', date: string = '') {
    this.id = id;
    this.name = name;
    this.calories = calories;
    this.quantity = quantity;
    this.unit = unit;
    this.time = time || this.getCurrentTime();
    this.date = date || this.getCurrentDate();
  }
  
  private getCurrentTime(): string {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }
  
  private getCurrentDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
}

// 热量统计数据模型
export class CalorieStats {
  date: string = '';
  totalCalories: number = 0;
  goalCalories: number = 2000;
  foodItems: FoodItem[] = [];
  
  constructor(date: string, goalCalories: number = 2000) {
    this.date = date;
    this.goalCalories = goalCalories;
  }
  
  addFoodItem(food: FoodItem): void {
    this.foodItems.push(food);
    this.totalCalories += food.calories;
  }
  
  removeFoodItem(id: string): void {
    const index = this.foodItems.findIndex(item => item.id === id);
    if (index !== -1) {
      this.totalCalories -= this.foodItems[index].calories;
      this.foodItems.splice(index, 1);
    }
  }
  
  getProgressPercentage(): number {
    return Math.min(100, (this.totalCalories / this.goalCalories) * 100);
  }
  
  isGoalExceeded(): boolean {
    return this.totalCalories > this.goalCalories;
  }
}

// 食物存储管理
export class FoodStore {
  private static instance: FoodStore;
  private dailyStats: Map<string, CalorieStats> = new Map();
  private foodItems: FoodItem[] = [];
  
  private constructor() {
    this.loadMockData();
  }
  
  static getInstance(): FoodStore {
    if (!FoodStore.instance) {
      FoodStore.instance = new FoodStore();
    }
    return FoodStore.instance;
  }
  
  // 添加食物项
  addFoodItem(food: FoodItem): void {
    this.foodItems.push(food);
    const date = food.date;
    
    if (!this.dailyStats.has(date)) {
      this.dailyStats.set(date, new CalorieStats(date));
    }
    
    const stats = this.dailyStats.get(date)!;
    stats.addFoodItem(food);
  }
  
  // 获取今日统计数据
  getTodayStats(): CalorieStats {
    const today = this.getCurrentDate();
    if (!this.dailyStats.has(today)) {
      this.dailyStats.set(today, new CalorieStats(today));
    }
    return this.dailyStats.get(today)!;
  }
  
  // 获取今日食物列表
  getTodayFoodItems(): FoodItem[] {
    const today = this.getCurrentDate();
    return this.foodItems.filter(item => item.date === today);
  }
  
  // 获取历史统计数据
  getHistoryStats(): CalorieStats[] {
    return Array.from(this.dailyStats.values())
      .sort((a, b) => b.date.localeCompare(a.date));
  }
  
  // 按日期获取食物列表
  getFoodItemsByDate(date: string): FoodItem[] {
    return this.foodItems.filter(item => item.date === date);
  }
  
  // 删除食物项
  deleteFoodItem(id: string): boolean {
    const index = this.foodItems.findIndex(item => item.id === id);
    if (index !== -1) {
      const food = this.foodItems[index];
      const stats = this.dailyStats.get(food.date);
      if (stats) {
        stats.removeFoodItem(id);
      }
      this.foodItems.splice(index, 1);
      return true;
    }
    return false;
  }
  
  // 更新每日目标
  updateDailyGoal(date: string, goal: number): void {
    if (this.dailyStats.has(date)) {
      this.dailyStats.get(date)!.goalCalories = goal;
    }
  }
  
  // 获取最近7天统计数据
  getWeeklyStats(): CalorieStats[] {
    const stats = this.getHistoryStats();
    return stats.slice(0, 7); // 返回最近7天
  }
  
  // 获取食物类别统计
  getCategoryStats(): Map<string, number> {
    const categoryMap = new Map<string, number>();
    const today = this.getCurrentDate();
    const todayFoods = this.getFoodItemsByDate(today);
    
    todayFoods.forEach(food => {
      const category = this.getFoodCategory(food.name);
      const current = categoryMap.get(category) || 0;
      categoryMap.set(category, current + food.calories);
    });
    
    return categoryMap;
  }
  
  // 简单的食物分类
  private getFoodCategory(foodName: string): string {
    const name = foodName.toLowerCase();
    
    if (name.includes('苹果') || name.includes('香蕉') || name.includes('橙子') || 
        name.includes('水果') || name.includes('蔬菜')) {
      return '水果蔬菜';
    } else if (name.includes('米饭') || name.includes('面条') || name.includes('面包') || 
               name.includes('土豆') || name.includes('谷物')) {
      return '主食';
    } else if (name.includes('鸡肉') || name.includes('牛肉') || name.includes('猪肉') || 
               name.includes('鱼') || name.includes('肉')) {
      return '蛋白质';
    } else if (name.includes('牛奶') || name.includes('酸奶') || name.includes('奶酪')) {
      return '乳制品';
    } else if (name.includes('蛋糕') || name.includes('巧克力') || name.includes('饼干') || 
               name.includes('零食')) {
      return '零食甜点';
    } else if (name.includes('水') || name.includes('茶') || name.includes('咖啡') || 
               name.includes('饮料')) {
      return '饮品';
    } else {
      return '其他';
    }
  }
  
  private getCurrentDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }
  
  // 加载模拟数据
  private loadMockData(): void {
    const today = this.getCurrentDate();
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = `${yesterday.getFullYear()}-${(yesterday.getMonth() + 1).toString().padStart(2, '0')}-${yesterday.getDate().toString().padStart(2, '0')}`;
    
    // 今天的数据
    const todayFoods = [
      new FoodItem('1', '苹果', 52, 1, '个', '08:30', today),
      new FoodItem('2', '米饭', 130, 1, '碗', '12:00', today),
      new FoodItem('3', '鸡胸肉', 165, 150, '克', '18:00', today),
      new FoodItem('4', '牛奶', 120, 1, '杯', '07:30', today),
      new FoodItem('5', '沙拉', 80, 1, '份', '12:30', today)
    ];
    
    // 昨天的数据
    const yesterdayFoods = [
      new FoodItem('6', '燕麦粥', 150, 1, '碗', '08:00', yesterdayStr),
      new FoodItem('7', '三明治', 320, 1, '个', '12:30', yesterdayStr),
      new FoodItem('8', '蔬菜汤', 90, 1, '碗', '18:30', yesterdayStr),
      new FoodItem('9', '香蕉', 105, 1, '根', '10:00', yesterdayStr)
    ];
    
    // 添加到存储
    todayFoods.forEach(food => this.addFoodItem(food));
    yesterdayFoods.forEach(food => this.addFoodItem(food));
  }
}