

# 鸿蒙 next 判断 Swiper 是否在最后一个元素并向右滑动与在第一个元素并向左滑动



要实现 Swiper 在最后一个元素的同时判断是否向右滑动，可以利用 Swiper 的 `onAnimationStart`方法，该方法是会在手势滑动开始时调用，其回调参数是: `(index: number, targetIndex: number, extraInfo: SwiperAnimationEvent)`, index 表示的是当前所在的位置，targetIndex 表示的是滑动到的位置，那么就可以利用这两个参数来判断，当 index 在最后时，并且 targetIndex 等于 index 时则可以认为是向右滑动。那么判断逻辑代码如下:

```JavaScript
.onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
              const tempNum = this.examList[this.index].material_length - 1;
              if ( index == targetIndex && index == tempNum) {
                // 最后一个元素向右滑动
                console.log("最后一个元素向右滑动")
              } else if ( index == targetIndex && index == 0) {
                // 第一个元素向左滑动
                console.log("第一个元素向左滑动")
              }
            })
```



上述代码在实际使用中会发一下一个问题，那么就是在第一个元素的同时，向右滑动一点点距离，ui 上是未触发向右滑动的，但上述逻辑会判断成 `第一个元素向左滑动`，所以还需要能够判断手势是在向左滑动的同时才判断 `第一个元素向左滑动`。

判断向左向右滑动就可以利用 `onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => void`来判断，代码如下:

```JavaScript
lastCurrentOffset: number = 0;
curSwiperDirection: "left" | "right" | "" = "";


.onChange((index: number) => {
             // ...... --- 自己的业务逻辑

              this.lastCurrentOffset = 0;
              this.curSwiperDirection = "";
})
.onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
              // LogUtil.info(`onGestureSwipe index:${index}, extraInfo:${JSON.stringify(extraInfo)}`);
              if (this.lastCurrentOffset != 0) {
                // 判断是左滑动还是右滑动
                if (extraInfo.currentOffset < this.lastCurrentOffset) {
                  // 右滑动
                  this.curSwiperDirection = "right";
                } else if (extraInfo.currentOffset > this.lastCurrentOffset) {
                  // 左滑动
                  this.curSwiperDirection = "left";
                }
                this.lastCurrentOffset = extraInfo.currentOffset;
                LogUtil.info(`this.curSwiperDirection: ${this.curSwiperDirection}`);
              } else {
                // 第一次记录
                this.lastCurrentOffset = extraInfo.currentOffset;
              }

            })
```



那么 onAnimationStart 的代码则改成如下代码:

```JavaScript
.onAnimationStart((index: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
              const tempNum = this.examList[this.index].material_length - 1;
              if (this.curSwiperDirection == "right" && index == targetIndex && index == tempNum) {
                // 最后一个元素向右滑动
                console.log("最后一个元素向右滑动")
              } else if (this.curSwiperDirection == "left" && index == targetIndex && index == 0) {
                // 第一个元素向左滑动
                console.log("第一个元素向左滑动")
              }
            })
```



那么利用上面的代码就可以比较完美的实现 Swiper 是否在最后一个元素并向右滑动与在第一个元素并向左滑动的判断了。



