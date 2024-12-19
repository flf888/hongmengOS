

# 鸿蒙 next Scroll() 无法滚动问题

在鸿蒙 next 中遇到了Scroll无法滚动的问题，明明元素已经超出屏幕了，但是就是不可以滚动，通过查询鸿蒙 next 的社区反馈得知了 Scroll 无法滚动的原因。

鸿蒙 next scroll 官方文档: [https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-container-scroll-V5](https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/ts-container-scroll-V5)





## 可以滚动的代码:

```JavaScript
Scroll() {
  Column() {}
}.height('100%')
```



## 不可以滚动的代码

```JavaScript
Scroll() {
  //先要写页面的框框 大部分都是 Column
  Column() {}.height('100%')
}.height('100%')
```



## 原因是:

```JavaScript
因为Scroll是根据其直接子组件的高度是否超出其高度判断是否开启滚动，设定100%后Column就与Scroll同高了，不会出现超出情况，也就不会开启滚动，而Column内部UI超出Column高度只是画出屏幕外，不能影响Scroll的判断，若有屏幕延伸可看到超出的部分画出Column外，但Scoll不知道：）
```





## 总结:

```JavaScript
以后遇到不滚动的问题，可以看子元素是否有高度设置成100% 的情况
```

