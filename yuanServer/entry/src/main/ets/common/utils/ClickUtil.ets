export class ClickUtil {
  private constructor() {
  }

  private static throttleTimeoutID: number; //节流timeoutID
  private static flag: boolean = false; //节流flag,true=已经进入执行状态了
  private static debounceCacheID: number; //防抖timeoutID

  /**
   * 节流：在一定时间内，只触发一次
   * @param func 要执行的回调函数
   * @param wait = 1500 延时的时间 毫秒
   * @param immediate = true 是否立即执行
   */
  static throttle(func: () => void, wait: number = 1000, immediate: boolean = true) {
    if (immediate) {
      if (!ClickUtil.flag) {
        ClickUtil.flag = true;
        typeof func === 'function' && func();
        ClickUtil.throttleTimeoutID = setTimeout(() => {
          ClickUtil.flag = false;
          clearTimeout(ClickUtil.throttleTimeoutID);
        }, wait);
      }
    } else {
      if (!ClickUtil.flag) {
        ClickUtil.flag = true;
        ClickUtil.throttleTimeoutID = setTimeout(() => {
          ClickUtil.flag = false;
          typeof func === 'function' && func();
          clearTimeout(ClickUtil.throttleTimeoutID);
        }, wait);
      }
    }
  }


  /**
   * 防抖：一定时间内，只有最后一次操作，再过wait毫秒后才执行函数
   * @param func 要执行的函数
   * @param wait 延时的时间
   */
  static debounce(func: () => void, wait: number = 1000) {
    if (ClickUtil.debounceCacheID) {
      clearTimeout(ClickUtil.debounceCacheID);
    }

    let timeoutID = setTimeout(() => {
      typeof func === 'function' && func();
      clearTimeout(timeoutID);
    }, wait);

    ClickUtil.debounceCacheID = timeoutID;

  }
}