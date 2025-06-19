
# Simplified Usage of Custom Dialogs

Custom Dialogs (`CustomDialog`) are popup components provided by HarmonyOS, displayed using the `CustomDialogController` class. Below is a simplified usage guide:

### 1. Basic Concepts
Supported from API Version 7 (API Version 11 for meta-services). Allows developers to customize dialog appearance and content. Suitable for simple prompts but not a replacement for full pages.

### 2. Key Interfaces and Parameters
- **`constructor(value: CustomDialogControllerOptions)`**: Configures dialog parameters (all parameters are static). Includes:
  - `builder`: Required. Content builder (use `@Link` for data binding).
  - `cancel`: Optional. Callback for back/ESC key or overlay tap.
  - `autoCancel`: Optional. Default `true`. Enables overlay tap dismissal.
  - `alignment`: Optional. Vertical alignment (default: `DialogAlignment.Default`).
  - `offset`: Optional. Alignment offset (default: `{ dx: 0, dy: 0 }`).
  - `customStyle`: Optional. Enables custom container styling (corners, dimensions).
  - `gridCount`: Optional. Grid width count (default: auto).
  - Additional parameters (`maskColor`, `maskRect`, `openAnimation`, `closeAnimation`) available from API 10/12 for finer control.

### 3. Usage Steps
1. **Create content builder**:  
   Define a struct with `@CustomDialog` and `@Component`, build content in `build()` method.
2. **Configure controller**:  
   Create `CustomDialogController` instance with parameters in parent component.
3. **Open/close dialog**:  
   Use controller's `open()` and `close()` methods triggered by events.

### 4. Example Code Breakdown
    ```typescript
    // Second dialog structure
    @CustomDialog
    struct CustomDialogExampleTwo {
      controllerTwo?: CustomDialogController
      build() {
    Column() {
      Text('I am the second dialog')
      .fontSize(30)
      .height(100)
      Button('Close this dialog')
      .onClick(() => {
      if (this.controllerTwo) this.controllerTwo.close()
    })
      .margin(20)
    }
      }
    }
    
    // First dialog (contains second dialog's controller)
    @CustomDialog
    @Component
    struct CustomDialogExample {
      @Link textValue: string
      @Link inputValue: string
      dialogControllerTwo: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExampleTwo(),
    alignment: DialogAlignment.Bottom,
    onWillDismiss:(action: DismissDialogAction)=> {
      console.log("Dismiss reason: " + action.reason)
      if ([DismissReason.PRESS_BACK, DismissReason.TOUCH_OUTSIDE].includes(action.reason)) {
    action.dismiss()
      }
    },
    offset: { dx: 0, dy: -25 } 
      })
      controller?: CustomDialogController
      cancel: () => void = () => {}
      confirm: () => void = () => {}
      build() {
    Column() {
      Text('Change text').fontSize(20).margin(10)
      TextInput({ placeholder: '', text: this.textValue })
    .height(60).width('90%')
    .onChange((value) => this.textValue = value)
      Text('Confirm changes?').fontSize(16).margin(10)
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
    Button('Cancel')
      .onClick(() => {
    this.controller?.close()
    this.cancel()
      })
    Button('Confirm')
      .onClick(() => {
    this.inputValue = this.textValue
    this.controller?.close()
    this.confirm()
      })
      }
      Button('Open second dialog')
    .onClick(() => this.dialogControllerTwo?.open())
    }.borderRadius(10)
      }
    }
    
    // Entry component with first dialog controller
    @Entry
    @Component
    struct CustomDialogUser {
      @State textValue: string = ''
      @State inputValue: string = 'click me'
      dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: this.onCancel,
      confirm: this.onAccept,
      textValue: $textValue,
      inputValue: $inputValue
    }),
    cancel: this.exitApp,
    autoCancel: true,
    alignment: DialogAlignment.Bottom,
    offset: { dx: 0, dy: -20 },
    gridCount: 4,
    customStyle: false,
    cornerRadius: 10,
      })
      
      aboutToDisappear() { this.dialogController = null }
      onCancel() { console.log('Cancel callback') }
      onAccept() { console.log('Confirm callback') }
      exitApp() { console.log('Overlay tap callback') }
      
      build() {
    Column() {
      Button(this.inputValue)
    .onClick(() => this.dialogController?.open())
    }
      }
    }
    ```
**Key features demonstrated**:
- Nested dialogs (`CustomDialogExample` contains `CustomDialogExampleTwo`)
- Parameter configuration (alignment, offset, grid count)
- Open/close control via button events
- Dismissal reason handling

### 5. Important Notes
- When avoiding soft keyboards, dialogs compress height at maximum limit. Fixed-height child components may overflow.
- Dialogs don't auto-close during page navigation. Use `Navigation` for synchronized closing.
- Style limitations:
  - `borderWidth`, `borderColor`, `borderStyle` must be used together
  - `backgroundColor` and `backgroundBlurStyle` have interdependent effects
