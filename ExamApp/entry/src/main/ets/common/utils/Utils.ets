import Config from '../../http/Config';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@ohos.base';
import router from '@ohos.router';
import { pasteboard } from '@kit.BasicServicesKit';

export interface ProctolObjType {
  proctol: string,
  pathName: string,
  params: Record<string, Object>,
  originUrl: string // 原始地址
}

export default class Utils {
  /**
   * 获取lpx单位数值
   * @param number
   * @returns
   */
  static getVp(number: number) {
    // return number + "lpx";
    return (number / 2) + "vp";
  }

  /**
   * 获取图片路径 默认tag是base
   * @param name
   * @param tag
   * @returns
   */
  static getImgPath(name: string, tag: string = 'base') {
    return '/common/images/' + name;
  }

  static strIsNull(str: string) {
    if (str == '' || str == undefined || str == null || str.length == 0 || str == 'null') {
      return true;
    }
    return false;
  }

  static getUrlPathValue(url: string) {
    if (url == undefined || url == '' || url == null) {
      return "";
    }
    if (!url.includes("?")) {
      return url;
    }
    return url.split("?")[0];
  }

  static getUrlKeyValue(url: string): Record<string, string | number | boolean> {
    const temp1 = url.split('?');
    const pram = temp1[1];
    const keyValue = pram.split('&');
    const obj: Record<string, string | number | boolean> = {};

    for (let i = 0; i < keyValue.length; i++) {
      if (keyValue[i].includes('=')) {
        const item = keyValue[i].split('=');
        const key = item[0];
        const value = item[1];
        obj[key] = value;
      }
    }
    return obj;
  }

  static formatTime(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    const formattedHours = hours > 0 ? `${hours}时` : '';
    const formattedMinutes = minutes > 0 ? `${minutes}分` : '';
    const formattedSeconds = remainingSeconds > 0 ? `${remainingSeconds}秒` : '';

    return formattedHours + formattedMinutes + formattedSeconds;
  }

  static formatTimeNormal(seconds: number): string {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const remainingSeconds = seconds % 60;

    const formattedHours = hours > 0 ? `${hours}:` : '00:';
    const formattedMinutes = minutes > 0 ? `${minutes}:` : '00:';
    const formattedSeconds = remainingSeconds > 0 ? `${remainingSeconds}` : '00';

    return formattedHours + formattedMinutes + formattedSeconds;
  }

  // 秒转成分秒  例如:30分25秒
  static formatTime2MS(seconds: number): string {

    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;

    const formattedMinutes = minutes > 0 ? `${minutes}分` : '';
    const formattedSeconds = remainingSeconds > 0 ? `${remainingSeconds}秒` : '';

    return formattedMinutes + formattedSeconds;
  }

  // 秒转时分
  static formatSeconds(time: number): string {
    let min = time;
    let val = Utils.formatBit(Math.floor(min / 60)) + ':' + Utils.formatBit(time % 60);
    return val;
  }

  // 补0
  static formatBit(val: number): string {
    val = val;
    return val > 9 ? val.toString() : '0' + val;
  }

  static getCurCommitTime() {
    // 创建一个新的 Date 对象
    let currentDate = new Date();

    // 获取年份
    let year = currentDate.getFullYear();

    // 获取月份（注意：月份是从 0 开始计数的，所以需要加 1）
    let month = currentDate.getMonth() + 1;

    // 获取日期
    let day = currentDate.getDate();

    // 获取小时
    let hours = currentDate.getHours();

    // 获取分钟
    let minutes = currentDate.getMinutes();

    // 获取秒
    let seconds = currentDate.getSeconds();

    // 格式化时间为字符串
    let formattedTime =
      `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')} ${hours.toString()
        .padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

    console.log(formattedTime);

    return formattedTime;

  }

  static getRightPercent(right_num: number, total: number) {
    // 计算正确率
    let right_percent = (right_num / total) * 100;

    // 格式化正确率为百分比形式，保留两位小数
    let formatted_right_percent = right_percent.toFixed(2) + '%';

    // 输出或使用 formatted_right_percent
    // console.log(formatted_right_percent);
    return formatted_right_percent;
  }

  //去掉富文本图片宽高
  static htmlImgParse(htmlTxt: string, autoImgWidth: boolean = true): string {
    // 替换图片高度
    const regExp = /height=".*?"/g;
    htmlTxt = htmlTxt.replace(regExp, '');

    if (!autoImgWidth) {
      return htmlTxt;
    }
    return htmlTxt.replace(/<img /g, '<img style="max-width:100%;height:auto;display:block" ');
  }


  // 跳转app
  static jumpApp(thisScore: Object) {
    let context: common.UIAbilityContext = getContext(thisScore) as common.UIAbilityContext;
    let want: Want = {
      uri: `store://appgallery.huawei.com/app/detail?id=C${Config.appId}`
    };

    try {
      context.startAbility(want).then(() => {
        console.log('调试唤起成功')
      }).catch((err: BusinessError) => {
        console.log('调试唤起失败', err.code, err.message)
      })
    } catch (paramError) {
      console.log('调试唤起失败', paramError.code, paramError.message)
    }
  }

  // 判断两个数组是否有相交元素
  static arraysIntersect(arr1: string[], arr2: string[]) {
    return arr1.some(element => arr2.includes(element));
  }

  // 复制文本到剪贴板
  static copyTextToClipboard(text: string) {
    const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
    const systemPasteboard = pasteboard.getSystemPasteboard();
    systemPasteboard.setData(pasteboardData); // 将数据放入剪切板
    return systemPasteboard.getData();
  }

  // 回退页面，没有上一页就回首页
  static routeBack() {
    let page = router.getState();
    // console.log('调试current index = ' + page.index);
    if (page.index > 1) {
      router.back();
    } else {
      router.replaceUrl({
        url: 'pages/InitDataPage'
      })
    }
  }

  // 将对象转换成url
  static paramsToUrl(data: Record<string, Object> = {}, isPrefix = true) {
    if (Object.keys(data).length == 0) {
      // 如果是空对象直接返回空字符
      return '';
    }
    let prefix = isPrefix ? '?' : '';
    let paramArray: string[] = [];
    Object.keys(data).forEach(key => {
      let value = data[key];
      // 去掉为空的参数
      if (['', undefined, null].indexOf(value as string) >= 0) {
        return;
      }
      paramArray.push(key + '=' + value);
    })

    return paramArray.length ? prefix + paramArray.join('&') : '';
  }

  // 获取url ? 后面的参数转换成对象
  static urlToParams(url: string) {
    let paramsObj: Record<string, Object> = {};
    if (!url) {
      return paramsObj;
    }
    let pStrsArr = url.split('?');
    if (pStrsArr.length === 2) {
      let pStrs = pStrsArr[1];
      let arr = pStrs.split('&');
      if (arr.length > 0) {
        arr.forEach(item => {
          let arr = item.split('=');
          paramsObj[arr[0]] = arr[1];
        });
        return paramsObj;
      }
    }
    return paramsObj;
  }

  // 解析完整的协议地址
  static parseProtoclUrl(url: string) {
    let proctolObj: ProctolObjType = {
      proctol: '',
      pathName: '',
      params: Utils.urlToParams(url),
      originUrl: url
    };

    let pStrsArr = url.split('?');

    let pstr = pStrsArr[0];
    let cstrArr = pstr.split('//');
    if (cstrArr.length == 2) {
      // 类似于 http://www.baidu.com
      proctolObj.proctol = cstrArr[0];
      proctolObj.pathName = cstrArr[1];
    } else if (cstrArr.length == 1) {
      // 类似于 /pages/test/dev
      proctolObj.pathName = cstrArr[0];
    }
    return proctolObj;
  }

  /**
   * 深度拷贝对象(对于undefined等无法序列化的数据会丢失,这个后期优化，也可先使用三方库lodash的_.cloneDeep方法。)
   * @param obj 被拷贝对象
   * @returns
   */
  static deepClone(obj: Object): ESObject {
    return JSON.parse(JSON.stringify(obj));
  }

  // 获取uri尾部的文件类型, 如 internal://cache/test.jpg 获取文件类型 jpg
  static getUriFileType(uri: string) {
    if (!uri) {
      return '';
    }
    const parts = uri.split('/');
    const fileName = parts.pop() || '';
    const fileExtensionParts = fileName.split('.');
    return fileExtensionParts.length > 1 ? fileExtensionParts.pop() || '' : '';
  }

  // 获取uri尾部的文件名, 如 internal://cache/test.jpg 获取文件名 test.jpg
  static getUriFileName(uri: string) {
    if (!uri) {
      return '';
    }
    const parts = uri.split('/');
    return parts.pop() || '';
  }
}