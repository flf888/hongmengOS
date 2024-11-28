

# 鸿蒙 next 封装轻量级缓存工具PreferencesUtil



```JavaScript
import preferences from '@ohos.data.preferences';
import dataPreferences from '@ohos.data.preferences';
import { AppUtil } from './AppUtil';


type PreferencesValue = string

/**
 * preferences 轻量级缓存工具
 */
export class PreferencesUtil {
  private constructor() {
  }

  private static defaultPreferenceName: string = "myPreferences";
  private static preferences: preferences.Preferences;

  /**
   * 获取Preferences实例
   * @param name
   * @returns
   */
  private static getPreferencesSync(): preferences.Preferences {
    if (!PreferencesUtil.preferences) {
      PreferencesUtil.preferences =
        dataPreferences.getPreferencesSync(AppUtil.getContext(), { name: PreferencesUtil.defaultPreferenceName });
    }
    return PreferencesUtil.preferences;
  }

  /**
   * 获取Preferences实例
   * @param name
   * @returns
   */
  private static async getPreferences(): Promise<preferences.Preferences> {
    if (!PreferencesUtil.preferences) {
      PreferencesUtil.preferences =
        await dataPreferences.getPreferences(AppUtil.getContext(), PreferencesUtil.defaultPreferenceName);
    }
    return PreferencesUtil.preferences;
  }


  /**
   * 将数据缓存
   * @param key
   * @param value
   */
  static putSync(key: string, value: PreferencesValue) {
    let preferences = PreferencesUtil.getPreferencesSync(); //获取实例
    preferences.putSync(key, value);
    preferences.flush(); //此处一定要flush，要不然不能永久序列化到本地
  }

  /**
   * 将数据缓存
   * @param key
   * @param value
   */
  static async put(key: string, value: PreferencesValue) {
    let preferences = await PreferencesUtil.getPreferences(); //获取实例
    await preferences.put(key, value);
    await preferences.flush(); //此处一定要flush，要不然不能永久序列化到本地
  }


  /**
   * 获取缓存值
   * @param key
   * @param defValue
   * @returns
   */
  static getSync(key: string, defValue: PreferencesValue): PreferencesValue {
    let preferences = PreferencesUtil.getPreferencesSync(); //获取实例
    return preferences.getSync(key, defValue) as PreferencesValue;
  }

  /**
   * 获取缓存值
   * @param key
   * @param defValue
   * @returns
   */
  static async get(key: string, defValue: PreferencesValue): Promise<PreferencesValue> {
    let preferences = await PreferencesUtil.getPreferences(); //获取实例
    return preferences.get(key, defValue) as Promise<PreferencesValue>;
  }

  static getAllSync() {
    let preferences = PreferencesUtil.getPreferencesSync(); //获取实例
    return preferences.getAllSync();
  }


  /**
   * 获取string类型的缓存值
   * @param key
   * @returns
   */
  static getStringSync(key: string): string {
    return PreferencesUtil.getSync(key, "") as string;
  }

  /**
   * 获取string类型的缓存值
   * @param key
   * @returns
   */
  static async getString(key: string): Promise<string> {
    return (await PreferencesUtil.get(key, "")) as string;
  }


  /**
   * 检查缓存的Preferences实例中是否包含名为给定Key的存储键值对
   * @param key
   * @returns
   */
  static hasSync(key: string) {
    return PreferencesUtil.getPreferencesSync().hasSync(key);
  }

  /**
   * 检查缓存的Preferences实例中是否包含名为给定Key的存储键值对
   * @param key
   * @returns
   */
  static async has(key: string) {
    let preferences = await PreferencesUtil.getPreferences(); //获取实例
    return await preferences.has(key);
  }


  /**
   * 删除缓存值
   * @param key
   * @returns
   */
  static deleteSync(key: string) {
    let preferences = PreferencesUtil.getPreferencesSync(); //获取实例
    preferences.deleteSync(key);
    preferences.flush() //此处一定要flush，要不然不能永久序列化到本地
  }

  /**
   * 删除缓存值
   * @param key
   * @returns
   */
  static async delete(key: string) {
    let preferences = await PreferencesUtil.getPreferences(); //获取实例
    await preferences.delete(key);
    return await preferences.flush() //此处一定要flush，要不然不能永久序列化到本地
  }


  /**
   * 清空缓存的Preferences实例中的所有数据
   * @returns
   */
  static clearSync() {
    let preferences = PreferencesUtil.getPreferencesSync(); //获取实例
    preferences.clearSync();
    preferences.flush() //此处一定要flush，要不然不能永久序列化到本地
  }

  /**
   * 清除缓存的Preferences实例中的所有数据
   * @returns
   */
  static async clear() {
    let preferences = await PreferencesUtil.getPreferences(); //获取实例
    await preferences.clear();
    return await preferences.flush() //此处一定要flush，要不然不能永久序列化到本地
  }
}

// export default new PreferencesUtil();
```



## 用法

### 1.存储数据

```JavaScript

PreferencesUtil.putSync("mykey", "myvalue")
```



### 2.获取数据

```JavaScript

PreferencesUtil.getStringSync("mykey")
```



### 



