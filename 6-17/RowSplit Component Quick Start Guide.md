# RowSplit Component Quick Start Guide

The **RowSplit** component in HarmonyOS allows you to create horizontal layouts with vertical splitters between child components. Below is a concise guide to using it:

------

### 1. Component Introduction and Basic Setup

- **Version Requirement**: Supported from **API Version 7** (API version 11+ required for meta-service usage). Ensure your project meets this requirement.
- **Create a Component Instance**:
   Import `RowSplit` and initialize it within your code:

```
RowSplit() {
  // Add child components here
}
```

------

### 2. Adding Child Components and Layout

- **Insert Child Components**: Place components horizontally within `RowSplit`:

```
RowSplit() {
  Text('1')
    .width('10%')
    .height(100)
    .backgroundColor(0xF5DEB3)
    .textAlign(TextAlign.Center);
  
  Text('2')
    .width('10%')
    .height(100)
    .backgroundColor(0xD2B48C)
    .textAlign(TextAlign.Center);
  
  // Add more components as needed...
}
```

- 

  Key Notes

  :

  - Splitter positions are calculated based on child widths at initialization.
  - Dynamically modifying child widths (except via splitter dragging) is **not supported**.
  - Overriding `margin`, `border`, or `padding` may disable splitter dragging if widths exceed adjacent splitter gaps.

------

### 3. Configuring Splitters

- **Enable Dragging**: Use the `resizeable` property to toggle splitter dragging:

```
RowSplit() {
  // Child components...
}
.resizeable(true); // Enable dragging
```

------

### 4. Styling the Component

- **Global Styles**: Set properties like width/height for the entire `RowSplit`:

```
RowSplit()
  .width('90%')
  .height(100);
```

- **Child Styles**: Customize individual child components (e.g., background color, text alignment):

```
Text('Item')
  .width('20%')
  .backgroundColor('#FFD700')
  .textAlign(TextAlign.Center);
```

------

### 5. Integrating with Other Components

- **Nested Layouts**: Combine `RowSplit` with other components (e.g., `Column`) for complex UIs:

```
Column() {
  Text('Draggable content below')
    .fontSize(9)
    .fontColor(0xCCCCCC)
    .width('90%');
  
  RowSplit()
    .resizeable(true)
    .width('90%')
    .height(100);
}
.width('100%')
.margin({ top: 5 });
```

------

### Summary

The **RowSplit** component simplifies horizontal layouts with draggable splitters in HarmonyOS. Use it to:

- Create responsive multi-column interfaces.
- Customize splitter behavior and styling.
- Nest within other layouts for advanced designs.

For best results, test dynamic resizing and edge cases (e.g., extreme child widths).