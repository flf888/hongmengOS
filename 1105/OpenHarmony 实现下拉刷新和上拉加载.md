#   HarmonyOS next之OpenHarmony 实现下拉刷新和上拉加载

下拉刷新、上拉加载功能是我们开发app中最常用的功能,本文通过PullToRefresh来实现这一基本的功能.

**简介**

PullToRefresh是一款OpenHarmony环境下可用的下拉刷新、上拉加载组件。 支持设置内置动画的各种属性，支持设置自定义动画，支持lazyForEarch的数据作为数据源。

**下载安装**

```
ohpm install @ohos/pulltorefresh
```

 **快速使用**

```
// V1装饰器下的使用方式
import { PullToRefresh } from '@ohos/pulltorefresh'

// 需绑定列表或宫格组件
private scroller: Scroller = new Scroller();
  
PullToRefresh({
// 必传项，列表组件所绑定的数据
data: $data,
// 必传项，需绑定传入主体布局内的列表或宫格组件
scroller: this.scroller,
// 必传项，自定义主体布局，内部有列表或宫格组件
customList: () => {
  // 一个用@Builder修饰过的UI方法
  this.getListView();
},
// 可选项，下拉刷新回调
onRefresh: () => {
  return new Promise<string>((resolve, reject) => {
    // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
    setTimeout(() => {
      resolve('刷新成功');
      this.data = [...this.dataNumbers];
    }, 2000);
  });
},
// 可选项，上拉加载更多回调
onLoadMore: () => {
  return new Promise<string>((resolve, reject) => {
    // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
    setTimeout(() => {
      resolve('');
      this.data.push("增加的条目" + this.data.length);
    }, 2000);
  });
},
customLoad: null,
customRefresh: null,
})

// V2装饰器下的使用方式
import { PullToRefreshV2 } from '@ohos/pulltorefresh'

// 需绑定列表或宫格组件
private scroller: Scroller = new Scroller();

PullToRefreshV2({
   // 可选项，列表组件所绑定的数据
   data: this.data,
   // 必传项，需绑定传入主体布局内的列表或宫格组件
   scroller: this.scroller,
   // 必传项，自定义主体布局，内部有列表或宫格组件
   customList: () => {
      // 一个用@Builder修饰过的UI方法
      this.getListView();
   },
   // 可选项，下拉刷新回调
   onRefresh: () => {
      return new Promise<string>((resolve, reject) => {
         // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
         setTimeout(() => {
            resolve('刷新成功');
            this.data = [...this.dataNumbers];
         }, 2000);
      });
   },
   // 可选项，上拉加载更多回调
   onLoadMore: () => {
      return new Promise<string>((resolve, reject) => {
         // 模拟网络请求操作，请求网络2秒后得到数据，通知组件，变更列表数据
         setTimeout(() => {
            resolve('');
            this.data.push("增加的条目" + this.data.length);
         }, 2000);
      });
   },
   customLoad: null,
   customRefresh: null,
})
```

**使用限制**

1、目前只支持List、Scroll、Tabs、Grid和WaterFlow系统容器组件；

2、暂不支持设置系统容器组件的弹簧效果和阴影效果，使用时需要将系统组件edgeEffect属性的值设置为(EdgeEffect.None)；

3、暂不支持页面触底时自动触发上拉加载功能；

4、暂不支持在页面数据不满一屏时触发上拉加载功能；

5、暂不支持通过代码的方式去触发下拉刷新功能；

6、暂不支持在下拉刷新动画结束时提供手势结束的回调；



**支持lazyForEarch的数据作为数据源**

LazyForEach从提供的数据源中按需迭代数据，并在每次迭代过程中创建相应的组件。当LazyForEach在滚动容器中使用了，框架会根据滚动容器可视区域按需创建组件，当组件滑出可视区域外时，框架会进行组件销毁回收以降低内存占用 接口描述：

```
LazyForEach(
    dataSource: IDataSource,             // 需要进行数据迭代的数据源
    itemGenerator: (item: any, index?: number) => void,  // 子组件生成函数
    keyGenerator?: (item: any, index?: number) => string // 键值生成函数
): void
```



**IDataSource类型说明**

```
interface IDataSource {
    totalCount(): number; // 获得数据总数
    getData(index: number): Object; // 获取索引值对应的数据
    registerDataChangeListener(listener: DataChangeListener): void; // 注册数据改变的监听器
    unregisterDataChangeListener(listener: DataChangeListener): void; // 注销数据改变的监听器
}
```

**DataChangeListener类型说明**

```
interface DataChangeListener {
    onDataReloaded(): void; // 重新加载数据时调用
    onDataAdded(index: number): void; // 添加数据时调用
    onDataMoved(from: number, to: number): void; // 数据移动起始位置与数据移动目标位置交换时调用
    onDataDeleted(index: number): void; // 删除数据时调用
    onDataChanged(index: number): void; // 改变数据时调用
    onDataAdd(index: number): void; // 添加数据时调用
    onDataMove(from: number, to: number): void; // 数据移动起始位置与数据移动目标位置交换时调用
    onDataDelete(index: number): void; // 删除数据时调用
    onDataChange(index: number): void; // 改变数据时调用
}
```

 

**约束与限制**

在下述版本验证通过：

- `DevEco Studio: NEXT Beta1-5.0.3.806, SDK: API12 Release(5.0.0.66)`
