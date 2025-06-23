# Implementing UI Updates for Object Arrays in HarmonyOS Next

The `@Provide` and `@Consume` decorators only support single-level data observation. For object array scenarios, we must use `@Observed` and `@ObjectLink` decorators as documented in the official HarmonyOS guide:
[Observed and ObjectLink Decorators](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/arkts-observed-and-objectlink-V5)

## 1. Create @Observed Classes

Define observable classes for nested data structures:

```
interface ExplanItemType {
  type_name: string
  type?: string
  my_log?: MyLogItem
  list: ExamItem[]
}

@Observed
export class ExplanItem {
  type_name: string
  type?: string
  my_log?: MyLogItem
  list: ExamItem[]

  constructor(obj: ExplanItemType) {
    this.type_name = obj.type_name;
    this.type = obj.type;
    this.my_log = obj.my_log;
    this.list = obj.list;
  }
}

interface MyLogItemType {
  id: number
  user_answer: string
  is_right: string
  q_user_paper_id: number
  time: string
  is_flag: string
  is_collect?: boolean
}

@Observed
export class MyLogItem {
  id: number
  user_answer: string
  is_right: string
  q_user_paper_id: number
  time: string
  is_flag: string
  is_collect?: boolean

  constructor(obj: MyLogItemType) {
    this.id = obj.id;
    this.user_answer = obj.user_answer;
    this.is_right = obj.is_right;
    this.q_user_paper_id = obj.q_user_paper_id;
    this.time = obj.time;
    this.is_flag = obj.is_right;
    this.is_collect = obj.is_collect;
  }
}

interface OptionItemType {
  key: string
  value: string
  name: string
  select: string
}

@Observed
export class OptionItem {
  key: string
  value: string
  name: string
  select: string

  constructor(obj: OptionItemType) {
    this.key = obj.key;
    this.value = obj.value;
    this.name = obj.name;
    this.select = obj.select;
  }
}

// Full ExamItem implementation remains the same as original
// with all properties and nested @Observed classes
```

## 2. Convert API Data to Class Instances

Transform API responses into observable objects:

```
_parseExamList(list: ESObject[]) {
  const objList: ExamItem[] = [];
  let mainNumber = 0;
  
  for (let i = 0; i < list.length; i++) {
    const objItem = new ExamItem(list[i]);
    objItem.main_number = mainNumber++;
    objList.push(objItem);
  }
  
  return objList;
}
```

## 3. Use @ObjectLink in Child Components

Enable reactive updates in non-@Entry components:

```
@Component
struct BottomTool {
  @ObjectLink examItem: ExamItem;       // Observable exam item
  @ObjectLink myLogItem: MyLogItem;     // Observable log item
  @State isParse: boolean = false;      // Local state
  openExamBottomDialog?: () => void     // Callback function

  build() {
    Flex({ direction: FlexDirection.Row }) {
      // Favorite button
      Row() {
        Image(Utils.getImgPath(
          this.myLogItem.is_collect ? '033collect.png' : '038collect_off.png', 
          "iconfont"
        ))
        .size(46)
      }
      .onClick(() => {
        if (this.myLogItem.is_collect) {
          // Unfavorite logic
          ExamApi.delFavorite({ question_uni_key: this.examItem.uni_key })
            .then(() => {
              this.myLogItem.is_collect = false; // Direct property update
              ToastUtils.showToast("Unfavorited successfully");
            });
        } else {
          // Favorite logic
          ExamApi.addFavorite({ question_uni_key: this.examItem.uni_key })
            .then(() => {
              this.myLogItem.is_collect = true; // Direct property update
              ToastUtils.showToast("Added to favorites");
            });
        }
      })
      
      // Flag button
      if (!this.isParse) {
        Row() {
          Image(Utils.getImgPath(
            this.myLogItem.is_flag == '1' ? '039mark_on.png' : '037mark_off.png',
            "iconfont"
          ))
          .size(46)
        }
        .onClick(() => {
          // Toggle flag state
          this.myLogItem.is_flag = this.myLogItem.is_flag == '1' ? '0' : '1';
        })
      }
      
      // Answer button
      Row() {
        Image(Utils.getImgPath('036answer.png', "iconfont"))
          .size(46)
      }
      .onClick(() => {
        this.openExamBottomDialog?.();
      })
    }
    .width('100%')
    .height(96)
  }
}
```

### Key Implementation Points:

1. **Deep Observation**:
   - `@Observed` classes enable nested property tracking
   - All related classes must be decorated
2. **Data Transformation**:
   - API responses must be converted to class instances
   - Ensures all nested objects become observable
3. **Direct Property Updates**:
   - Child components modify properties directly via `@ObjectLink`
   - Changes propagate automatically to parent components
   - No need for manual array splicing or state resetting
4. **Performance Optimization**:
   - Only affected components re-render
   - Minimal overhead for complex data structures

This pattern provides efficient, granular updates for complex nested data scenarios in HarmonyOS applications.
