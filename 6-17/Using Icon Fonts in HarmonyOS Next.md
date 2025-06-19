# Using Icon Fonts in HarmonyOS Next

## 1. Register Custom Font

```
import { font } from '@kit.ArkUI';

// Register custom icon font
font.registerFont({
  familyName: 'Icomoon',              // Font family name
  familySrc: '/common/fonts/icomoon.ttf' // Path to font file
})
```

## 2. Create Icon Component

```
// Icon font character mapping
export enum CustomIconType {
  ico_arrow_back = "\ue900",          // Left arrow (back)
  ico_arrow_choosedown = "\ue901",    // Solid down triangle
  ico_arrow_chooseup = "\ue902",      // Solid up triangle
  ico_arrow_down = "\ue903",          // Down arrow
  ico_arrow_more = "\ue904",          // Right arrow (more)
  ico_arrow_up = "\ue905",            // Up arrow
  ico_choose_on = "\ue906",           // Checkmark (selected)
  ico_close = "\ue907",               // Close (X)
  ico_correct = "\ue908",             // Correction icon
  ico_listarrow_down = "\ue90a",      // Expand down
  ico_listarrow_up = "\ue90b",        // Collapse up
  ico_listmore = "\ue90c",            // Horizontal dots (more)
  ico_lock = "\ue90d",                // Lock
  ico_mode_bright = "\ue90e",         // Sun (light mode)
  ico_mode_night = "\ue90f",          // Moon (dark mode)
  ico_restart = "\ue910",             // Restart
  ico_screen = "\ue911",              // Filter
  ico_switch = "\ue912",              // Switch subjects
  ico_write = "\ue913",               // Pencil (write)
  ico_arrow_check = "\ue914",         // Arrow checkmark
  ico_selected = "\ue914",            // Checkmark (√)
  ico_video_play = "\ue915",          // Video play
  icon_reload = "\ue916",             // Refresh
  ico_reload = "\ue916",              // Circular reload
  icon_notice = "\ue917",             // Notification
  ico_notice = "\ue917",              // Speaker (broadcast)
  ico_aisearch = "\ue918",            // AI robot
  ico_intelligence_search = "\ue918", // Smart search
  ico_clock = "\ue919",               // Clock
  icon_clock = "\ue919",              // Clock icon
  icon_search = "\ue91a",             // Search
  ico_search = "\ue91a",              // Search icon
  ico_discribe = "\ue91b",            // Question mark in circle
  icon_discribe = "\ue91b",           // Question icon
  icon_location = "\ue91c",           // Location
  icon_change = "\ue91d",             // Swap
  icon_filter = "\ue91e",             // Filter
  icon_choose = "\ue91f",             // Empty circle
  icon_share = "\ue920",              // Share
  icon_collect = "\ue921",            // Solid star (favorite)
  icon_like = "\ue922",               // Thumbs up
  icon_off = "\ue923",                // No entry (solid)
  icon_answer = "\ue924",             // View answer
  icon_mark_off = "\ue925",           // Bookmark off
  icon_collect_off = "\ue926",        // Empty star (unfavorited)
  icon_mark_on = "\ue927",            // Bookmark on
  icon_doubt = "\ue928",              // Info in circle
  icon_points = "\ue929",             // Article favorite
  icon_data = "\ue92a",               // Data
  icon_advice = "\ue92b",             // Edit article
  icon_next = "\ue92c",               // Next article
  icon_add = "\ue92d",                // Plus
  icon_wrong = "\ue92e",              // X in circle
  icon_timer = "\ue92f",              // Timer
  icon_aim = "\ue930",                // Target
  icon_delete = "\ue931",             // Trash
  icon_setting = "\ue932",            // Settings
  icon_notes = "\ue933",              // Notes
  icon_aimed = "\ue934",              // Target (selected)
  icon_function = "\ue935",           // Function
  icon_catalog = "\ue936",            // Menu
  icon_text = "\ue937",               // Text (Aa)
  icon_exit = "\ue938",               // Power off
  icon_teacher = "\ue939",            // Teacher
  icon_nomore = "\ue93a",             // No entry (hollow)
  icon_nomore_1 = "\ue93b",           // No entry (solid 2)
  icon_mark = "\ue93c",               // Pushpin
  icon_fullscreen = "\ue93d",         // Fullscreen
  icon_download = "\ue93e",           // Download
  icon_director = "\ue93f",           // Left arrow (←)
  icon_scan = "\ue940",               // QR scan
  icon_wrongnote = "\ue941",          // Error notes
  icon_record = "\ue942",             // History
  icon_full_screen = "\ue93d",        // Fullscreen (alias)
  icon_video = "\ue943",              // Video
  icon_clear = "\ue944",              // Clear progress
  icon_remind = "\ue945",             // Alarm clock
}

// Reusable icon component
@Component
export struct CustomIcon {
  @Prop iconType: CustomIconType      // Icon selection
  @Prop iconSize: number = 23         // Default size (vp)
  @Prop iconWeight: FontWeight = FontWeight.Normal // Font weight
  @Prop iconColor: ResourceColor = $r("app.color.blodTextColor") // Default color

  build() {
    Text(this.iconType)
      .fontSize(this.iconSize)
      .fontFamily('Icomoon')          // Use registered font
      .fontWeight(this.iconWeight)
      .fontColor(this.iconColor)
  }
}
```

## 3. Using Icons in UI

```
// Basic usage
CustomIcon({
  iconType: CustomIconType.icon_collect,
  iconSize: 23,
})

// Customized example
CustomIcon({
  iconType: CustomIconType.ico_mode_night, // Dark mode icon
  iconSize: 28,
  iconColor: Color.Blue
})

// With click handler
CustomIcon({
  iconType: CustomIconType.icon_delete,
  iconSize: 24,
  iconColor: Color.Red
})
.onClick(() => {
  // Handle delete action
})
```

### Key Benefits:

1. **Vector Quality**: Icons scale perfectly at any size
2. **Single HTTP Request**: All icons in one font file
3. **CSS Control**: Easily change color, size, and effects
4. **Accessibility**: Better for screen readers than image icons
5. **Performance**: Smaller footprint than individual image assets

### Implementation Notes:

- Place font files in `common/fonts/` directory
- Register fonts early in app lifecycle (e.g., in main entry file)
- Use enum for type safety and autocomplete support
- Default colors reference resource files for theme consistency
