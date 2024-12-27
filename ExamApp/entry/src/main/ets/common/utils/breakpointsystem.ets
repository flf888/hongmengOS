
declare interface BreakPointTypeOption<T> {
  sm?: T
  md?: T
  lg?: T
}

/**
 * 媒体查询（mediaquery）
 * 响应式设计的核心
 */
export class BreakPointType<T> {
  options: ESObject

  constructor(option: BreakPointTypeOption<T>) {
    this.options = option
  }

  getValue(currentBreakPoint: string): T {
    return this.options[currentBreakPoint] as T
  }
}