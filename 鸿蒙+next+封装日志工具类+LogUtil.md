

# 鸿蒙 next 封装日志工具类 LogUtil

由于每次使用系统的 hilog 不太方便，所以这里封装 hilog 成日志工具工具类，方便每次调用.



# 1.封装工具类

```JavaScript
import hilog from '@ohos.hilog'

const LOGGER_DOMAIN: number = 0x0000
const LOGGER_TAG: string = 'LogUtil'

/**
 * TODO 日志工具类
 */
export class LogUtil {
  private static domain: number = LOGGER_DOMAIN
  private static tag: string = LOGGER_TAG //日志Tag
  private static format: string = '%{public}s'
  private static showLog: boolean = true //是否显示打印日志


  /**
   * 是否打印日志（该方法建议在Ability里调用）
   * @param showLog
   */
  static setShowLog(showLog: boolean = true) {
    LogUtil.showLog = showLog
  }

  /**
   * 打印DEBUG级别日志
   * @param args
   */
  static debug(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.debug(LogUtil.domain, LogUtil.tag, LogUtil.format.repeat(args.length), args)
    }
  }

  /**
   * 打印INFO级别日志
   * @param args
   */
  static info(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.info(LogUtil.domain, LogUtil.tag, LogUtil.format.repeat(args.length), args)
    }
  }

  /**
   * 打印WARN级别日志
   * @param args
   */
  static warn(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.warn(LogUtil.domain, LogUtil.tag, LogUtil.format.repeat(args.length), args)
    }
  }

  /**
   * 打印ERROR级别日志
   * @param args
   */
  static error(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.error(LogUtil.domain, LogUtil.tag, LogUtil.format.repeat(args.length), args)
    }
  }

  /**
   * 打印FATAL级别日志
   * @param args
   */
  static fatal(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.fatal(LogUtil.domain, LogUtil.tag, LogUtil.format.repeat(args.length), args)
    }
  }
}

```



## 2.在自己的代码中使用工具类

```JavaScript
 LogUtil.info("run log..............")
```



