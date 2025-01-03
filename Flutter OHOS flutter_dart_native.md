# HarmonyOS next之DartNative

DartNative 作为 Dart 和原生 API 之间沟通的桥梁。

用更快、更简洁的代码替换性能低下的 Flutter 通道。


## 特征

### 动态同步和异步通道

DartNative动态调用任何原生 API 。它支持同步和异步通道。

### 多语言接口直接调用

不再需要像 Flutter Channel 那样对参数和返回值进行序列化，DartNative 提供了语言接口之间的直接调用和自动对象编组。

### Dart finalizer

Dart finalizer 仅支持 Flutter 3（Dart 2.17）以上版本，但 DartNative 可在 Dart Flutter 2.2.0（Dart 2.13.0）及更高版本中使用。

### 自动生成简洁的桥接代码

DartNative 支持自动类型转换，因此其桥接代码比 Flutter 通道更短更简单。

此包的设计和愿景：

![](https://gitee.com/openharmony-sig/flutter_dart_native/raw/master/images/dartnative.png)

## 要求

DartNative 版本	 Flutter 要求	               代码生成版本
0.4.x - 0.7.x	 Flutter 2.2.0（Dart 2.13.0）	 2.x
0.3.x	         Flutter  1.20.0（Dart 2.9.1）	 1.2.x
0.2.x	         Flutter  1.12.13（Dart 2.7）    1.x

## 支持的平台

iOS、macOS 和 Android

## 用法

### 基本用法：接口绑定

添加dart_native到依赖项和build_runnerdev_dependencies。然后你就可以编写代码了。以下是一些示例：

#### Dart 调用 Native

Dart code:


    final interface = Interface("MyFirstInterface");
    // Example for string type.
    String helloWorld() {
    return interface.invokeMethodSync('hello', args: ['world']);
    }
    // Example for num type.
    Future<int> sum(int a, int b) {
    return interface.invokeMethod('sum', args: [a, b]);
    }


相应的Objective-C代码：


    @implementation DNInterfaceDemo
    
    // Register interface name.
    InterfaceEntry(MyFirstInterface)
    
    // Register method "hello".
    InterfaceMethod(hello, myHello:(NSString *)str) {
        return [NSString stringWithFormat:@"hello %@!", str];
    }
    
    // Register method "sum".
    InterfaceMethod(sum, addA:(int32_t)a withB:(int32_t)b) {
    return @(a + b);
    }
    
    @end


对应的Java代码：



    // load libdart_native.so
    DartNativePlugin.loadSo();
    
    @InterfaceEntry(name = "MyFirstInterface")
    public class InterfaceDemo extends DartNativeInterface {
    
    @InterfaceMethod(name = "hello")
    public String hello(String str) {
    return "hello " + str;
    }
    
    @InterfaceMethod(name = "sum")
    public int sum(int a, int b) {
    return a + b;
    }
    }


注意：如果您的路径是自定义的，则需要传递特定路径。
    
    DartNativePlugin.loadSoWithCustomPath("xxx/libdart_native.so");

在 dart 中使用 DartNative 之前，首先调用dartNativeInitCustomSoPath()。它将从通道中获取路径。

#### Native 调用 Dart

Dart code:


    interface.setMethodCallHandler('totalCost',
    (double unitCost, int count, List list) async {
    return {'totalCost: ${unitCost * count}': list};
    });


相应的Objective-C代码：


    [self invokeMethod:@"totalCost"
             arguments:@[@0.123456789, @10, @[@"testArray"]]
                result:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@", result);
    }];



对应的Java代码：


    invokeMethod("totalCost", new Object[]{0.123456789, 10, Arrays.asList("hello", "world")},
     new DartNativeResult() {
    @Override
    public void onResult(@Nullable Object result) {
    Map retMap = (Map) result;
    // do something
    }
    
    @Override
    public void error(@Nullable String errorMessage) {
    // do something
    }
      }
    );


#### Dart finalizer


    final foo = Bar(); // A custom instance.
    unitTest.addFinalizer(() { // register a finalizer callback.
      print('The instance of \'foo\' has been destroyed!'); // When `foo` is destroyed by GC, this line of code will be executed.
    });



### 高级用法：动态调用方法

- 步骤 1：添加dart_native依赖项和build_runnerdev_dependencies。

- 第 2 步：使用@dartnative/codegen生成 Dart 包装器代码或手动编写 Dart 代码。

- 步骤 3：使用dart_native_gen生成自动类型转换的代码，步骤如下（3.1-3.3）：

  + 3.1 用 注释 Dart 包装器类@native。
    
>         @native
>     class RuntimeSon extends RuntimeStub {
>       RuntimeSon([Class isa]) : super(Class('RuntimeSon'));
>       RuntimeSon.fromPointer(Pointer<Voidptr) : super.fromPointer(ptr);
>     }


  + 3.2 用 注释您自己的条目（例如main()）@nativeRoot。

    
        @nativeRoot
    void main() {
      runApp(App());
    }


  + 3.3 运行 
    
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
	将文件生成到您的源目录中。

    注意：我们建议clean先运行：

    flutter packages pub run build_runner clean
    

- 步骤4：调用3.3中自动生成的函数。函数名由中<generated-name>.dn.dart确定。namepubspec.yaml

    
>     @nativeRoot
>     void main() {
>       // Function name is generated by name in pubspec.yaml.
>       runDartNativeExample(); 
>       runApp(App());
>     }


- 步骤5：然后就可以编写代码了。以下是一些示例：

  + 5.1 iOS:

    Dart 代码（生成）：


>     // new Objective-C object.
>     RuntimeStub stub = RuntimeStub();
>     
>     // Dart function will be converted to Objective-C block.
>     stub.fooBlock((NSObject a) {
>     print('hello block! ${a.toString()}');
>     return 101;
>     });
>     
>     // support built-in structs.
>     CGRect rect = stub.fooCGRect(CGRect(4, 3, 2, 1));
>     print(rect);

   相应的Objective-C代码：
    
       
    typedef int(^BarBlock)(NSObject *a);
    
    @interface RuntimeStub
    
    - (CGRect)fooCGRect:(CGRect)rect;
    - (void)fooBlock:(BarBlock)block;
    
    @end


    More iOS examples see: [ios_unit_test.dart](/dart_native/example/lib/ios/unit_test.dart)

  + 5.2 Android:

    Dart 代码（生成）：
    
>     // new Java object.
>     RuntimeStub stub = RuntimeStub();
>     
>     // get java list.
>     List list = stub.getList([1, 2, 3, 4]);
>     
>     // support interface.
>     stub.setDelegateListener(DelegateStub());


   对应的Java代码：


    public class RuntimeStub {
    
    public List<Integer> getList(List<Integer> list) {
    List<Integer> returnList = new ArrayList<>();
    returnList.add(1);
    returnList.add(2);
    return returnList;
    }
    
    public void setDelegateListener(SampleDelegate delegate) {
    delegate.callbackInt(1);
    }
    }

 更多android示例参见：[https://gitee.com/openharmony-sig/flutter_dart_native/blob/master/dart_native/example/lib/android/unit_test.dart](https://gitee.com/openharmony-sig/flutter_dart_native/blob/master/dart_native/example/lib/android/unit_test.dart "android_unit_test.dart")

注意：如果您在 macOS 上使用 dart_native，则必须use_frameworks!在 Podfile 中使用。
