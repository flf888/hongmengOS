# Modal Dialogs in HarmonyOS: Usage and Interaction Modes

### 1. Overview

Modal dialogs in HarmonyOS restrict user interaction to the dialog itself until dismissed. ArkUI provides multiple modal components tailored for different scenarios:

- **AlertDialog**: For alerts, confirmations, or prompts (supports titles, messages, up to 3 buttons, inputs, icons, checkboxes, etc.).
- **ActionSheet**: For presenting lists of actionable items (e.g., menu choices).
- **CustomDialog**: For fully customizable UIs.
- **Popup**, **Menu**, **ContextMenu**: For lightweight contextual interactions.

------

### 2. Global Modal Dialogs

#### AlertDialog

Example with title, message, buttons, and optional features:

```
AlertDialog.show({
  title: 'Important Notice',
  subtitle: 'Subtitle Placeholder',
  message: 'This is a sample alert message.',
  autoCancel: true,
  alignment: DialogAlignment.Bottom,
  gridCount: 4,
  offset: { dx: 0, dy: -20 },
  primaryButton: {
    value: 'Cancel',
    action: () => console.info('Cancel button clicked')
  },
  secondaryButton: {
    enabled: true,
    defaultFocus: true,
    style: DialogButtonStyle.HIGHLIGHT,
    value: 'Confirm',
    action: () => console.info('Confirm button clicked')
  }
});
```

#### ActionSheet

Example for selecting an option from a list:

```
ActionSheet.show({
  title: 'Select a Fruit',
  subtitle: 'Choose your favorite',
  message: 'Available options:',
  autoCancel: true,
  confirm: {
    value: 'Confirm Selection',
    action: () => console.log('Selection confirmed')
  },
  alignment: DialogAlignment.Bottom,
  offset: { dx: 0, dy: -10 },
  sheets: [
    { title: 'Apples', action: () => console.log('Apples selected') },
    { title: 'Bananas', action: () => console.log('Bananas selected') },
    { title: 'Pears', action: () => console.log('Pears selected') }
  ]
});
```

#### CustomDialog

Example of a text input dialog:

```
// Define custom dialog content
@Builder
function CustomInputDialog() {
  Column() {
    TextInput({ placeholder: 'Enter new text' });
    Row() {
      Button('Save').onClick(() => {/* Save logic */});
      Button('Cancel').onClick(() => {/* Close dialog */});
    }
  }
}

// Show dialog
PromptAction.openCustomDialog({
  builder: CustomInputDialog,
  title: 'Edit Text',
  primaryButton: { value: 'Save' },
  secondaryButton: { value: 'Cancel' }
});
```

------

### 3. Popup (Tooltip-like Behavior)

Example of a popup triggered by a button click:

```
Button('Show Popup')
  .onClick(() => this.showPopup = !this.showPopup)
  .bindPopup(this.showPopup, {
    message: 'This is a popup message!',
    placementOnTop: true,
    showInSubWindow: false,
    primaryButton: {
      value: 'OK',
      action: () => {
        this.showPopup = false;
        console.info('OK clicked');
      }
    },
    secondaryButton: {
      value: 'Cancel',
      action: () => {
        this.showPopup = false;
        console.info('Cancel clicked');
      }
    },
    onStateChange: (event) => {
      console.info(`Popup visibility: ${event.isVisible}`);
      if (!event.isVisible) this.showPopup = false;
    }
  })
  .position({ x: 100, y: 150 });
```

------

### 4. Menu and ContextMenu

#### bindMenu (Standard Menu)

Attach a menu to a component (no preview image):

```
@Builder
function MyMenu() {
  Menu() {
    MenuItem({ content: 'Option 1' });
    MenuItem({ content: 'Option 2' });
    MenuItem({ content: 'Option 3' });
  }
}

Row() {
  Column() {
    Text('Click to show menu')
      .fontSize(50)
      .fontWeight(FontWeight.Bold);
  }
  .bindMenu(MyMenu)
  .width('100%');
}
```

#### bindContextMenu (Context Menu with Preview)

For long-press actions (e.g., desktop shortcuts):

```
Column() {
  Text('Long press for context menu')
    .width('100%')
    .margin({ top: 5 });
}
.bindContextMenu(() => MenuBuilder.create(), ResponseType.LongPress, {
  placement: Placement.Left,
  preview: MenuPreviewMode.IMAGE
});
```

------

### 5. Subwindow Support

For 2-in-1 devices, use `showInSubWindow: true` to display dialogs outside the main window:

```
CustomDialog.show({
  title: 'Subwindow Dialog',
  message: 'This dialog appears in a subwindow!',
  showInSubWindow: true
});

// Or via ContextMenu
.bindContextMenu(..., { showInSubWindow: true });
```

------

### Summary

HarmonyOS offers flexible modal components for diverse use cases:

- **AlertDialog**: Critical alerts/confirmations.
- **ActionSheet**: List-based selections.
- **CustomDialog**: Tailored UIs.
- **Popup/Menu**: Contextual interactions.
- **Subwindow Support**: Extend dialogs beyond app boundaries.

For advanced scenarios, combine with state management or custom animations.