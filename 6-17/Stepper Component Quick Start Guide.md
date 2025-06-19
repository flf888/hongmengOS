# Stepper Component Quick Start Guide

The **Stepper** component in HarmonyOS provides a convenient navigation solution for guiding users through multi-step tasks. Below is a concise guide to using it:

------

### 1. Component Setup and Basics

- **Version Requirement**: The Stepper component is supported from **API Version 8**. Ensure your project meets this requirement.
- **Create a Stepper Instance**:
   Import the Stepper component and initialize it with `Stepper({index: currentStepIndex})`, where `index` sets the initial active step (default: `0`). From ​**API Version 10**, `index` supports two-way data binding for dynamic state updates.

```
// Example: Initialize Stepper with initial index 0
Stepper({ index: 0 });
```

------

### 2. Build Step Content

- **Add `StepperItem` Children**:
   The Stepper component accepts only `StepperItem` as child components. Each `StepperItem` represents a step:

```
StepperItem() {
  Column() {
    Text('Step 1: Account Setup')
    Button('Next')
      .onClick(() => {
        // Handle next step logic
      });
  }
  .itemStyle({ /* Customize width, height, colors, etc. */ });
}
```

- **Customize Step Styles**:
   Use functions like `itemStyle()` or `itemTextStyle()` to define styles for content area, buttons, and text.

------

### 3. Configure Navigation

- **Define Navigation Labels**:
   Set labels for "Next" and "Previous" buttons using `.nextLabel()` and `.prevLabel()`:

  ```
  StepperItem()
    .nextLabel('Proceed')
    .prevLabel('Back');
  ```

- **Set Step Status**:
   Control step behavior with the `status` property (options: `Normal`, `Skip`, `Disabled`, `Waiting`):

  ```
  StepperItem()
    .status(this.isStepDisabled ? 'Disabled' : 'Normal');
  ```

------

### 4. Event Handling

- **Navigation Events**:
  - `onChange(prevIndex, index)`: Triggered when switching steps. Use `index` to update the current step state.
  - `onPrevious()`: Triggered when clicking "Previous".
  - `onNext()`: Triggered when clicking "Next" (only if the next step is enabled).
- **Special Events**:
  - `onFinish()`: Triggered when completing the final step. Ideal for task submission logic.
  - `onSkip()`: Triggered when skipping a step (if `status` is `Skip`).

------

### 5. Example Scenario

```
// Define a 3-step process with dynamic status
Stepper({ index: this.currentStep }) {
  StepperItem()
    .title('Personal Info')
    .status(this.step1Disabled ? 'Disabled' : 'Normal');

  StepperItem()
    .title('Payment Details')
    .nextLabel('Confirm Payment');

  StepperItem()
    .title('Review Order')
    .onFinish(() => {
      // Navigate to success page
    });
}
```

------

### Summary

The Stepper component simplifies complex multi-step workflows in HarmonyOS apps. Use it to:

- Guide users through sequential tasks.
- Customize step appearance and behavior.
- Handle navigation and state changes seamlessly.

For advanced use cases, explore integrations with state management libraries or custom animations.

