# Deep Observation of Object Array Changes for HarmonyOS Next

**Preface**:
In practical application development, we find that standard decorators have limitations—they only observe first-level changes. However, applications often need to encapsulate complex data models. When dealing with multi-level nesting (like 2D arrays, class array items, or class properties containing other classes), second-level property changes become unobservable. This gap severely impacts monitoring complex data structure changes. The solution comes with `@Observed`/`@ObjectLink` decorators, which enable observation of nested data structure property changes, ensuring accurate data processing in applications.

These decorators provide two-way data synchronization for nested objects or arrays:

```
let NextID: number = 1;

// Observe array objects using decorator
@Observed
class Info {
  public id: number;
  public info: number;

  constructor(info: number) {
    this.id = NextID++;
    this.info = info;
  }
}

// @ObjectLink must be placed in child components
@Component
struct Child {
  // Child component's @ObjectLink is of type Info
  @ObjectLink info: Info;
  label: string = 'ViewChild';

  build() {
    Row() {
      Button(`ViewChild [${this.label}] this.info.info = ${this.info ? this.info.info : "undefined"}`)
        .width(320)
        .margin(10)
        .onClick(() => {
          this.info.info += 1; // Nested property change
        })
    }
  }
}

@Entry
@Component
struct Parent {
  // Always use 'new' for observable changes
  @State arrA: Info[] = [new Info(0), new Info(0)];

  build() {
    Column() {
      ForEach(this.arrA,
        (item: Info) => {
          Child({ label: `#${item.id}`, info: item })
        },
        (item: Info): string => item.id.toString()
      )
      // Initialize @ObjectLink with @Observed items
      Child({ label: `ViewChild this.arrA[first]`, info: this.arrA[0] })
      Child({ label: `ViewChild this.arrA[last]`, info: this.arrA[this.arrA.length-1] })

      Button(`ViewParent: reset array`)
        .onClick(() => {
          this.arrA = [new Info(0), new Info(0)]; // Full array reset
        })
        
      Button(`ViewParent: push`)
        .onClick(() => {
          this.arrA.push(new Info(0)) // Add new item
        })
        
      Button(`ViewParent: shift`)
        .onClick(() => {
          this.arrA.length > 0 && this.arrA.shift() // Remove first item
        })
        
      Button(`Update middle item property`)
        .onClick(() => {
          // Direct nested property modification
          this.arrA[Math.floor(this.arrA.length / 2)].info = 10;
        })
        
      Button(`Replace middle item`)
        .onClick(() => {
          // Full item replacement
          this.arrA[Math.floor(this.arrA.length / 2)] = new Info(11);
        })
    }
  }
}
```

### Key Implementation Notes:

1. **@Observed Class**:
   - Applied to classes containing nested data
   - Enables deep observation of class instances in arrays
2. **@ObjectLink in Child Components**:
   - Creates bidirectional binding with nested objects
   - Must be used in child components receiving observed objects
3. **Array Operations**:
   - Supports all standard array methods (`push`, `shift`, etc.)
   - Both property-level and full-item changes are observable
4. **Initialization Requirement**:
   - Always use `new` when creating observable objects
   - Direct assignment of plain objects won't trigger updates

This approach provides comprehensive observation capabilities for complex nested data structures in HarmonyOS applications.