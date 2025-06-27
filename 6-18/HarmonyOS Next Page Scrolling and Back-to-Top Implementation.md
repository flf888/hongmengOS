# HarmonyOS Next Page Scrolling and Back-to-Top Implementation

### Introduction

When building page layouts in HarmonyOS Next, developers often encounter a common challenge: content exceeding the screen height without scroll functionality. The desired behavior is to enable vertical scrolling when content overflows, but sometimes scrolling fails to work as expected. This guide provides an effective solution to implement scrolling and add a back-to-top feature.

### Implementing Basic Scrolling

Wrap your content with the `Scroll` component to enable vertical scrolling:

```
@Entry
@Component
struct NestedScroll {
    build() {
        Scroll() {
            // Note: Scroll can only have one root element
            Column() {
                // Main content
            }
            .width('100%')
            .height('100%')
        }
        .width('100%')
        .height('100%')
    }
}
```

This implementation allows vertical scrolling when content exceeds screen height.

### Adding Back-to-Top Functionality

Implement a scroll controller and back-to-top button:

```
@Entry
@Component
struct NestedScroll {
    private scroller: Scroller = new Scroller()
    @State show_to_top: boolean = false; // Controls back-to-top visibility
    
    build() {
        Column() {
            Scroll(this.scroller) {
                // Scroll requires single root element
                Column() {
                    // Main content
                }
                .width('100%')
                .height('100%')
            }
            .width('100%')
            .height('100%')
            .onDidScroll(() => {
                // Show button when scrolled beyond 50 units
                if (this.scroller.currentOffset().yOffset < 50) {
                    this.show_to_top = false;
                } else {
                    this.show_to_top = true;
                }
            })
            
            // Back-to-top button
            if (this.show_to_top) {
                Column() {
                    Image(Utils.getImgPath('course/back_top.png'))
                        .height(80)
                        .width(80)
                        .onClick(() => {
                        	// Scroll to top on click
                        	this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
                    	})
                }
                .position({ 
                    bottom: { value: 85, unit: 1 }, // 85vp from bottom
                    end: { value: -5, unit: 1 }     // 5vp from right edge
                })
            }
        }
        .width('100%')
        .height('100%')
    }
}
```

### Key Features:

1. **Scroller Controller**: Manages scroll position and behavior
2. **Scroll Position Tracking**: Shows/hides button based on scroll depth
3. **Positioning**: Places button in bottom-right corner
4. **Smooth Navigation**: Instantly returns to top when clicked

This implementation ensures:

- Seamless scrolling for overflow content
- Intuitive user experience with back-to-top functionality
- Adaptive positioning across different screen sizes
- Efficient performance with state-based rendering