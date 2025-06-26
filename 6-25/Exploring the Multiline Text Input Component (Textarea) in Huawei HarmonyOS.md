# Exploring the Multiline Text Input Component (Textarea) in Huawei HarmonyOS

## Introduction

In Huawei HarmonyOS application development, user interaction components are essential for delivering exceptional user experiences. The **Multiline Text Input Component (Textarea)** provides users with convenient multi-line text input capabilities, suitable for scenarios like comment boxes, messaging inputs, and more. This article delves into the usage, properties, and code examples of the Textarea component.

------

## I. Component Overview

The **Textarea** component has been supported since HarmonyOS version 1.0.0. It enables users to input multi-line text effortlessly and offers rich customization options to meet diverse scenario requirements.

------

## II. Constraints and Limitations

1. **Width**: If no width is set, Textarea defaults to full width to maximize space utilization in layouts.
2. **Line Wrapping**: Text exceeding the component width automatically wraps, ensuring readability and preventing overflow.
3. **Height**: Without a predefined height, Textarea adjusts dynamically based on content length, accommodating varying text input.

------

## III. Property Details

| Property              | Type          | Required | Default Value | Description                                                  |
| --------------------- | ------------- | -------- | ------------- | ------------------------------------------------------------ |
| **value**             | `string`      | No       | `''`          | Initial text content (useful for placeholders or default values). |
| **confirm-type**      | `string`      | No       | `"return"`    | Button text at the bottom-right corner (options: `"send"`, `"search"`, `"next"`, `"go"`, `"done"`, `"return"`). |
| **placeholder**       | `string`      | No       | `''`          | Placeholder text displayed when the input is empty.          |
| **placeholder-style** | `string`      | No       | `''`          | Custom styles for the placeholder (supports `color`, `font-size`, `font-weight`). |
| **disabled**          | `boolean`     | No       | `false`       | Disables input if `true` (useful for read-only states).      |
| **maxlength**         | `number`      | No       | `140`         | Maximum input length (set to `-1` for unlimited).            |
| **auto-height**       | `boolean`     | No       | `false`       | Enables automatic height adjustment based on content (overrides manual `height`). |
| **bindinput**         | `eventhandle` | No       | `undefined`   | Triggers on keyboard input; returns `{ value: string }` via `event.detail`. |
| **bindfocus**         | `eventhandle` | No       | `undefined`   | Triggers when the input gains focus.                         |
| **bindblur**          | `eventhandle` | No       | `undefined`   | Triggers when the input loses focus.                         |
| **bindconfirm**       | `eventhandle` | No       | `undefined`   | Triggers when the confirmation button (based on `confirm-type`) is clicked. |

------

## IV. Example Code Analysis

### Example 1: Auto-Height and Confirmation Button Type

**hxml File Content**

```
<view class="page-section">
  <view class="textarea-wrp">
    <textarea
      bindblur="onTextAreaBlur"
      confirm-type="go"
      maxlength="140"
      auto-height="{{true}}"
    />
  </view>
</view>
```

**JavaScript Code**

```
Page({
  data: {},
  onTextAreaBlur(e) {
    console.log(e.detail.value); // Logs the current input value
  },
});
```

**Features Demonstrated**:

- `bindblur`: Binds to the `onTextAreaBlur` function.
- `confirm-type`: Sets the confirmation button text to "Go".
- `maxlength`: Limits input to 140 characters.
- `auto-height`: Enables dynamic height adjustment.

------

### Example 2: Custom Placeholder Style

**hxml File Content**

```
<view class="page-section">
  <view class="page-section-title">Red Placeholder Text</view>
  <view class="textarea-wrp">
    <textarea
      placeholder="Placeholder text is red"
      placeholder-style="color: red; font-size: 20px; font-weight: 200;"
    />
  </view>
</view>
```

**Features Demonstrated**:

- `placeholder`: Sets custom placeholder text.
- `placeholder-style`: Styles the placeholder with red color, 20px font size, and 200 font weight.

------

## V. Key Takeaways

The Textarea component in HarmonyOS offers:

- **Flexibility**: Auto-height, custom placeholders, and confirmation buttons.
- **Validation**: `maxlength` and input event bindings.
- **Localization**: Support for internationalization via dynamic placeholder and confirmation text.

Whether building social apps, chat interfaces, or forms, Textarea streamlines multi-line text input for intuitive user interactions.
