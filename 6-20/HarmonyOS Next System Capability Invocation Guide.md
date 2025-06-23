# HarmonyOS Next System Capability Invocation Guide

## 1. Basic Environment Setup

Before utilizing HarmonyOS Next’s system capabilities, ensure proper development environment setup, including installing tools like DevEco Studio and configuring SDKs/dependencies. Follow the official documentation to complete setup before proceeding.

------

## 2. UI Construction & Interaction Capabilities

HarmonyOS Next provides flexible UI components via the **ArkUI** framework. Here’s a simple example of text display and button interaction:

```
import { Text, Button } from '@ohos.arkui';

@Entry
@Component
struct MyPage {
  @State message: string = 'Hello, HarmonyOS Next';

  build() {
    Column() {
      Text(this.message)
      Button('Click Me')
        .onClick(() => {
          this.message = 'Button Clicked!';
        })
    }
  }
}
```

**Explanation**:

- A vertical layout with a `Text` component and a `Button`.
- Clicking the button updates the text, demonstrating basic UI interactivity.

------

## 3. Data Storage & Management

Use **Preferences** for local key-value storage:

```
import preferences from '@ohos.data.preferences';

async function storeData() {
  const pref = await preferences.getPreferences('my_data_store');
  await pref.put('key', 'value');
  const value = await pref.get('key', 'default_value');
  console.log('Stored value:', value);
}
```

**Key Actions**:

- Creates a storage instance named `my_data_store`.
- Stores/retrieves values and logs them to the console.

------

## 4. Device Capability Invocation

Access device hardware features, such as **location services**:

```
import location from '@ohos.location';

async function getLocation() {
  const locator = location.createLocator();
  locator.on('locationChange', (location) => {
    console.log('Latitude:', location.latitude);
    console.log('Longitude:', location.longitude);
  });
  await locator.start();
}
```

**Functionality**:

- Initializes a location tracker and logs real-time coordinates.

------

## 5. Distributed Capabilities

Demonstrates cross-device communication via **distributed soft bus**:

```
import rpc from '@ohos.rpc';

// Server-side code
async function startServer() {
  const elementName = {
    bundleName: 'com.example.myapp',
    abilityName: 'MyAbility'
  };
  const remoteObject = rpc.RemoteObject.create('MyService', {
    onRemoteRequest(code, data, reply, option) {
      if (code === 1) reply.writeInt(42);
      return true;
    }
  });
  rpc.addAbility(elementName, remoteObject);
}

// Client-side code
async function callServer() {
  const elementName = {
    bundleName: 'com.example.myapp',
    abilityName: 'MyAbility'
  };
  const proxy = rpc.getProxy(elementName);
  const result = await proxy.sendRequest(1);
  console.log('Server response:', result.readInt());
}
```

**Workflow**:

1. The server registers a service and listens for requests.
2. The client sends a request (code `1`) and receives a response (`42`).

------

## Key Takeaways

- **UI Development**: Use ArkUI for responsive layouts and interactive components.
- **Data Management**: Leverage `Preferences` for lightweight local storage.
- **Device Integration**: Access sensors/hardware via specialized modules (e.g., `location`).
- **Distributed Features**: Enable seamless cross-device communication with RPC.

Experiment with these capabilities to build innovative HarmonyOS Next applications