# Implementing a Logging Utility Class in HarmonyOS Next

## 1. LogUtil Implementation

A wrapper around the native `hilog` module for simplified logging:

```
import hilog from '@ohos.hilog';

const LOGGER_DOMAIN: number = 0x0000;
const LOGGER_TAG: string = 'AppLogger';

export class LogUtil {
  private static domain: number = LOGGER_DOMAIN;
  private static tag: string = LOGGER_TAG;
  private static format: string = '%{public}s';
  private static showLog: boolean = true;

  /**
   * Enable/disable logging globally
   * @param showLog - Enable logging (default: true)
   */
  static setShowLog(showLog: boolean = true) {
    LogUtil.showLog = showLog;
  }

  /**
   * DEBUG level logging
   * @param args - Log messages
   */
  static debug(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.debug(LogUtil.domain, LogUtil.tag, 
                 LogUtil.format.repeat(args.length), args);
    }
  }

  /**
   * INFO level logging
   * @param args - Log messages
   */
  static info(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.info(LogUtil.domain, LogUtil.tag, 
                LogUtil.format.repeat(args.length), args);
    }
  }

  /**
   * WARN level logging
   * @param args - Log messages
   */
  static warn(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.warn(LogUtil.domain, LogUtil.tag, 
                LogUtil.format.repeat(args.length), args);
    }
  }

  /**
   * ERROR level logging
   * @param args - Log messages
   */
  static error(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.error(LogUtil.domain, LogUtil.tag, 
                 LogUtil.format.repeat(args.length), args);
    }
  }

  /**
   * FATAL level logging
   * @param args - Log messages
   */
  static fatal(...args: string[]): void {
    if (LogUtil.showLog) {
      hilog.fatal(LogUtil.domain, LogUtil.tag, 
                 LogUtil.format.repeat(args.length), args);
    }
  }
}
```

### Key Features:

1. **Log Level Support**: DEBUG, INFO, WARN, ERROR, FATAL
2. **Global Toggle**: Enable/disable all logging with `setShowLog()`
3. **Domain Management**: Isolate logs using domains
4. **Public Formatting**: Ensures log content visibility
5. **Variadic Parameters**: Accepts multiple log arguments

## 2. Usage Examples

```
// Basic logging
LogUtil.info("Application started successfully");

// Multiple parameters
LogUtil.debug("User login", `ID: ${userId}`, `Session: ${sessionToken}`);

// Error handling
try {
  riskyOperation();
} catch (err) {
  LogUtil.error("Operation failed", err.message);
}

// Conditional logging (e.g., in production)
if (__DEV__) {
  LogUtil.setShowLog(true);
} else {
  LogUtil.setShowLog(false);
}
```

### Best Practices:

1. **Use Appropriate Levels**:
   - `DEBUG`: Development diagnostics
   - `INFO`: Normal operations
   - `WARN`: Potential issues
   - `ERROR`: Recoverable failures
   - `FATAL`: Critical failures
2. **Tag Organization**:

```
// Module-specific logger
class PaymentService {
  private static loggerTag = 'PaymentService';
  
  processPayment() {
    LogUtil.info(this.loggerTag, "Processing payment");
  }
}
```

1. **Performance Considerations**:

```
// Avoid expensive operations in logs
// Bad:
LogUtil.debug(`User data: ${JSON.stringify(largeObject)}`);

// Good:
if (LogUtil.showLog) {
  LogUtil.debug(`User data: ${JSON.stringify(largeObject)}`);
}
```

1. **Log Filtering**:

```
# View logs in terminal
hdc shell hilog | grep AppLogger
```

This utility class simplifies logging while maintaining the power of HarmonyOS' native logging system, making it easier to implement consistent logging practices across your application.
