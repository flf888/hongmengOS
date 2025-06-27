# Implementing Pull-to-Refresh and Load-More in OpenHarmony

Pull-to-refresh and load-more functionality are among the most commonly used features in app development. This article demonstrates how to implement these basic functionalities using PullToRefresh.

**Introduction**

PullToRefresh is a component available in the OpenHarmony environment that supports both pull-to-refresh and load-more functionalities. It allows configuring various properties for built-in animations, supports custom animations, and can use lazyForEach data as a data source.

**Installation**

```
ohpm install @ohos/pulltorefresh
```

**Quick Start**

```
// Usage with V1 decorator
import { PullToRefresh } from '@ohos/pulltorefresh'

// Must bind to a list or grid component
private scroller: Scroller = new Scroller();
  
PullToRefresh({
  // Required: Data bound to the list component
  data: $data,
  // Required: List or grid component to bind within the main layout
  scroller: this.scroller,
  // Required: Custom main layout containing the list/grid component
  customList: () => {
    // A UI method decorated with @Builder
    this.getListView();
  },
  // Optional: Pull-to-refresh callback
  onRefresh: () => {
    return new Promise<string>((resolve, reject) => {
      // Simulate network request: After 2 seconds, update data
      setTimeout(() => {
        resolve('Refresh successful');
        this.data = [...this.dataNumbers];
      }, 2000);
    });
  },
  // Optional: Load-more callback
  onLoadMore: () => {
    return new Promise<string>((resolve, reject) => {
      // Simulate network request: After 2 seconds, append data
      setTimeout(() => {
        resolve('');
        this.data.push("New item " + this.data.length);
      }, 2000);
    });
  },
  customLoad: null,
  customRefresh: null,
})

// Usage with V2 decorator
import { PullToRefreshV2 } from '@ohos/pulltorefresh'

// Must bind to a list or grid component
private scroller: Scroller = new Scroller();

PullToRefreshV2({
  // Optional: Data bound to the list component
  data: this.data,
  // Required: List/grid component to bind
  scroller: this.scroller,
  // Required: Custom main layout
  customList: () => {
    this.getListView();
  },
  // Optional: Pull-to-refresh callback
  onRefresh: () => {
    return new Promise<string>((resolve, reject) => {
      setTimeout(() => {
        resolve('Refresh successful');
        this.data = [...this.dataNumbers];
      }, 2000);
    });
  },
  // Optional: Load-more callback
  onLoadMore: () => {
    return new Promise<string>((resolve, reject) => {
      setTimeout(() => {
        resolve('');
        this.data.push("New item " + this.data.length);
      }, 2000);
    });
  },
  customLoad: null,
  customRefresh: null,
})
```

**Usage Limitations**

1. Currently only supports List, Scroll, Tabs, Grid, and WaterFlow system container components
2. Does not support setting spring effects or shadow effects for system container components (must set edgeEffect property to EdgeEffect.None)
3. Does not support automatically triggering load-more when reaching the bottom of the page
4. Does not support triggering load-more when page data doesn't fill one screen
5. Does not support programmatically triggering pull-to-refresh
6. Does not provide gesture-end callback when pull-to-refresh animation completes

**Support for lazyForEach Data Sources**

LazyForEach iterates through data sources on-demand and creates corresponding components during each iteration. When used in scrollable containers, the framework creates components on-demand based on the visible area and destroys them when they leave the viewport to reduce memory usage.

Interface description:

```
LazyForEach(
  dataSource: IDataSource,             // Data source to iterate
  itemGenerator: (item: any, index?: number) => void,  // Component generator function
  keyGenerator?: (item: any, index?: number) => string // Key generator function
): void
```

**IDataSource Type Definition**

```
interface IDataSource {
  totalCount(): number;                 // Get total data count
  getData(index: number): Object;        // Get data at specified index
  registerDataChangeListener(listener: DataChangeListener): void;  // Register data change listener
  unregisterDataChangeListener(listener: DataChangeListener): void; // Unregister data change listener
}
```

**DataChangeListener Type Definition**

```
interface DataChangeListener {
  onDataReloaded(): void;               // Called when data reloads
  onDataAdded(index: number): void;      // Called when data is added
  onDataMoved(from: number, to: number): void;  // Called when data moves between positions
  onDataDeleted(index: number): void;    // Called when data is deleted
  onDataChanged(index: number): void;    // Called when data changes
  onDataAdd(index: number): void;        // Called when data is added (alias)
  onDataMove(from: number, to: number): void;  // Called when data moves (alias)
  onDataDelete(index: number): void;     // Called when data is deleted (alias)
  onDataChange(index: number): void;     // Called when data changes (alias)
}
```

**Constraints**

Verified in the following versions:

- `DevEco Studio: NEXT Beta1-5.0.3.806`
- `SDK: API12 Release(5.0.0.66)`