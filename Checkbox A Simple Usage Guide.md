### Checkbox: A Simple Usage Guide

The **Checkbox** component in HarmonyOS is a multi-select box used to indicate the on/off state of an option. Below is a simple guide to using it:

------

#### 1. Import and Basic Usage

In a `.ets` file, define a component using the `@Entry` and `@Component` decorators. Create a `Checkbox` instance within the `build` function:

```
@Entry
@Component
struct CheckboxExample {
  build() {
    Flex({ justifyContent: FlexAlign.SpaceAround }) {
      Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
        .select(true)
        .selectedColor(0xed6f21)
        .shape(CheckBoxShape.CIRCLE)
        .onChange((value: boolean) => {
          console.info('Checkbox1 change is ' + value);
        });
    }
  }
}
```

------

#### 2. Common Properties

| Property                                | Description                                                  | Default Value          |
| --------------------------------------- | ------------------------------------------------------------ | ---------------------- |
| **`select`**                            | Determines whether the checkbox is selected. Supports two-way binding (API version 10+). | `false`                |
| **`selectedColor`**                     | Sets the color when selected. Default: `$r('sys.color.ohos_id_color_text_primary_activated')`. | N/A                    |
| **`unselectedColor`** (API version 10+) | Sets the border color when unselected. Default: `$r('sys.color.ohos_id_color_switch_outline_off')`. | N/A                    |
| **`mark`** (API version 10+)            | Customizes the internal icon style. If `indicatorBuilder` is set (API version 12+), this is overridden. | N/A                    |
| **`shape`** (API version 11+)           | Sets the component shape: `CheckBoxShape.CIRCLE` (default) or `CheckBoxShape.ROUNDED_SQUARE` (rounded square). | `CheckBoxShape.CIRCLE` |
| **`contentModifier`** (API version 12+) | Customizes the content area using a class implementing the `ContentModifier` interface. | N/A                    |

------

#### 3. Event Handling

Use the `onChange` event to listen for changes in the selection state. The callback returns `true` (selected) or `false` (unselected):

```
Checkbox({ name: 'checkbox1', group: 'checkboxGroup' })
  .onChange((value: boolean) => {
    console.info('Checkbox1 change status: ' + value);
  });
```

------

#### 4. Example Scenarios

- **Setting Checkbox Shape**: Configure shapes via the `shape` property (e.g., circle or rounded square).
- **Customizing Colors**: Use `selectedColor`, `unselectedColor`, and `mark` to define colors.
- **Advanced Styling**: Implement complex styles with `contentModifier` (API 12+) by creating custom components. For example:

```
// Custom pentagon checkbox
class PentagonModifier implements ContentModifier {
  build(context: Context, content: View) {
    // Custom drawing logic for a pentagon shape
  }
}

Checkbox()
  .contentModifier(new PentagonModifier());
```

------

#### Summary

The **Checkbox** component is versatile and meets various multi-selection needs. Developers can flexibly apply its properties and events to suit different scenarios.

