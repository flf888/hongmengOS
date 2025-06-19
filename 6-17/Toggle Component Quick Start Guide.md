# Toggle Component Quick Start Guide

The **Toggle** component in HarmonyOS provides versatile switch functionality, including checkbox, state button, and switch styles. Below is a concise guide to using it:

------

### 1. Component Introduction and Basic Structure

- **Version Requirement**: Supported from **API Version 8**. Ensure your project meets this requirement.
- **Basic Usage**:
   In your `.ets` file, import and initialize the `Toggle` component within a `Column` or other layout:

```
@Entry
@Component
struct ToggleExample {
  build() {
    Column({ space: 10 }) {
      // Add Toggle components here
    }
    .width('100%')
    .padding(24);
  }
}
```

------

### 2. Setting Toggle Styles

Create a `Toggle` instance with the `type` parameter to define its style:

- `ToggleType.Checkbox` (checkbox style)
- `ToggleType.Button` (state button style with optional text)
- `ToggleType.Switch` (switch style)

**Example**:

```
Toggle({ type: ToggleType.Switch, isOn: false });
```

------

### 3. Style Customization

- **Background Color**: Use `selectedColor` for the active state:

  ```
  .selectedColor('#007DFF')
  ```

- **Slider Color (Switch Only)**: Customize the switch thumb color:

  ```
  .switchPointColor('#FFFFFF')
  ```

- **Advanced Switch Styles (API 12+)**:
   Use `switchStyle` to refine slider appearance:

  ```
  .switchStyle({
    pointRadius: 15,
    trackBorderRadius: 10,
    pointColor: '#D2B48C',
    unselectedColor: Color.Pink
  });
  ```

------

### 4. Event Handling

Listen for state changes with the `onChange` event:

```
.onChange((isOn: boolean) => {
  console.info('Toggle status: ' + isOn);
});
```

------

### 5. Advanced Customization (API 12+)

Implement the `ContentModifier` interface for full styling control:

```
class MySwitchStyle implements ContentModifier<ToggleConfiguration> {
  build(context: Context, config: ToggleConfiguration) {
    // Custom UI logic here
  }
}

Toggle({ type: ToggleType.Switch })
  .contentModifier(new MySwitchStyle())
  .onChange((isOn) => console.info('Switch state: ' + isOn));
```

------

### Summary

The **Toggle** component is ideal for:

- Checkbox-style selections
- Stateful buttons with optional text
- Customizable switch controls
- Responsive UI designs

For deeper customization, explore combining `ContentModifier` with state management or animations.