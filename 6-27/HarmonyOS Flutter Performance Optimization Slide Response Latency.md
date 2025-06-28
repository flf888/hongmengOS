# HarmonyOS Flutter Performance Optimization: Slide Response Latency

This article analyzes trace diagnostics for slide response latency in Flutter applications under touch interaction scenarios.

## **Finger Press (Initial Touch)**
The finger press event establishes the foundation for all subsequent interactions, capturing:
- Initial touch coordinates
- Targeted UI controls
- Interaction context

### Event Flow:
1. **mmi_service thread** handles multimodal input events
2. **Flutter application** listens and responds to touch events

### Trace Characteristics:
- In `mmi_service` thread:  
  `"service report touchId:[id], type: down"` immediately after `"package touchEvent"`
- In application main thread:  
  `"DispatchTouchEvent"` with coordinates and `type: 0` (down event)

These traces correspond directly across threads:



## **Finger Slide (Movement)**
Slide events follow a controlled delivery mechanism different from initial presses.

### Key Differences:
- **Not immediate**: Governed by `vsync-app` signal
- **Initial position**: Matches press coordinates (first move event)
- **Type identifier**: `type: move` (numerical value: 2)

### Event Sequence:
1. `mmi_service` thread detects movement
2. `VSyncGenerator` produces synchronization signal
3. `DVSync-app` processes the signal
4. Application main thread receives event

### Trace Flow:



## **Slide Threshold (TouchSlop)**
The system-defined minimum recognition distance for slide gestures:
- **Default value**: 18 units
- **Customizable**: Developers can adjust per control

### Calculation Method:
1. Capture touch coordinates from main thread traces
2. Compute coordinate offsets between events
3. Verify if offset exceeds threshold:
   ```javascript
   const distance = Math.sqrt(
     Math.abs(x2 - x1)**2 + 
     Math.abs(y2 - y1)**2
   );
   const isSlide = distance > TOUCH_SLOP;
   ```

## **First Frame Rendering**
When slide distance exceeds threshold:
1. Flutter triggers UI update operations
2. Actual rendering waits for next VSync signal
3. One-frame delay occurs before visual update

### Trace Pattern:



## **First Frame Completion**
Rendering completion identification:
- **Development tracing**: `RSHardwareThread` in RS process
- **Automated testing**: `dpu_gfx_primary` thread (hardware signal proxy)

### Completion Trace:



## **Measuring Slide Response Latency**
Total response duration spans:
	```
	Start: mmi_service "package touchEvent" (finger press)
	End: RSHardwareThread/dpu_gfx_primary (first slide frame rendered)
	```

### Optimization Focus Areas:
1. **Touch event propagation time**
2. **VSync signal generation latency**
3. **Frame scheduling efficiency**
4. **Render service processing time**
5. **Hardware composition duration**

This analysis methodology enables precise identification of performance bottlenecks in Flutter slide interactions on HarmonyOS, providing actionable insights for latency reduction.