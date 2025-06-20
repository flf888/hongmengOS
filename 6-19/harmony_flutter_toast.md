# Custom Toast Implementation for harmony_flutter

#### Establishing Channel on OHOS Side to Display System-Level Toast

```
export default class FlutterToastPlugin implements FlutterPlugin {
  private channel: MethodChannel | null = null;

  getUniqueClassName(): string {
    return TAG;
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.setupChannel(binding.getBinaryMessenger());
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.teardownChannel();
  }

  private setupChannel(messenger: BinaryMessenger) {
    this.channel = new MethodChannel(messenger, "PonnamKarthik/fluttertoast", StandardMethodCodec.INSTANCE);
    let handler = new MethodCallHandlerImpl();
    this.channel.setMethodCallHandler(handler);
  }

  private teardownChannel() {
    this.channel?.setMethodCallHandler(null)
    this.channel = null
  }
}
```

#### Receiving Parameters Passed from Flutter Layer

```
export default class MethodCallHandlerImpl implements MethodCallHandler{
  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'showToast': {
        let msg: string = call.argument('msg');

        /* Time unit from Dart layer is seconds, promptAction.showToast requires milliseconds */
        let time: number = call.argument('time') * 1000;
        let gravity: string = call.argument("gravity");
        let bgcolor: number = call.argument("bgcolor");
        let textcolor: number = call.argument("textcolor");
        let textSize: number = call.argument("fontSize");

        try {
          promptAction.showToast({message: msg, duration: time});
        } catch (e) {
          Log.e(TAG, "Show toast err " + e);
        }

        result.success(true);
      }
      case 'cancel': {
        result.success(true);
      }
      default: {
        result.notImplemented();
      }
    }
  }
}
```

#### Flutter Side Code

```
/// Toast Length
/// Only for Android Platform
enum Toast {
  /// Show Short toast for 1 sec
  LENGTH_SHORT,

  /// Show Long toast for 5 sec
  LENGTH_LONG
}

/// ToastGravity
/// Used to define the position of the Toast on the screen
enum ToastGravity { TOP, BOTTOM, CENTER, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, CENTER_LEFT, CENTER_RIGHT, SNACKBAR, NONE }

/// Plugin to show a toast message on screen
/// Only for android, ios and Web platforms
class Fluttertoast {
  /// [MethodChannel] used to communicate with the platform side.
  static const MethodChannel _channel = const MethodChannel('PonnamKarthik/fluttertoast');

  /// Let say you have an active show
  /// Use this method to hide the toast immediately
  static Future<bool?> cancel() async {
    bool? res = await _channel.invokeMethod("cancel");
    return res;
  }

  /// Summons the platform's showToast which will display the message
  ///
  /// Wraps the platform's native Toast for android.
  /// Wraps the Plugin https://github.com/scalessec/Toast for iOS
  /// Wraps the https://github.com/apvarun/toastify-js for Web
  ///
  /// Parameter [msg] is required and all remaining are optional
  static Future<bool?> showToast({
    required String msg,
    Toast? toastLength,
    int timeInSecForIosWeb = 1,
    double? fontSize,
    ToastGravity? gravity,
    Color? backgroundColor,
    Color? textColor,
    bool webShowClose = false,
    webBgColor = "linear-gradient(to right, #00b09b, #96c93d)",
    webPosition = "right",
  }) async {
    String toast = "short";
    if (toastLength == Toast.LENGTH_LONG) {
      toast = "long";
    }

    String gravityToast = "bottom";
    if (gravity == ToastGravity.TOP) {
      gravityToast = "top";
    } else if (gravity == ToastGravity.CENTER) {
      gravityToast = "center";
    } else {
      gravityToast = "bottom";
    }

    // Apply default colors if none provided
    if (backgroundColor == null) {
      backgroundColor = Colors.black;
    }
    if (textColor == null) {
      textColor = Colors.white;
    }
    final Map<String, dynamic> params = <String, dynamic>{
      'msg': msg,
      'length': toast,
      'time': timeInSecForIosWeb,
      'gravity': gravityToast,
      'bgcolor': backgroundColor.value,
      'iosBgcolor': backgroundColor.value,
      'textcolor': textColor.value,
      'iosTextcolor': textColor.value,
      'fontSize': fontSize,
      'webShowClose': webShowClose,
      'webBgColor': webBgColor,
      'webPosition': webPosition
    };

    bool? res = await _channel.invokeMethod('showToast', params);
    return res;
  }
}

/// Signature for a function to buildCustom Toast
typedef PositionedToastBuilder = Widget Function(BuildContext context, Widget child);

/// Runs on dart side with no native interaction
/// Works with all platforms in two lines of code:
/// final fToast = FToast().init(context)
/// fToast.showToast(child)
///
class FToast {
  BuildContext? context;

  static final FToast _instance = FToast._internal();

  /// Primary Constructor for FToast
  factory FToast() {
    return _instance;
  }

  /// Saves user's Context to a variable
  FToast init(BuildContext context) {
    _instance.context = context;
    return _instance;
  }

  FToast._internal();

  OverlayEntry? _entry;
  List<_ToastEntry> _overlayQueue = [];
  Timer? _timer;
  Timer? _fadeTimer;

  /// Internal function handling overlay display
  _showOverlay() {
    if (_overlayQueue.isEmpty) {
      _entry = null;
      return;
    }
    if (context == null) {
      removeQueuedCustomToasts();
      throw ("Error: Context is null, Please call init(context) before showing toast.");
    }

    Overlay? _overlay;
    try {
      _overlay = Overlay.of(context;
    } catch (err) {
      removeQueuedCustomToasts();
      throw ("Error: Overlay is null. See documentation for solutions.");
    }
    if (_overlay == null) {
      removeQueuedCustomToasts();
      throw ("Error: Overlay is null. See documentation for solutions.");
    }

    /// Create and display overlay
    _ToastEntry _toastEntry = _overlayQueue.removeAt(0);
    _entry = _toastEntry.entry;
    _overlay.insert(_entry;

    _timer = Timer(_toastEntry.duration, () {
      _fadeTimer = Timer(_toastEntry.fadeDuration, () {
        removeCustomToast();
      });
    });
  }

  /// Hides active toast immediately
  removeCustomToast() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;
    _entry?.remove();
    _entry = null;
    _showOverlay();
  }

  /// Clears toast queue
  removeQueuedCustomToasts() {
    _timer?.cancel();
    _fadeTimer?.cancel();
    _timer = null;
    _fadeTimer = null;
    _overlayQueue.clear();
    _entry?.remove();
    _entry = null;
  }

  /// Displays custom toast
  void showToast({
    required Widget child,
    PositionedToastBuilder? positionedToastBuilder,
    Duration toastDuration = const Duration(seconds: 2),
    ToastGravity? gravity,
    Duration fadeDuration = const Duration(milliseconds: 350),
    bool ignorePointer = false,
    bool isDismissable = false,
  }) {
    if (context == null) throw ("Error: Context is null, Please call init(context) before showing toast.");
    Widget newChild = _ToastStateFul(
        child,
        toastDuration,
        fadeDuration,
        ignorePointer,
        !isDismissable
            ? null
            : () {
                removeCustomToast();
              });

    /// Adjust position if keyboard is open
    if (gravity == ToastGravity.BOTTOM) {
      if (MediaQuery.of(context.viewInsets.bottom != 0) {
        gravity = ToastGravity.CENTER;
      }
    }

    OverlayEntry newEntry = OverlayEntry(builder: (context) {
      if (positionedToastBuilder != null) return positionedToastBuilder(context, newChild);
      return _getPostionWidgetBasedOnGravity(newChild, gravity);
    });
    _overlayQueue.add(_ToastEntry(entry: newEntry, duration: toastDuration, fadeDuration: fadeDuration));
    if (_timer == null) _showOverlay();
  }

  /// Positions widget based on gravity
  _getPostionWidgetBasedOnGravity(Widget child, ToastGravity? gravity) {
    switch (gravity) {
      case ToastGravity.TOP:
        return Positioned(top: 100.0, left: 24.0, right: 24.0, child: child);
      case ToastGravity.TOP_LEFT:
        return Positioned(top: 100.0, left: 24.0, child: child);
      case ToastGravity.TOP_RIGHT:
        return Positioned(top: 100.0, right: 24.0, child: child);
      case ToastGravity.CENTER:
        return Positioned(top: 50.0, bottom: 50.0, left: 24.0, right: 24.0, child: child);
      case ToastGravity.CENTER_LEFT:
        return Positioned(top: 50.0, bottom: 50.0, left: 24.0, child: child);
      case ToastGravity.CENTER_RIGHT:
        return Positioned(top: 50.0, bottom: 50.0, right: 24.0, child: child);
      case ToastGravity.BOTTOM_LEFT:
        return Positioned(bottom: 50.0, left: 24.0, child: child);
      case ToastGravity.BOTTOM_RIGHT:
        return Positioned(bottom: 50.0, right: 24.0, child: child);
      case ToastGravity.SNACKBAR:
        return Positioned(bottom: MediaQuery.of(context.viewInsets.bottom, left: 0, right: 0, child: child);
      case ToastGravity.NONE:
        return Positioned.fill(child: child);
      case ToastGravity.BOTTOM:
      default:
        return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    }
  }
}

/// Creates [TransitionBuilder] for MaterialApp builder
TransitionBuilder FToastBuilder() {
  return (context, child) {
    return _FToastHolder(
      child: child!,
    );
  };
}

/// StatelessWidget holding child and creating toast overlay
class _FToastHolder extends StatelessWidget {
  const _FToastHolder({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Overlay overlay = Overlay(
      initialEntries: [OverlayEntry(builder: (ctx) => child)],
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: overlay,
    );
  }
}

/// Internal class managing overlay entries
class _ToastEntry {
  final OverlayEntry entry;
  final Duration duration;
  final Duration fadeDuration;

  _ToastEntry({
    required this.entry,
    required this.duration,
    required this.fadeDuration,
  });
}

/// StatefulWidget handling toast animations
class _ToastStateFul extends StatefulWidget {
  _ToastStateFul(this.child, this.duration, this.fadeDuration, this.ignorePointer, this.onDismiss, {Key? key}) : super(key: key);

  final Widget child;
  final Duration duration;
  final Duration fadeDuration;
  final bool ignorePointer;
  final VoidCallback? onDismiss;

  @override
  ToastStateFulState createState() => ToastStateFulState();
}

/// State for toast animations
class ToastStateFulState extends State<_ToastStateFul> with SingleTickerProviderStateMixin {
  /// Start show animation
  showIt() {
    _animationController!.forward();
  }

  /// Start hide animation
  hideIt() {
    _animationController!.reverse();
    _timer?.cancel();
  }

  AnimationController? _animationController;
  late Animation _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController!, curve: Curves.easeIn);
    super.initState();

    showIt();
    _timer = Timer(widget.duration, () {
      hideIt();
    });
  }

  @override
  void deactivate() {
    _timer?.cancel();
    _animationController!.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss == null ? null : () => widget.onDismiss!(),
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        ignoring: widget.ignorePointer,
        child: FadeTransition(
          opacity: _fadeAnimation as Animation<double>,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
```

### Flutter Example Usage

```
fToast = FToast();
fToast.init(context);

fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 2),
    positionedToastBuilder: (context, child) {
      return Positioned(
        child: child,
        top: 16.0,
        left: 16.0,
      );
    });
```
