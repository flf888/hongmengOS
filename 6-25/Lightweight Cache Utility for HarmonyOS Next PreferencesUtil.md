# Lightweight Cache Utility for HarmonyOS Next: PreferencesUtil

```
import preferences from '@ohos.data.preferences';
import dataPreferences from '@ohos.data.preferences';
import { AppUtil } from './AppUtil';

type PreferencesValue = string | number | boolean;

/**
 * Lightweight cache utility using Preferences
 */
export class PreferencesUtil {
  private constructor() {}

  private static defaultPreferenceName: string = "appPreferences";
  private static preferences: preferences.Preferences;

  /**
   * Get Preferences instance synchronously
   * @returns Preferences instance
   */
  private static getPreferencesSync(): preferences.Preferences {
    if (!PreferencesUtil.preferences) {
      PreferencesUtil.preferences = dataPreferences.getPreferencesSync(
        AppUtil.getContext(), 
        { name: PreferencesUtil.defaultPreferenceName }
      );
    }
    return PreferencesUtil.preferences;
  }

  /**
   * Get Preferences instance asynchronously
   * @returns Promise with Preferences instance
   */
  private static async getPreferences(): Promise<preferences.Preferences> {
    if (!PreferencesUtil.preferences) {
      PreferencesUtil.preferences = await dataPreferences.getPreferences(
        AppUtil.getContext(), 
        PreferencesUtil.defaultPreferenceName
      );
    }
    return PreferencesUtil.preferences;
  }

  /**
   * Store data synchronously
   * @param key Storage key
   * @param value Value to store
   */
  static putSync(key: string, value: PreferencesValue) {
    const prefs = PreferencesUtil.getPreferencesSync();
    prefs.putSync(key, value);
    prefs.flush(); // Required for permanent storage
  }

  /**
   * Store data asynchronously
   * @param key Storage key
   * @param value Value to store
   */
  static async put(key: string, value: PreferencesValue) {
    const prefs = await PreferencesUtil.getPreferences();
    await prefs.put(key, value);
    await prefs.flush(); // Required for permanent storage
  }

  /**
   * Retrieve value synchronously
   * @param key Storage key
   * @param defValue Default value if key not found
   * @returns Stored value or default
   */
  static getSync(key: string, defValue: PreferencesValue): PreferencesValue {
    const prefs = PreferencesUtil.getPreferencesSync();
    return prefs.getSync(key, defValue) as PreferencesValue;
  }

  /**
   * Retrieve value asynchronously
   * @param key Storage key
   * @param defValue Default value if key not found
   * @returns Promise with stored value or default
   */
  static async get(key: string, defValue: PreferencesValue): Promise<PreferencesValue> {
    const prefs = await PreferencesUtil.getPreferences();
    return prefs.get(key, defValue) as Promise<PreferencesValue>;
  }

  /**
   * Get all stored values synchronously
   * @returns All key-value pairs
   */
  static getAllSync() {
    return PreferencesUtil.getPreferencesSync().getAllSync();
  }

  /**
   * Get string value synchronously
   * @param key Storage key
   * @returns String value or empty string
   */
  static getStringSync(key: string): string {
    return PreferencesUtil.getSync(key, "") as string;
  }

  /**
   * Get string value asynchronously
   * @param key Storage key
   * @returns Promise with string value or empty string
   */
  static async getString(key: string): Promise<string> {
    return (await PreferencesUtil.get(key, "")) as string;
  }

  /**
   * Check if key exists synchronously
   * @param key Storage key
   * @returns True if key exists
   */
  static hasSync(key: string): boolean {
    return PreferencesUtil.getPreferencesSync().hasSync(key);
  }

  /**
   * Check if key exists asynchronously
   * @param key Storage key
   * @returns Promise with existence status
   */
  static async has(key: string): Promise<boolean> {
    const prefs = await PreferencesUtil.getPreferences();
    return prefs.has(key);
  }

  /**
   * Delete key-value pair synchronously
   * @param key Storage key
   */
  static deleteSync(key: string) {
    const prefs = PreferencesUtil.getPreferencesSync();
    prefs.deleteSync(key);
    prefs.flush(); // Required for permanent removal
  }

  /**
   * Delete key-value pair asynchronously
   * @param key Storage key
   */
  static async delete(key: string) {
    const prefs = await PreferencesUtil.getPreferences();
    await prefs.delete(key);
    await prefs.flush(); // Required for permanent removal
  }

  /**
   * Clear all data synchronously
   */
  static clearSync() {
    const prefs = PreferencesUtil.getPreferencesSync();
    prefs.clearSync();
    prefs.flush(); // Required for permanent removal
  }

  /**
   * Clear all data asynchronously
   */
  static async clear() {
    const prefs = await PreferencesUtil.getPreferences();
    await prefs.clear();
    await prefs.flush(); // Required for permanent removal
  }
}
```

## Usage Examples

### 1. Storing Data

```
// Synchronous storage
PreferencesUtil.putSync("username", "john_doe");
PreferencesUtil.putSync("dark_mode_enabled", true);
PreferencesUtil.putSync("user_score", 95);

// Asynchronous storage
await PreferencesUtil.put("notification_prefs", JSON.stringify({
  email: true,
  push: false,
  sms: true
}));
```

### 2. Retrieving Data

```
// Synchronous retrieval
const username = PreferencesUtil.getStringSync("username");
const isDarkMode = PreferencesUtil.getSync("dark_mode_enabled", false);
const score = PreferencesUtil.getSync("user_score", 0);

// Asynchronous retrieval
const notificationPrefs = await PreferencesUtil.getString("notification_prefs");
const parsedPrefs = JSON.parse(notificationPrefs || "{}");
```

### 3. Advanced Operations

```
// Check if key exists
if (PreferencesUtil.hasSync("user_token")) {
  const token = PreferencesUtil.getStringSync("user_token");
}

// Delete specific key
PreferencesUtil.deleteSync("temporary_data");

// Clear all preferences
PreferencesUtil.clearSync();

// Get all stored values
const allData = PreferencesUtil.getAllSync();
console.log("All stored preferences:", allData);
```

### Key Features:

1. **Dual Access Modes**: Synchronous and asynchronous APIs
2. **Type Safety**: Strongly typed value handling
3. **Persistence Guarantee**: Automatic flushing after write operations
4. **Singleton Pattern**: Single Preferences instance management
5. **Comprehensive API**: Full CRUD operations + existence checking
6. **Memory Efficiency**: Lazy initialization of Preferences instance

### Best Practices:

1. **Use Asynchronous Methods** for non-critical operations to avoid blocking UI
2. **Batch Operations** when possible to minimize disk I/O
3. **Serialize Complex Objects** using JSON for storage
4. **Handle Default Values** gracefully for missing keys
5. **Limit Data Size** to under 1MB per Preferences instance
6. **Namespace Management** for different data categories:

```
// User preferences
PreferencesUtil.putSync("user:theme", "dark");

// App settings
PreferencesUtil.putSync("app:first_launch", false);
```
