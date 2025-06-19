# FoldSplitContainer Component Quick Start Guide

The **FoldSplitContainer** component in HarmonyOS enables adaptive two-column or three-column layouts for foldable screens, optimizing UI presentation across different device states. Below is a concise guide to using it:

------

### 1. Introduction and Basic Setup

- **Version Requirement**: Supported from **API Version 12**. Ensure your project meets this requirement.
- **Create a Component Instance**:
   Import `FoldSplitContainer` and initialize it with configuration options:

```
FoldSplitContainer({
  primary: () => {
    // Primary area content builder
  },
  secondary: () => {
    // Secondary area content builder
  },
  extra: () => {
    // Optional extra area content builder
  },
  expandedLayoutOptions: {
    // Expanded state layout options
  },
  hoverModeLayoutOptions: {
    // Hover mode layout options
  },
  foldedLayoutOptions: {
    // Folded state layout options (required)
  },
  animationOptions: null, // Optional animation parameters
  onHoverStatusChange: (status) => {
    // Callback for hover state changes
  }
});
```

------

### 2. Building Region Content

- **Primary Area (`primary`)**:
   Define content using a `@Builder` function:

```
@Builder
private buildPrimaryArea() {
  Text("Primary")
    .backgroundColor('rgba(255, 0, 0, 0.1)')
    .fontSize(28)
    .textAlign(TextAlign.Center)
    .height('100%')
    .width('100%');
}

// In FoldSplitContainer:
primary: this.buildPrimaryArea,
```

- **Secondary Area (`secondary`)** and **Extra Area (`extra`)** follow similar patterns.

------

### 3. Layout Configuration Options

#### Expanded State (`expandedLayoutOptions`):

- `isExtraRegionPerpendicular`: Vertical expansion of the extra region (default: `true`).
- `verticalSplitRatio`: Height ratio between primary and secondary areas (default: `PresetSplitRatio.LAYOUT_1V1`).
- `horizontalSplitRatio`: Width ratio between primary and extra regions (default: `PresetSplitRatio.LAYOUT_3V2`).
- `extraRegionPosition`: Position of the extra region when vertical (default: `ExtraRegionPosition.top`).

#### Hover Mode (`hoverModeLayoutOptions`):

- `showExtraRegion`: Show extra region in half-fold state (default: `false`).
- `horizontalSplitRatio`: Same as expanded state.
- `extraRegionPosition`: Adjusted for hover mode.

#### Folded State (`foldedLayoutOptions`):

- `verticalSplitRatio`: Required height ratio between primary and secondary areas (default: `PresetSplitRatio.LAYOUT_1V1`).

------

### 4. Event Handling

- **`onHoverStatusChange(status)`**:
   Triggered when entering/exiting hover mode. Use this to update UI or track state changes.

------

### Example Workflow

```
FoldSplitContainer({
  primary: this.buildPrimaryArea,
  secondary: () => Text("Secondary"),
  extra: () => Text("Extra"),
  expandedLayoutOptions: { horizontalSplitRatio: PresetSplitRatio.LAYOUT_2V1 },
  onHoverStatusChange: (status) => {
    console.log("Hover status changed to:", status);
  }
});
```

------

### Summary

The **FoldSplitContainer** component simplifies adaptive layout design for foldable devices. Use it to:

- Create dynamic multi-column layouts.
- Customize behavior for expanded, folded, and hover states.
- Enhance user experience across form factors.

For advanced scenarios, explore integration with state management or custom animations.