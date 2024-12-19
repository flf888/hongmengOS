# harmony_flutter **mvvm架构思想**

**写在前面**

在Flutter中实现MVVM（Model-View-ViewModel）架构是为了将UI（视图）与业务逻辑（模型和视图模型）分离，提高代码的可维护性和可读性。

**整体架构概述**

Model: 数据层，处理应用程序的业务逻辑和数据管理。
View: 用户界面层，负责展示数据并接受用户输入。
ViewModel: 连接模型和视图的中间层，处理与视图相关的业务逻辑，并通知视图更新。



**各文件详细讲解**

main.dart

```
import 'package:flutter/material.dart';
import 'package:mvvm/View/MyHomePage.dart';
import 'package:provider/provider.dart';
import 'Model/Model.dart';
import 'ViewModel/CounterViewModel.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MVVM Example',
      home: ChangeNotifierProvider(
        create: (context) => CounterViewModel(CounterModel()),
        child: MyHomePage(),
      ),
    );
  }
}
```

导入依赖: 导入Flutter的Material库、MVVM架构的视图、提供者库、模型和视图模型。
main函数: 应用程序的入口，使用runApp启动MyApp。
MyApp类:
MaterialApp用于创建一个Material风格的应用。
使用ChangeNotifierProvider来创建CounterViewModel实例并将其提供给MyHomePage。这样，MyHomePage及其子组件就能访问CounterViewModel。

CounterViewModel.dart

```
import 'package:flutter/foundation.dart';
import '../Model/Model.dart';

class CounterViewModel extends ChangeNotifier {
  final CounterModel _counterModel;

  CounterViewModel(this._counterModel);

  int get counter => _counterModel.counter;

  void incrementCounter() {
    _counterModel.increment();
    notifyListeners();
  }
}
```

导入依赖: 导入flutter/foundation.dart和模型。
CounterViewModel类:
继承自ChangeNotifier，实现了观察者模式，使得UI组件能够监听到数据的变化。
_counterModel是CounterModel的实例，负责持有计数数据。
counter: 一个getter，提供当前计数值。
incrementCounter: 增加计数值的方法，并调用notifyListeners()来通知UI进行更新。

MyHomePage.dart

```
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/CounterViewModel.dart';
class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePage_State();
}
class MyHomePage_State extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final counterViewModel = Provider.of<CounterViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter MVVM Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('flutter鸿蒙版本MvvM原理的说明：Dart'),
            Text('页面MyHomePage向中间层CounterViewModel要数据'),//业务层（负责直接面对用户的一层）
            Text('中间层CounterViewModel向数据处理层Model要数据：中间创建一个方法并使用该方法调用数据处理层的方法'),
            Text('中间层方法调用完数据处理层方法后使用notifyListeners来通知页面更新UI'),
            Text(
              '${counterViewModel.counter}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterViewModel.incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

导入依赖: 导入Flutter库和Provider**MyHomePage类:
作为应用的主要视图，展示了计数器的当前值。
build方法:
使用Provider.of<CounterViewModel>(context)获取CounterViewModel的实例。
创建一个Scaffold，显示应用的结构。
显示一些文本以说明MVVM的工作原理，并动态展示计数值。
使用FloatingActionButton调用incrementCounter方法以增加计数值。

Model.dart

```
class CounterModel {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
  }
}
```

CounterModel类:
作为数据模型，负责持有和管理计数数据。
_counter是一个私有变量，用于存储计数值。
counter: 一个getter，提供对计数值的访问。
increment: 方法用于增加计数值。



**MVVM架构思想分析**

分离关注点

Model（模型）:
负责数据的管理和业务逻辑，独立于UI层。所有数据操作都在这里完成，如获取、更新等。



View（视图）:
负责展示数据并处理用户输入。UI组件只关心如何展示数据，而不涉及数据如何被处理。
ViewModel（视图模型）:
作为中介，负责协调模型和视图之间的交互。
处理从视图接收的用户输入，并调用模型进行相应的数据处理。
一旦模型的数据发生变化，ViewModel会通过notifyListeners()通知视图更新UI。

数据绑定

在这个示例中，Flutter的Provider包使得数据绑定变得简单。通过ChangeNotifier和Provider，视图可以非常方便地监听数据变化。
当用户点击浮动按钮增加计数时，视图模型调用模型的方法来更新数据，并通知视图重新构建。这种响应式的设计使得开发变得更加高效。



可维护性和可测试性

MVVM架构使得代码结构更加清晰，增强了可维护性。
各个层次的分离使得测试变得更加简单，例如可以单独测试模型和视图模型而无需依赖UI。
写在最后



在Flutter中实现MVVM架构的关键在于利用Provider进行状态管理，将数据和UI分开，使得应用程序的各个部分相互独立，增强了可维护性和可测试性。通过使用CounterViewModel作为中介，视图可以轻松地与模型交互，并在数据变化时自动更新。整个架构的设计不仅提升了代码的整洁度，也使得开发者能够更专注于各自的职责