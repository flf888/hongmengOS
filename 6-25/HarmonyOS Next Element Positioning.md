# HarmonyOS Next Element Positioning

### Introduction

In HarmonyOS Next, child elements use the **.position()** attribute for relative positioning within parent elements. Usage example:

```
@Entry
@Component
struct PositionExample1 {
  build() {
    Column() {
        Row() {
            
        }
        .position({x: 50, y: 50})
    }
    .width('100%')
    .height('100%')
  }
}
```

This positions the child element 50 units from the parent's left and top edges.

A common challenge is positioning elements near the right edge, especially given the diverse screen sizes across devices. How can we ensure consistent positioning across different devices?

We propose a solution using the LocalizedEdges type. This approach accounts for device diversity by:

1. Identifying device types
2. Adapting to screen dimensions
3. Maintaining consistent positioning across devices

### Solution

Official documentation:
\#position

Use LocalizedEdges for positioning relative to parent container edges, with mirroring support. This is ideal for:

- Fixed-position elements
- Floating action buttons
- Top-aligned components
- Edge-sensitive designs

Example of bottom-right positioning:

```
@Entry
@Component
struct PositionExample1 {
  build() {
    Column() {
        Row() {
            
        }
        // bottom: Offset from bottom edge
        // end: Offset from right edge (supports RTL mirroring)
        .position(bottom: { value: 20, unit: 2 }, end: { value: 20, unit: 2 })
    }
    .width('100%')
    .height('100%')
  }
}
```

Key features:

- `unit: 2` specifies percentage-based positioning
- Works consistently across all screen sizes
- Automatically adjusts for right-to-left languages
- Maintains design integrity on any device

This concludes our overview of advanced positioning techniques in HarmonyOS Next.
