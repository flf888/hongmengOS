# Implementing Responsive Knowledge Point Layouts in HarmonyOS Next

## 1. Window Breakpoint Detection on App Launch
	```typescript
	// Update breakpoint based on current window dimensions
	private updateBreakpoint(windowWidth: number): void {
	  try {
	    // Convert px to vp (virtual pixels)
	    const windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels;
	    
	    console.log('Calculated windowWidthVp', windowWidthVp);
	    let newBp: string = '';
	    
	    // Determine breakpoint based on width
	    if (windowWidthVp < 600) {
	      newBp = 'sm'; // Small screens (phones)
	    } else if (windowWidthVp < 840) {
	      newBp = 'md'; // Medium screens (tablets)
	    } else {
	      newBp = 'lg'; // Large screens (desktops)
	    }
	
	    // Update global breakpoint state if changed
	    if (this.curBp !== newBp) {
	      this.curBp = newBp;
	      AppStorage.setOrCreate('currentBreakpoint', this.curBp);
	    }
	  } catch (err) {
	    console.error("Display sync failed: " + err.code);
	  }
	}
	```

## 2. Universal Breakpoint Utility Class
	```typescript
	interface BreakPointTypeOption<T> {
	  sm?: T; // Small screen configuration
	  md?: T; // Medium screen configuration
	  lg?: T; // Large screen configuration
	}
	
	/**
	 * Media Query Utility
	 * Core of responsive design implementation
	 */
	export class BreakPointType<T> {
	  options: BreakPointTypeOption<T>;
	
	  constructor(option: BreakPointTypeOption<T>) {
	    this.options = option;
	  }
	
	  // Get value for current breakpoint
	  getValue(currentBreakPoint: string): T {
	    return this.options[currentBreakPoint] as T;
	  }
	}
	```

## 3. Responsive Knowledge Point Layout
	```typescript
	GridRow({
	  gutter: Utils.getVp(23) // Responsive gutter spacing
	}) {
	  ForEach(this.knowledgeDataList, (item: KnowledgeItem, tempIndex) => {
	    GridCol({
	      // Responsive column span configuration:
	      // - sm (phones): 12 columns = 1 item per row
	      // - md (tablets): 6 columns = 2 items per row
	      // - lg (desktops): 4 columns = 3 items per row
	      span: { sm: 12, md: 6, lg: 4 }
	    }) {
	      KnowledgeListItemLayout({ 
	        knowledgeInfo: item, 
	        level: 0 
	      });
	    }
	  })
	}
	```

## Implementation Details

### 1. Breakpoint Detection
- **Unit Conversion**: Converts physical pixels (px) to virtual pixels (vp) for consistent sizing
- **Breakpoint Thresholds**:
  - `sm`: < 600vp (mobile phones)
  - `md`: 600-840vp (tablets)
  - `lg`: ≥ 840vp (desktops/large tablets)
- **Global State**: Stores current breakpoint in `AppStorage` for app-wide access

### 2. Breakpoint Utility Features
- **Type-Safe Configuration**: Generic class works with any data type
- **Simple Value Retrieval**: `getValue()` returns configuration for current breakpoint
- **Extensible Design**: Easily add new breakpoints as needed

### 3. Responsive Grid Implementation
- **GridRow**: Container for responsive grid system
- **GridCol**: Responsive columns with breakpoint-specific spans
- **Layout Behavior**:
  - **Phones (sm)**: 1 item per row (12/12 columns)
  - **Tablets (md)**: 2 items per row (6/12 columns each)
  - **Large Screens (lg)**: 3 items per row (4/12 columns each)
- **Gutter Spacing**: Responsive spacing between items using `Utils.getVp()`

## Usage Example
	```typescript
	// Create responsive configuration
	const responsiveColors = new BreakPointType<string>({
	  sm: '#FF5733', // Red for mobile
	  md: '#33FF57', // Green for tablets
	  lg: '#3357FF'  // Blue for desktops
	});
	
	// Get current color based on breakpoint
	const currentColor = responsiveColors.getValue(AppStorage.get('currentBreakpoint'));
	```

This implementation provides a complete responsive design solution for HarmonyOS Next applications, enabling adaptive layouts that automatically adjust to different screen sizes and device types.