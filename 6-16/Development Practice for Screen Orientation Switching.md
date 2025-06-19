
### Development Practice for Screen Orientation Switching

Implementing screen orientation switching (landscape/portrait) in HarmonyOS application development requires attention to multiple aspects.

### Window Rotation Strategy Selection

1. **Configuration in module.json5**:  
   Suitable for applications that determine orientation at launch. Examples:  
   - Portrait-only apps: Configure `"portrait"`  
   - Landscape-only apps: `"landscape"` (single orientation) or `"auto_rotation_landscape"` (supports normal/reverse landscape)  
   - Rotatable apps: `"auto_rotation_restricted"`  
   - Devices adapting to form factors: `"follow_desktop"` (phones in portrait, tablets/foldables in landscape when unfolded)  
   *Note: Configurations with "restricted" are controlled by the system's Rotation Lock toggle.*

2. **setPreferredOrientation Method**:  
   Used for dynamically changing orientation after app launch (e.g., video/photo apps). Once set, the orientation persists across page navigation.

### Landscape/Portrait Implementation for Video Apps

1. **Set Rotation Strategy**:  
   - Initialize with `"follow_desktop"` at launch  
   - In video playback pages:  
     ```typescript
     // Get window instance
     const window = getContext().windowStage.getMainWindowSync()
     // Set orientation based on user action (e.g., fullscreen button)
     window.setPreferredOrientation(display.Orientation.USER_ROTATION_LANDSCAPE) 
     ```

2. **Monitor Window Changes**:  
   ```typescript
   aboutToAppear() {
     window.on('windowSizeChange', (newSize) => {
       const isLandscape = newSize.width > newSize.height
       // Update UI layout
     })
   }
   aboutToDisappear() {
     window.off('windowSizeChange')
   }
   ```

3. **Layout Adaptation**:  
   - Bind video player size to state variables:  
     ```typescript
     @State playerWidth: number = 300
     @State playerHeight: number = 200
     ```
   - In windowSizeChange callback:  
     ```typescript
     if (isLandscape) {
       this.playerWidth = newSize.width
       this.playerHeight = newSize.height
     }
     ```

4. **Screen Lock Handling**:  
   ```typescript
   // Lock screen
   window.setPreferredOrientation(display.Orientation.AUTO_ROTATION_LANDSCAPE)
   
   // Unlock screen
   window.setPreferredOrientation(display.Orientation.AUTO_ROTATION_UNSPECIFIED)
   
   // Monitor Rotation Lock state
   settings.registerKeyObserver(settings.Key.KEY_ROTATION_LOCK, (locked) => {
     // Handle lock state changes
   })
   ```

### Landscape Implementation for Game Apps

1. **Landscape-Only**:  
   Configure `"orientation": "landscape"` in module.json5

2. **Support Reverse Landscape**:  
   Use `"auto_rotation_landscape"` or `"auto_rotation_landscape_restricted"` (respects system Rotation Lock)

3. **Portrait-to-Landscape Switching**:  
   Call `setPreferredOrientation()` when entering gameplay from portrait menus

### Performance Optimization

1. **Component Freezing**:  
   ```typescript
   @Component({ freezeWhenInactive: true })
   struct DetailComponent {
     // UI won't update during rotation
   }
   ```

2. **Image Auto-Resizing**:  
   ```typescript
   Image($r('app.media.cover'))
     .autoResize(true) // Reduces memory usage
   ```

3. **Performance Pitfalls**:  
   Avoid:  
   - Redundant `onAreaChange` listeners  
   - Heavy visual effects (e.g., blur, complex gradients)  
   - Unnecessary layout calculations during rotation  

### Common Issues & Solutions

1. **Tabs Visibility in Fullscreen Video**:  
   ```typescript
   Tabs() {
     // ...
   }
   .barHeight(this.isFullscreen ? 0 : 50) // Dynamically hide/show
   ```

2. **Inconsistent Rotation Behavior**:  
   Set `"orientation": "follow_desktop"` in module.json5 for consistent behavior across devices

3. **Window Instance Delay**:  
   Use synchronous method:  
   ```typescript
   const window = getContext().windowStage.getMainWindowSync() // Avoid async delays
   ```

4. **Rotation Lock Interaction**:  
   | System Setting | Restricted Config | Non-restricted Config |
   |----------------|-------------------|----------------------|
   | Rotation Lock ON | App won't rotate | App still rotates |
   | Rotation Lock OFF | App rotates | App rotates |
