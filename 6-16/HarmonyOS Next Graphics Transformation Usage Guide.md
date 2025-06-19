# HarmonyOS Next Graphics Transformation Usage Guide

HarmonyOS Next provides developers with powerful graphics transformation capabilities for rotating, translating, scaling, and performing matrix transformations on components. This greatly enriches the visual effects and user experience of applications. Here is a detailed guide on how to use them:

### 1. Rotation (rotate)

- ​​Function​​: Rotates the component within a coordinate system using the top-left corner as the origin.
- ​​Parameter Description​​
  - RotateOptions Object​​: Contains the rotation axis vector (x, y, z coordinates, default values 0, 0, 1), rotation angle (angle, positive values indicate clockwise rotation, can be a number or string like '90deg'), center point coordinates (centerX, centerY, can be numbers or strings, default '50%'), and z-axis anchor point (centerZ) and perspective (perspective) supported starting from API version 10.
  
- Usage Example​​

```typescript
Row()
   .rotate({
        x: 0,
        y: 0,
        z: 1,
        centerX: '50%',
        centerY: '50%',
        angle: 300
    })
   .width(100).height(100).backgroundColor(0xAFEEEE)
```

### 2. Translation (translate)

- Function​​: Moves the component within the coordinate system.
- ​​Parameter Description​​:
  - TranslateOptions Object​​: Translation distance along the x, y, and z axes (can be numbers or strings like '10px', '10%', default value 0).


- ​​Usage Example

```typescript
Row()
   .translate({ x: 100, y: 10 })
   .width(100).height(100).backgroundColor(0xAFEEEE).margin({ bottom: 10 })
```

### 3. Scaling (scale)

- Function​​: Sets the scaling ratio of the component along the X, Y, and Z axes separately.
- ​​Parameter Description​​
  - ScaleOptions Object​​: Scaling factor for the x, y, and z axes (default value 1; x/y/z > 1 scales up, 0 < x/y/z < 1 scales down, x/y/z < 0 scales inversely), and center point coordinates (centerX, centerY, default '50%').
  
- ​​Usage Example​​:

```typescript
Row()
   .scale({ x: 2, y: 0.5 })
   .width(100).height(100).backgroundColor(0xAFEEEE)
```

### 4. Matrix Transformation (transform)

- Function​​: Implements complex transformation effects by setting a transformation matrix.
- Parameter Description​​: Only supports the Matrix4Transit matrix object type, used to define the component's transformation matrix.

- ​​Usage Example​​:

```typescript
Row()
   .width(100).height(100).backgroundColor(0xAFEEEE)
   .transform(matrix4.identity().translate({ x: 50, y: 50 }).scale({ x: 1.5, y: 1 }).rotate({
        x: 0,
        y: 0,
        z: 1,
        angle: 60
    }))
```

### 5. Notes

- Graphics transformation functionality has been supported since API Version 7, with updates and extensions in subsequent versions, including support within ArkTS Cards and Atomic Services.
- When both rotate and scale properties are set on a component, the values of centerX and centerY will be determined by the last property set.

By flexibly applying these graphics transformation capabilities, developers can create various creative and dynamic application interfaces, enhancing the appeal and interactivity of their applications.