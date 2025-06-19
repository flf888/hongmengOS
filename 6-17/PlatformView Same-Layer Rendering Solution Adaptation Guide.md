## PlatformView Same-Layer Rendering Solution Adaptation Guide

### Legacy PlatformView Solution

##### Overview

Defines `DynamicView` and `DVModel` in the Flutter adaptation layer:

```
@Observed
export class DVModel {
  id_: number;
  compType: string;
  params: DVModelParameters;
  events: DVModelEvents;
  children: DVModelChildren;
  builder: Any;

  public getLayoutParams(): DVModelParameters {
    return this.params;
  }
}

@Component
export struct DynamicView{
  @ObjectLink model: DVModel;
  @ObjectLink children: DVModelChildren;
  @ObjectLink params: DVModelParameters;
  @ObjectLink events: DVModelEvents;
  @BuilderParam customBuilder?: ($$: BuilderParams) => void;
}
```

Developers use JSON strings to define DVModel structures for PlatformView implementation. This solution positions FlutterView at the bottom layer and DynamicView (implemented with ArkUI) at the top layer using native HarmonyOS rendering.

```
build() {
  Stack() {
    XComponent({ id: this.viewId, type: this.xComponentType, libraryname: 'flutter' })
      .focusable(true)
      .focusOnTouch(true)
      .onLoad((context) => {
        this.flutterView?.onSurfaceCreated()
      })
      .onDestroy(() => {
        this.flutterView?.onSurfaceDestroyed()
      })
      .backgroundColor(Color.Transparent)
    
    ForEach(this.rootDvModel!!, (child: Any) => {
      DynamicView({
        model: child as DVModel,
        params: child.params,
        events: child.events,
        children: child.children,
        customBuilder: child.builder
      })
    })
  }
}
```

This legacy solution has two critical limitations:

1. **Occlusion issues**: PlatformView overlays FlutterView causing visual blocking
2. **Animation inconsistency**: FlutterView and PlatformView animations desynchronize during page transitions

### New PlatformView Solution

##### Overview

Implements NodeContainer same-layer rendering functionality. Exports native component textures to the Flutter Engine for unified rendering. This resolves the legacy solution's limitations while enabling:

- PlatformView usage with custom ArkUI Components
- Alignment with native HarmonyOS development practices
- Elimination of JSON-based definitions and coding without hints

```
build() {
  Stack() {
    NodeContainer(this.nodeController)
      .width(this.storageLinkWidth)
      .height(this.storageLinkHeight)
    
    XComponent({ id: this.viewId, type: this.xComponentType, libraryname: 'flutter' })
      .focusable(true)
      .focusOnTouch(true)
      .onLoad((context) => {
        this.flutterView?.onSurfaceCreated()
      })
      .onDestroy(() => {
        this.flutterView?.onSurfaceDestroyed()
      })
      .backgroundColor(Color.Transparent)
  }
}
```

### Key Differences Between Solutions

###### Legacy Solution:

JSON-based DVModel definition:

```
private model: DVModel = createDVModelFromJson(
  {
    compType: "Column",
    attributes: { height: '200%'},
    children: [
      {
        compType: "Text",
        attributes: { 
          value: "Native: Send data to Dart111111111111111", 
          fontColor: Color.Orange,
          backgroundColor: Color.Black,
          height: 100
        },
        events: { onClick: this.sendMessage },
      },
      {
        compType: "Text",
        attributes: { 
          value: "Native: Data from Dart", 
          marginTop: 20 
        },
      }
    ],
  }
);

/// Custom PlatformView entity implementation interface
getView(): DVModel {
  return this.model;
}
```

###### New Solution:

Custom ArkUI Component implementation:

```
@Component
struct ButtonComponent {
  @Prop params: Params 
  customView: CustomView = this.params.platformView as CustomView
  @StorageLink('numValue') storageLink: string = "first"
  @State bkColor: Color = Color.Red
  
  build() {
    Column() {
      Button("Send Data to Flutter")
        .border({ width: 2, color: Color.Blue })
        .backgroundColor(this.bkColor)
        .onTouch((event: TouchEvent) => {
          console.log("Button touch event")
        })
        .onClick((event: ClickEvent) => {
          this.customView.sendMessage();
          console.log("Button clicked")
        })
      
      Text(`Data from Flutter: ${this.storageLink}`)
        .onTouch((event: TouchEvent) => {
          console.log("Text touch event")
        })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .direction(Direction.Ltr)
    .width('100%')
    .height('100%')
  }
}

/// Custom PlatformView entity implementation interface
getView(): WrappedBuilder<[Params]> {
  return new WrappedBuilder(ButtonBuilder);
}
```
