# HarmonyOS Flutter Contacts Integration (Accessing Native Address Book)

------

## I. Establishing Channels on the OHOS Side

### **Requesting Permissions**

```
const permissions: Array<Permissions> = [
  'ohos.permission.READ_CONTACTS',
  'ohos.permission.WRITE_CONTACTS'
];
```

### **Key Functionalities**

1. 

   Contact CRUD Operations

   :

   - Query, insert, update, and delete contacts.
   - Manage contact groups and properties.

------

## II. Method Definitions

```
export default class FlutterContactsPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  // ... (Existing code remains unchanged)

  async onMethodCall(call: MethodCall, result: MethodResult) {
    switch (call.method) {
      case "requestPermission":
        // Request read/write contacts permissions from the user
        const atManager = abilityAccessCtrl.createAtManager();
        atManager.requestPermissionsFromUser(this.context, permissions)
          .then((data) => {
            const [readGranted, writeGranted] = data.authResults;
            result.success(readGranted && writeGranted);
          })
          .catch((err) => {
            Log.e(TAG, `Permission request failed: ${err.message}`);
            result.success(false);
          });
        break;

      case "select":
        // Fetch contacts with optional parameters
        const [id, withProperties, withThumbnail, withPhoto, withGroups, withAccounts, returnUnifiedContacts, includeNonVisible] = call.args;
        const contacts = await this.flutterContacts.select(
          this.context!!,
          id,
          withProperties,
          withThumbnail,
          withPhoto,
          withGroups,
          withAccounts,
          returnUnifiedContacts,
          includeNonVisible
        );
        result.success(contacts);
        break;

      case "insert":
        // Insert a new contact
        const contactInsert = call.args[0];
        const insertResult = await this.flutterContacts.insert(this.context!!, contactInsert);
        if (this.eventSink != null) this.eventSink.success(true);
        result.success(insertResult);
        break;

      case "update":
        // Update an existing contact
        const contactUpdate = call.args[0];
        const withGroupsUpdate = call.args[1];
        const updateResult = await this.flutterContacts.update(this.context!!, contactUpdate, withGroupsUpdate);
        if (this.eventSink != null) this.eventSink.success(true);
        result.success(updateResult);
        break;

      case "delete":
        // Delete contacts by ID list
        this.flutterContacts.delete(this.context!!, call.args as List<string>);
        if (this.eventSink != null) this.eventSink.success(true);
        result.success(null);
        break;

      // ... (Other cases remain unchanged)
    }
  }

  // ... (Other methods remain unchanged)
}
```

------

## III. Flutter Code Implementation

### **Channel Setup**

```
static const MethodChannel _channel = MethodChannel('github.com/QuisApp/flutter_contacts');
static const EventChannel _eventChannel = EventChannel('github.com/QuisApp/flutter_contacts/events');
```

### **Fetching Contact Lists**

```
Future<void> _fetchContacts() async {
  bool hasPermission = await FlutterContacts.requestPermission(readonly: true);
  if (!hasPermission) {
    setState(() => _permissionDenied = true);
  } else {
    final contacts = await FlutterContacts.getContacts();
    setState(() => _contacts = contacts);
  }
}
```

------

## IV. Flutter Example Usage

```
import 'package:flutter_contacts/flutter_contacts.dart';

// Request permission and fetch contacts
Future<void> fetchContacts() async {
  if (await FlutterContacts.requestPermission()) {
    final contacts = await FlutterContacts.getContacts();
    print('Fetched contacts: $contacts');
  } else {
    print('Permission denied');
  }
}

// Insert a new contact
Future<void> addContact() async {
  final newContact = Contact(
    displayName: 'John Doe',
    phones: [Item(label: 'mobile', value: '1234567890')],
    emails: [Item(label: 'work', value: 'john@example.com')]
  );
  await FlutterContacts.insert(newContact);
}
```

------

## Key Features

- **Cross-Platform Compatibility**: Works seamlessly with both HarmonyOS and Flutter.
- **Granular Permissions**: Control read/write access to contacts.
- **Flexible Data Handling**: Query, modify, or delete contacts with ease
