# Simplified Guide to Using Dialogs

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