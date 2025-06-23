# Border Usage and Individual Direction in HarmonyOS NextSettings

The following details the implementation of component border styling in relevant development environments:

### Border Style Setting Overview

Border styling has been supported since API Version 7, with subsequent versions adding support for different application scenarios (such as ArkTS cards and meta-services).

### border Interface

- 

  Function

  :

   

  ```
  border(value: BorderOptions)
  ```

   

  sets unified border styles.

  - Default border width is 0 (invisible)
  - Since API Version 9, parent node borders display above child node content

- 

  Support

  :

  - ArkTS Cards: Supported since API version 9
  - Meta Services: Supported since API version 11

- **System Capability**: `SystemCapability.ArkUI.ArkUI.Full`

### borderStyle Interface

- 

  Function

  :

   

  ```
  borderStyle(value: BorderStyle | EdgeStyles)
  ```

   

  sets border line styles.

  - Default value: `BorderStyle.Solid`

- 

  Support

  :

  - ArkTS Cards: Supported since API version 9
  - Meta Services: Supported since API version 11

- **System Capability**: `SystemCapability.ArkUI.ArkUI.Full`

### borderWidth Interface

- 

  Function

  :

   

  ```
  borderWidth(value: Length | EdgeWidths | LocalizedEdgeWidths)
  ```

   

  sets border widths.

  - Percentage values not supported

- 

  Support

  :

  - ArkTS Cards: Supported since API version 9
  - Meta Services: Supported since API version 11

- **System Capability**: `SystemCapability.ArkUI.ArkUI.Full`

### borderColor Interface

- 

  Function

  :

   

  ```
  borderColor(value: ResourceColor | EdgeColors | LocalizedEdgeColors)
  ```

   

  sets border colors.

  - Default value: `Color.Black`

- 

  Support

  :

  - ArkTS Cards: Supported since API version 9
  - Meta Services: Supported since API version 11

- **System Capability**: `SystemCapability.ArkUI.ArkUI.Full`

### borderRadius Interface

- 

  Function

  :

   

  ```
  borderRadius(value: Length | BorderRadiuses | LocalizedBorderRadiuses)
  ```

   

  sets border radii.

  - Maximum radius limited to half of component width/height
  - Supports percentage values (relative to component width)
  - Use with `.clip` to prevent child components from overflowing

- 

  Support

  :

  - ArkTS Cards: Supported since API version 9
  - Meta Services: Supported since API version 11

- **System Capability**: `SystemCapability.ArkUI.ArkUI.Full`

These interfaces provide comprehensive and flexible control over component border styling across different application scenarios.

### Individual Border Direction Setting Example

```
Row().border({
    width: { bottom: 1 }, // Set only bottom border width
    color: { bottom: 'rgba(153, 159, 181, 0.15)' }, // Set only bottom border color
})
```
