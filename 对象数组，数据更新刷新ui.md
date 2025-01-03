# HarmonyOS next之对象数组，数据更新刷新ui

### 前言

对象数组是一种在编程中极为常用的数据结构，它能高效地存储和处理一组相关的对象。在鸿蒙 Next 中，这种数据结构有着广泛的应用。

比如在开发一个简单的联系人管理应用时，我们可以使用对象数组。每个联系人是一个对象，对象包含姓名、电话、邮箱等属性。像这样：

```js
[
    {name: ' 张三 ', phone: '123456789', email: 'zhangsan@example.com'}, 
    {name: ' 李四 ', phone: '987654321', email: 'lisi@example.com'},
]
```

通过这种对象数组结构，方便对联系人数据进行遍历、查找、添加和删除等操作，有效管理联系人信息。

在鸿蒙 next 中，使用对象数组循环生成列表时会有特殊情况。当列表中的某个对象更新数据，令人意外的是，这并不会促使 ui 页面刷新。这种现象与我们通常的预期不同，可能会在开发过程中带来一些困扰，开发者需要特别留意这一特性，以便在遇到相关问题时，能准确地分析和解决，确保应用的 ui 显示与数据状态的一致性。

为了解决这个问题我们可以采取一些措施

### 直接赋值不会刷新ui

例如：

```js
@Entry
@Component
struct ViewB {
  // ViewB中有@State装饰的ClassA[]
  @State arrA: ClassA[] = [{name: ' 张三 ', phone: '123456789'}， {name: ' 李四 ', phone: '987654321'}];

  build() {
      ForEach(this.arrA, (item: ClassA, index: number) => {
          Text(item.phone)
          Button(`改变号码为888888`)
              .width(320)
              .margin(10)
              .onClick(() => {
              		this.arrA[index].phone = '888888';
          	   })
      },
  }
 }
```

### 赋值后将对象重新结构赋值能够刷新ui

例如：

```js
@Entry
@Component
struct ViewB {
  // ViewB中有@State装饰的ClassA[]
  @State arrA: ClassA[] = [{name: ' 张三 ', phone: '123456789'}， {name: ' 李四 ', phone: '987654321'}];

  build() {
      ForEach(this.arrA, (item: ClassA, index: number) => {
          Text(item.phone)
          Button(`改变号码为888888`)
              .width(320)
              .margin(10)
              .onClick(() => {
              		this.arrA[index].phone = '888888';
              		// 解构重新赋值
              		this.arrA = [...this.arrA];
          	   })
      },
  }
 }
```

通过这个 demo，我们知晓了对象数组的即时刷新情况。但这里仍存在一些小问题，在页面刷新数据时，由于数组重新赋值，整个列表会闪烁一下。这一闪烁现象可能会影响用户体验，尤其是在对视觉效果要求较高的应用场景中。不过别担心，我们已经关注到这个问题，下一期内容将为大家详细讲解如何解决这个列表闪烁问题，帮助开发者进一步优化鸿蒙 Next 应用的用户界面表现。
