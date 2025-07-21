# Simplified Guide to Using Dialogs

HarmonyOS Next uses dialogs (or dialog boxes) as a key UI element for user interaction, displaying important information, or obtaining confirmations. These dialogs can be customized and are often used for things like displaying menus, prompts, and alerts. 
Types of Dialogs
Several types of dialogs are available in HarmonyOS Next, including: 
TipsDialog: Displays brief messages or information to the user.
SelectDialog: Allows users to choose from a list of options.
ConfirmDialog: Asks the user to confirm an action.
AlertDialog: Displays an alert message with an "OK" button.
LoadingDialog: Indicates that an action is in progress.
CustomContentDialog: Enables fully customized dialog content and appearance.
Basic Usage
Import Modules: Import the necessary dialog modules from @kit.ArkUI. 
Create a Controller: Each dialog type requires a corresponding controller (e.g., CustomDialogController) to manage its display and interaction. 
Customize Content: Configure the content and appearance of the dialog (e.g., text, buttons, etc.). 
Display the Dialog: Call the open() method on the controller to display the dialog. 
Custom Dialogs
HarmonyOS NEXT offers flexibility in creating custom dialogs, allowing developers to design unique UI experiences. 
openCustomDialog:
This method allows you to create a custom dialog, either by passing in a builder (which can have some coupling with the UI) or using ComponentContent (which provides more flexibility and decoupling).
ComponentContent:
Encapsulates the dialog content, making it more flexible and decoupled from the UI.
builder:
Creates a dialog using a builder, which can be useful for achieving the default style of system pop-ups.
Key Considerations
Context:
When working with dialogs, make sure you have the correct context (UI context). 
Lifecycle:
Be aware of the dialog's lifecycle events (e.g., onWillAppear, onDiDisappear) and use them for specific actions or updates. 
Modal vs. Non-Modal:
Decide whether to use a modal dialog (which blocks interaction with the underlying page) or a non-modal dialog (which allows interaction). 
Subwindows:
For specific scenarios (e.g., 2-in-1 devices), you can display dialogs in subwindows using showInSubWindow. 

Dialogs (Dialog) are commonly used UI components in HarmonyOS application development for interacting with users, presenting important information, or obtaining user confirmation. Below is a simplified usage guide:

## 一、Import Module

Before using dialogs, import the required module:
	
	```javascript
	import { TipsDialog, SelectDialog, ConfirmDialog, AlertDialog, LoadingDialog, CustomContentDialog } from '@kit.ArkUI';
	```

## 二、Create Dialog Controller

Each dialog type requires a corresponding controller to manage its display and interaction. Example for creating a TipsDialog controller:

	```javascript
	let dialogController = new CustomDialogController({
	    builder: TipsDialog({
	        
	    })
	});
	```

## 三、Configure Dialog Parameters

 Common Parameters

   - controller: Dialog controller for show/hide operations
   - theme (Optional, API 12+): Theme information (custom or from onWillApplyTheme)
   - themeColorMode (Optional, API 12+): Custom dark/light mode

## 四、Handle Button Click Events

Define click actions in button configurations:

	```javascript
	primaryButton: {
	    value: 'Cancel',
	    action: () => {
	        console.info('Cancel button clicked');
	    }
	}
	```

## 五、Display Dialog

Call the controller's open method:

	```javascript
	dialogController.open();
	```

By following these steps, you can implement various dialog types in HarmonyOS applications to enhance user interaction. Select the appropriate dialog type and configure its parameters according to your specific requirements for information display and user confirmation scenarios.
