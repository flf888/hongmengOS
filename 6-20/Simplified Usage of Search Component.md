
# Simplified Usage of Search Component

### 1. Basic Usage

- **Import and Creation**: In an ETS file, first import the Search component via `import { Search } from '@ohos.arkui.advanced.Search'`. Then create a Search instance in the component's `build` method:

    	```typescript
    	Search({ value: this.searchText, placeholder: 'Search...' })
    	 .width('90%')
    	 .height(40)
    	 .onSubmit((value: string) => {
    	// Handle search submission logic
    	  })
    	 .onChange((value: string) => {
    	// Handle input change logic
    	  });
    	```

This sets the initial text (`value`), placeholder text, dimensions, and event listeners for `onSubmit` (search submission) and `onChange` (input changes).

### 2. Property Configuration

- **Search Button Style**: Customize the search button using `searchButton`:

	```typescript
	.searchButton('SEARCH', { fontSize: '16fp', fontColor: '#ff3f97e9' })
	```

- **Placeholder Styling**:  
  `placeholderColor` sets placeholder text color  
  `placeholderFont` sets placeholder font style:

	```typescript
	.placeholderColor(Color.Grey)
	.placeholderFont({ size: 14, weight: 400 })
	```

- **Text Styling**: `textFont` customizes input text appearance
- **Alignment**: `textAlign` (API 9+) sets text alignment (`TextAlign.Start` default)
- **Icon Styling**:  
  `searchIcon` (API 10+) customizes search icon  
  `cancelButton` customizes clear button
- **Text Copying**: `copyOption` (API 9+) enables text copying (default: `CopyOptions.LocalDevice`)
- **Additional Properties**:  
  `fontColor` - Input text color  
  `caretStyle` - Cursor appearance  
  `enableKeyboardOnFocus` - Auto-open keyboard on focus

### 3. Event Handling

- **Search Submission**: `onSubmit` triggers when:  
  • Search icon clicked  
  • Search button pressed  
  • Keyboard search key pressed
- **Input Changes**: `onChange` triggers during text input
- **Text Operations**:  
  `onCopy` - Copy operations  
  `onCut` - Cut operations  
  `onPaste` - Paste operations  
  `onTextSelectionChange` - Text selection changes  
  `onContentScroll` - Content scrolling

### 4. Controller Usage

- **Controller Creation**: `controller: SearchController = new SearchController()`
- **Cursor Control**: `this.controller.caretPosition(1)` positions cursor after first character
- **Exit Edit Mode**: `this.controller.stopEditing()` closes keyboard (custom keyboard scenarios)

### 5. Custom Keyboards

1. Create custom keyboard component:
	```typescript
	@Builder CustomKeyboardBuilder() {
	  Column() {
	// Custom keyboard layout and logic
	  }
	}
	```
2. Bind to Search component:
	```typescript
	Search({ controller: this.controller, value: this.inputValue})
	 .customKeyboard(this.CustomKeyboardBuilder())
	```

### 6. Input Types & Restrictions

- **Input Types** (API 11+):  
  `SearchType.Normal` - Default text input  
  `SearchType.NUMBER` - Numeric only  
  `SearchType.PHONE_NUMBER` - Phone number format  
  `SearchType.EMAIL` - Email format
- **Length Limit**: `maxLength` restricts character count

### 7. Advanced Features

- **Text Styling** (API 12+):  
  `decoration` - Text underline styling  
  `textIndent` - First-line indentation  
  `letterSpacing` - Character spacing  
  `lineHeight` - Line height  
  `selectedBackgroundColor` - Selection highlight color
- **Input Preview**: `enablePreviewText` enables/disables input preview (default enabled)
- **Input Filtering**: `inputFilter` uses regex to restrict allowed characters

By combining these features, developers can create powerful search components tailored to specific application requirements. Consider API version support when implementing features, and leverage new capabilities to optimize search functionality.
