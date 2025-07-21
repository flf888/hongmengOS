### Create Custom Cursor

```
createCustomCursor(name: string, buffer: ArrayBufferLike, hotX: number, hotY: number): string | null {
  try {
    // Create image source from buffer
    let imgSource = image.createImageSource(buffer);
    // Create custom cursor object
    let customCursor: CustomCursor = {
      pixelMap: imgSource.createPixelMapSync(), // Synchronized pixel map creation
      focusX: hotX, // X-axis hotspot coordinate
      focusY: hotY  // Y-axis hotspot coordinate
    };
    // Cache the custom cursor
    this.caches.set(name, customCursor);
  } catch (e) {
    Log.e(TAG, `createCustomCursor Error: ${JSON.stringify(e)}`);
    return null;
  }
  return name;
}
```

------

### Set Custom Cursor

```
setCustomCursor(name: string): boolean {
  try {
    // Check if cursor exists in cache
    if (!this.caches.has(name)) return false;
    // Retrieve cursor from cache
    let cursor = this.caches.get(name);
    if (cursor) {
      // Synchronously apply custom cursor to system pointer
      pointer.setCustomCursorSync(
        this.mainWindow?.getWindowProperties().id, // Window ID
        cursor.pixelMap, // PixelMap data
        cursor.focusX, // Hotspot X
        cursor.focusY  // Hotspot Y
      );
    } else {
      return false;
    }
  } catch (e) {
    Log.i(TAG, `setCustomCursor Error: ${JSON.stringify(e)}`);
    return false;
  }
  return true;
}
```

------

### Delete Custom Cursor

```
deleteCustomCursor(name: string): boolean {
  if (!this.caches.has(name)) return false;
  try {
    // Release pixelMap resources
    this.caches.get(name)?.pixelMap.release();
    // Remove cursor from cache
    this.caches.delete(name);
  } catch (e) {
    Log.i(TAG, `deleteCustomCursor Error: ${JSON.stringify(e)}`);
    return false;
  }
  return true;
}
```

------

### Key Notes

1. 

   Memory Management

   :

   - Explicitly releases `pixelMap` resources in `deleteCustomCursor` to prevent memory leaks.

2. 

   Error Handling

   :

   - Logs detailed error messages for debugging.
   - Returns `null`/`false` on failure to indicate invalid operations.

3. 

   Hotspot Coordinates

   :

   - `focusX`/`focusY` define the cursor's "active" point (e.g., tip of arrow).
  
   1. How to set the cursor position based on a custom keyboard?
Refer to the following code:

class MyKeyboardController {
  public onInputChanged?: (value: string) => void
  public inputController = new TextInputController()
  public carePosition = -1
  private inputValue = ''

  onKeyClicked(key: string) {
    const index = this.inputController.getCaretOffset().index
    if (key === 'A' || key === 'B') {
      this.setInputValue(this.inputValue.substring(0, index) + key + this.inputValue.substring(index))
      this.carePosition = index + 1
    } else if (key === '<') {
      if (index > 0) {
        this.setInputValue(this.inputValue.substring(0, index - 1) + this.inputValue.substring(index))
        this.carePosition = index - 1
      }
    }
  }

  setInputValue(value: string) {
    if (this.carePosition >= 0) {
      this.inputController.caretPosition(this.carePosition)
      this.carePosition = -1
    }
    if (this.inputValue === value) {
      return;
    }
    this.inputValue = value
    if (this.onInputChanged) {
      this.onInputChanged(value)
    }
  }
}

@Component
struct MyKeyboardA {
  controller?: MyKeyboardController
  private keys = ['A', 'B', '<']

  build() {
    Row() {
      ForEach(this.keys, (v: string) => {
        Text(v)
          .layoutWeight(1)
          .height(44)
          .borderWidth(1)
          .borderColor(Color.Gray)
          .borderRadius(4)
          .onClick(() => {
            this.controller?.onKeyClicked(v)
          })
      })
    }
    .height(300)
      .backgroundColor(Color.Gray)
  }
}

@Entry
@Component
export struct RichKeyPage {
  keyboardController = new MyKeyboardController()
  @State text: string = ''

  aboutToAppear(): void {
    this.keyboardController.onInputChanged = (value) => {
      this.text = value
    }
  }

  build() {
    Column({ space: 20 }) {
      TextInput({ text: this.text, controller: this.keyboardController.inputController })
        .width('100%')
        .height(44)
        .customKeyboard(this.myKeyboardA())
        .onChange((value) => {
          this.keyboardController.setInputValue(value)
        })
      Button('Click to directly change the input box content')
        .width('100%')
        .height(44)
        .onClick(() => {
          this.text = '12345678'
        })
    }
  }

  @Builder
  myKeyboardA() {
    MyKeyboardA({ controller: this.keyboardController })
  }
}
2. How to achieve a hollow effect?
Use Canvas to draw a hollow circle and overlay it on the area that needs to be transparent using a Stack component. Refer to the following code:

@Entry
@Component
struct Page {
  @State message: string = 'Hello World';
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State circleCenterX: number = 0
  @State circleCenterY: number = 0
  @State circleRadius: number = 100

  build() {
    Row() {
      Column() {
        Stack() {
          Image($r('app.media.startIcon')).height(300)
          // Use Canvas to draw a mask over images, cameras, etc.
          Canvas(this.context)
            .width('100%')
            .height('100%')
            .backgroundColor('#00000000')
            .onReady(() => {
              this.circleCenterX = this.context.width / 2
              this.circleCenterY = this.context.height / 2
              this.context.fillStyle = '#aa000000'
              // Draw a circular path for semi-transparent filling
              this.context.beginPath()
              this.context.moveTo(0, 0)
              this.context.lineTo(0, this.context.height)
              this.context.lineTo(this.context.width, this.context.height)
              this.context.lineTo(this.context.width, 0)
              this.context.lineTo(0, 0)
              this.context.arc(this.circleCenterX, this.circleCenterY, this.circleRadius, 0, Math.PI * 2)
              this.context.fill()
              this.context.closePath()
            })
        }.width('1456px')
        .height('1456px')
      }
      .width('100%')
    }
    .height('100%')
  }
}
3. How to draw a rounded rectangle using Canvas?
Use the arc method of the CanvasRenderingContext2D object to draw arc paths and combine it with the lineTo method to draw straight lines. Refer to the following code:

@Entry
@Component
struct Page {
  @State message: string = 'Hello World';
  private readonly settings: RenderingContextSettings = new RenderingContextSettings(true);
  private readonly ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  /**
   * Draw a rounded rectangle
   * @param {* Required} x x-coordinate
   * @param {* Required} y y-coordinate
   * @param {* Required} width Width
   * @param {* Required} height Height
   * @param {* Required} radius Radius of the rounded corner
   * @param {* Optional, default: '#456'} strokeColor Border color
   * @param {* Optional, no default} fillColor Fill color
   * @param {* Optional, default: [] solid line} lineDash Border style
   */
  drawRoundRect(x: number, y: number, width: number, height: number, radius: number, strokeColor?: string, fillColor?: string, lineDash?: []) {
    strokeColor = strokeColor || '#333';
    lineDash = lineDash || [];
    this.ctx.beginPath();
    // Set line dash if specified
    this.ctx.setLineDash(lineDash);
    // Draw the first arc path
    this.ctx.arc(x + radius, y + radius, radius, Math.PI, Math.PI * 3 / 2);
    // Draw the first straight line path
    this.ctx.lineTo(width - radius + x, y);
    // Draw the second arc path
    this.ctx.arc(width - radius + x, radius + y, radius, Math.PI * 3 / 2, Math.PI * 2);
    // Draw the second straight line path
    this.ctx.lineTo(width + x, height + y - radius);
    // Draw the third arc path
    this.ctx.arc(width - radius + x, height - radius + y, radius, 0, Math.PI / 2);
    // Draw the third straight line path
    this.ctx.lineTo(radius + x, height + y);
    // Draw the fourth arc path
    this.ctx.arc(radius + x, height - radius + y, radius, Math.PI / 2, Math.PI);
    // Draw the fourth straight line path
    this.ctx.lineTo(x, y + radius);
    // Set the stroke color
    this.ctx.strokeStyle = strokeColor;
    // Stroke the path
    this.ctx.stroke();
    if (fillColor) {
      // Fill the path if fill color is specified
      this.ctx.fillStyle = fillColor;
      this.ctx.fill();
    }
    this.ctx.closePath();
  }

  build() {
    Row() {
      Column() {
        Canvas(this.ctx)
          .width('100%')
          .height('100%')
          .onReady(() => {
            this.drawRoundRect(50, 50, 100, 100, 10)
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
4. Why does XComponent sometimes fail to trigger the keyboard release event?
Problem description:

When using Native XComponent's keyboard event interface, the release state of the Alt key cannot be obtained.
When launching another application or switching to another application via shortcut keys, the window loses focus, causing the XComponent to fail to receive the key release event, resulting in abnormal key behavior within the application.
Solution:

You can observe all subscribed keys using hdc shell hidumper -s 3101 -a -s, and see that Alt is subscribed. In this case, the Alt release event will be consumed by other subscribed applications.
When the window loses focus, the application cannot perceive keyboard events, which is a specification. A new interface capability will be released in the future. The new interface will return parameters indicating the currently pressed keys/buttons on the keyboard/mouse when keyboard/mouse events are triggered, allowing the application to handle the logic accordingly.
5. What is the correct way to use bound-type components with ForEach?
Problem description:

When using bindSheet with ForEach, $$this.isShow triggers the semi-modal twice. If using this.isShow, the semi-modal pops up as many times as the length of the array. How to ensure only one pop-up is triggered when clicking an item in ForEach?

Solution:

Key code: Bind each pop-up with a @State-decorated variable. An array is convenient when there are multiple pop-ups.
