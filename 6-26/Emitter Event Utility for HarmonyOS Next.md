# Emitter Event Utility for HarmonyOS Next

	```typescript
	import { emitter } from '@kit.BasicServicesKit';
	
	// Define custom event IDs for type safety and autocompletion
	type EmitterEventId = "parentShowNext" | "parentShowPrevious" | "customEvent1" | "customEvent2";
	
	export class EmitterUtil {
	  private constructor() {} // Prevent instantiation
	
	  /**
	   * Emit an event with optional data
	   * @param eventId Unique event identifier
	   * @param data Optional payload to send with event
	   * @param priority Event priority (default: HIGH)
	   */
	  static emit(
	    eventId: EmitterEventId, 
	    data?: Object, 
	    priority: emitter.EventPriority = emitter.EventPriority.HIGH
	  ) {
	    const eventData: emitter.EventData = { data: { "eventData": data } };
	    const options: emitter.Options = { priority };
	    emitter.emit(eventId, options, eventData);
	  }
	
	  /**
	   * Subscribe to an event
	   * @param eventId Event identifier to listen for
	   * @param callback Function to execute when event occurs
	   */
	  static subscribe(
	    eventId: EmitterEventId, 
	    callback: (data?: Object) => void
	  ) {
	    emitter.on(eventId, (eventData: emitter.EventData) => {
	      callback(eventData.data?.eventData);
	    });
	  }
	
	  /**
	   * Subscribe to an event only once
	   * @param eventId Event identifier to listen for
	   * @param callback Function to execute when event occurs (only once)
	   */
	  static subscribeOnce(
	    eventId: EmitterEventId, 
	    callback: (data?: Object) => void
	  ) {
	    emitter.once(eventId, (eventData: emitter.EventData) => {
	      callback(eventData.data?.eventData);
	    });
	  }
	
	  /**
	   * Unsubscribe from an event
	   * @param eventId Event identifier to stop listening to
	   */
	  static unsubscribe(eventId: EmitterEventId) {
	    emitter.off(eventId);
	  }
	}
	```

## Usage Examples

### 1. Emitting Events
	```typescript
	// Send event without data
	EmitterUtil.emit("parentShowNext");
	
	// Send event with data payload
	EmitterUtil.emit("parentShowPrevious", { page: 3, action: "navigate" });
	
	// Send high-priority event
	EmitterUtil.emit("customEvent1", { value: 42 }, emitter.EventPriority.IMMEDIATE);
	```

### 2. Subscribing to Events
	```typescript
	// Regular subscription
	EmitterUtil.subscribe("parentShowNext", (data) => {
	  console.log("Next button event received", data);
	});
	
	// One-time subscription
	EmitterUtil.subscribeOnce("parentShowPrevious", (data) => {
	  console.log("Previous button event (first occurrence only)", data);
	});
	```

### 3. Unsubscribing from Events
	```typescript
	// Unsubscribe when no longer needed
	EmitterUtil.unsubscribe("parentShowNext");
	```

## Key Features

1. **Type-Safe Events**:
   - Custom `EmitterEventId` type ensures valid event names
   - Prevents typos and invalid event references
   - Enables IDE autocompletion for event names

2. **Simplified API**:
   - Unified methods for common emitter operations
   - Consistent parameter ordering across methods
   - Default values for optional parameters

3. **Data Handling**:
   - Automatic payload wrapping/unwrapping
   - Optional data parameter for event emission
   - Type-safe data retrieval in callbacks

4. **Priority Control**:
   - Supports all HarmonyOS event priorities:
     - `IMMEDIATE`: Highest priority
     - `HIGH`: Default priority
     - `LOW`: Lower priority
     - `IDLE`: Lowest priority

5. **Memory Management**:
   - Explicit unsubscribe method
   - Prevents memory leaks from lingering subscriptions
   - Clean API for resource management

## Benefits Over Native Implementation

1. **Reduced Boilerplate**:
   ```diff
   - const eventData = { data: { "eventData": payload } };
   - const options = { priority: emitter.EventPriority.HIGH };
   - emitter.emit("myEvent", options, eventData);
   + EmitterUtil.emit("myEvent", payload);
   ```

2. **Consistent Payload Handling**:
   - Automatic payload encapsulation
   - Simplified data access in callbacks

3. **Type Enforcement**:
   - Prevents runtime errors from invalid event names
   - Enables better code documentation

4. **Error Prevention**:
   - Default priority reduces configuration errors
   - Clear method names improve code readability

This utility provides a robust abstraction over HarmonyOS's native emitter API, making cross-component communication cleaner, safer, and more maintainable in HarmonyOS Next applications.