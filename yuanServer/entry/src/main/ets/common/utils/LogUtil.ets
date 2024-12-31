import hilog from '@ohos.hilog'


/**
 * TODO 日志工具类
 */
export class LogUtil {
  private static domain: number = 0x0000
  private static tag: string = 'LogUtil' //日志Tag
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
