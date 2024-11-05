# 鸿蒙 next 使用字体图标

## 1.注册字体

```JavaScript
import { font } from '@kit.ArkUI';

font.registerFont({
        familyName: 'Icomoon',
        familySrc: '/common/fonts/icomoon.ttf'
      })
```



## 2.封装字体图片组件

```JavaScript
export enum CustomIconType {
  ico_arrow_back = "\ue900", //返回图标 < 左返回
  ico_arrow_choosedown = "\ue901", //图标实心下三角
  ico_arrow_chooseup = "\ue902", //图标实心上三角
  ico_arrow_down = "\ue903", //返回图标 > 箭头符号向下
  ico_arrow_more = "\ue904", //返回图标 > 右返回  查看更多
  ico_arrow_up = "\ue905", //返回图标 > 箭头符号向上
  ico_choose_on = "\ue906", //选中 勾选
  ico_close = "\ue907", //学习页面 x 图标 ，删除,
  ico_correct = "\ue908", //纠错

  ico_listarrow_down = "\ue90a", //知识点练习下展开
  ico_listarrow_up = "\ue90b", //知识点练习上收起
  ico_listmore = "\ue90c", // 三个横向小圆点的更多数据图标 。。。
  ico_lock = "\ue90d", //锁
  ico_mode_bright = "\ue90e", // 日间模式图标，小太阳
  ico_mode_night = "\ue90f", // 夜间模式图标，小月亮

  ico_restart = "\ue910", //重新开始
  ico_screen = "\ue911", //筛选
  ico_switch = "\ue912", //首页和学习页面切换科目图片,
  ico_write = "\ue913", // 书写图标，铅笔
  ico_arrow_check = "\ue914", //选中 箭头勾选
  ico_selected = "\ue914", //选中 √勾选
  ico_video_play = "\ue915", //item播放图标
  icon_reload = "\ue916", //刷新图标
  ico_reload = "\ue916", // 圆形重新加载图标
  icon_notice = "\ue917", //通知图标
  ico_notice = "\ue917", // 广播小喇叭
  ico_aisearch = "\ue918", // ai小机器人
  ico_intelligence_search = "\ue918", //首页智能搜索图标
  ico_clock = "\ue919", // 时钟
  icon_clock = "\ue919", //时钟图标

  icon_search = "\ue91a", //搜索
  ico_search = "\ue91a", // 时钟
  ico_discribe = "\ue91b", // 带圆圈的问号
  icon_discribe = "\ue91b", //疑问图标
  icon_location = "\ue91c", //定位图标
  icon_change = "\ue91d", //交换图标
  icon_filter = "\ue91e", //过滤图标
  icon_choose = "\ue91f", //空心圆
  icon_share = "\ue920", //分享图标
  icon_collect = "\ue921", //收藏图标
  icon_like = "\ue922", //点赞图标

  icon_off = "\ue923", //实心禁止通行
  icon_answer = "\ue924", //查看答案
  icon_mark_off = "\ue925", //标记-关闭
  icon_collect_off = "\ue926", //空心五角星-收藏
  icon_mark_on = "\ue927", //标记-开启
  icon_doubt = "\ue928", //圆圈-小i
  icon_points = "\ue929", // 文章-收藏

  icon_data = "\ue92a", //数据
  icon_advice = "\ue92b", // 文章-编写
  icon_next = "\ue92c", //文章-下一个
  icon_add = "\ue92d", //加号 +
  icon_wrong = "\ue92e", //圆圈-x
  icon_timer = "\ue92f", //半圆-时钟

  icon_aim = "\ue930", //瞄准
  icon_delete = "\ue931", //删除垃圾桶
  icon_setting = "\ue932", //设置
  icon_notes = "\ue933", //笔记
  icon_aimed = "\ue934", //瞄准选中
  icon_function = "\ue935", //功能
  icon_catalog = "\ue936", //数据菜单
  icon_text = "\ue937", //Aa
  icon_exit = "\ue938", //关机
  icon_teacher = "\ue939", //老师头像

  icon_nomore = "\ue93a", //空心禁止通行
  icon_nomore_1 = "\ue93b", //实心禁止通行2
  icon_mark = "\ue93c", //固定图钉
  icon_fullscreen = "\ue93d", //全屏
  icon_download = "\ue93e", //下载
  icon_director = "\ue93f", //向左箭头 ←

  icon_scan = "\ue940", //扫码
  icon_wrongnote = "\ue941", //错题
  icon_record = "\ue942", //历史记录


  icon_full_screen = "\ue93d",
  icon_video = "\ue943", //视频图标
  icon_clear = "\ue944", //清空做题进度记录
  icon_remind = "\ue945", //闹钟提醒
}

@Component
export struct CustomIcon {
  @Prop iconType: CustomIconType
  @Prop iconSize: number = 23
  @Prop iconWeight: FontWeight = FontWeight.Normal
  @Prop iconColor: ResourceColor = $r("app.color.blodTextColor")

  build() {
    Text(this.iconType)
      .fontSize(this.iconSize)
      .fontFamily('Icomoon')
      .fontWeight(this.iconWeight)
      .fontColor(this.iconColor)
  }
}
```



## 3.使用字体图标

```JavaScript
  CustomIcon({
          iconType: CustomIconType.icon_collect,
          iconSize: 23,
        })
```



