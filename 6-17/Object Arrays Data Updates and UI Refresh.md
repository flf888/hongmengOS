# Object Arrays: Data Updates and UI Refresh

### Introduction

Object arrays are an extremely common data structure in programming, efficiently storing and processing sets of related objects. In HarmonyOS Next, this data structure has widespread applications.

For example, when developing a simple contact management application, we can use an object array. Each contact is an object containing properties like name, phone number, and email. For instance:

```
[
    {name: 'Zhang San', phone: '123456789', email: 'zhangsan@example.com'}, 
    {name: 'Li Si', phone: '987654321', email: 'lisi@example.com'},
]
```

This object array structure facilitates operations like traversing, searching, adding, and deleting contact information, enabling efficient contact management.

In HarmonyOS Next, a special case occurs when using object arrays to generate lists. When data in an object within the list is updated, it unexpectedly does not trigger a UI page refresh. This behavior differs from typical expectations and may cause confusion during development. Developers need to pay special attention to this characteristic to accurately analyze and resolve related issues, ensuring consistency between the application's UI display and data state.

To address this issue, we can take specific measures.

### Direct Assignment Does Not Refresh UI

For example:

```
@Entry
@Component
struct ViewB {
  // ViewB has @State decorated ClassA[]
  @State arrA: ClassA[] = [{name: 'Zhang San', phone: '123456789'}, {name: 'Li Si', phone: '987654321'}];

  build() {
      ForEach(this.arrA, (item: ClassA, index: number) => {
          Text(item.phone)
          Button(`Change number to 888888`)
              .width(320)
              .margin(10)
              .onClick(() => {
                    this.arrA[index].phone = '888888';
                })
      },
  }
 }
```

### Restructuring and Reassigning the Object Refreshes UI

For example:

```
@Entry
@Component
struct ViewB {
  // ViewB has @State decorated ClassA[]
  @State arrA: ClassA[] = [{name: 'Zhang San', phone: '123456789'}, {name: 'Li Si', phone: '987654321'}];

  build() {
      ForEach(this.arrA, (item: ClassA, index: number) => {
          Text(item.phone)
          Button(`Change number to 888888`)
              .width(320)
              .margin(10)
              .onClick(() => {
                    this.arrA[index].phone = '888888';
                    // Destructure and reassign
                    this.arrA = [...this.arrA];
                })
      },
  }
 }
```

Through this demo, we understand the immediate refresh behavior of object arrays. However, a minor issue remains: when refreshing page data by reassigning the array, the entire list flickers briefly. This flickering may impact user experience, especially in applications requiring high visual quality. But don't worry—we've noted this issue. In the next installment, we'll explain how to resolve this list flickering problem, helping developers further optimize the user interface in HarmonyOS Next applications.