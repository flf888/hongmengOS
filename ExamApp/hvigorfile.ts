import { appTasks, OhosAppContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin'
import { hvigor, getNode, FileUtil } from '@ohos/hvigor'
import {
  hviConfig,
  getMainCertProp,
  getApptypeProp,
  readJson,
  writeJson,
  isExistFile
} from "./hviUtils"


const APP_TYPE = hviConfig.APP_TYPE;

// let APP_TYPE = 'senioriup';


// 根据apptype动态修改build-profile.json5
function replaceProfileJson5() {

  const rootNode = getNode(__filename);
  rootNode.afterNodeEvaluate(node => {
    const appContext = node.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
    const buildProfileOpt = appContext.getBuildProfileOpt();
    const buildMode = appContext.getBuildMode();
    const appJsonOpt = appContext.getAppJsonOpt();

    const setBundleName = (setName) => {
      if (setName) {
        appJsonOpt['app']['bundleName'] = setName;
      } else {

        appJsonOpt['app']['bundleName'] = `com.atomicservice.${getApptypeProp('bundleId', buildMode)}`;
      }

      appContext.setAppJsonOpt(appJsonOpt);
    }

    // console.log("buildMode", buildMode)
    // 只有打正式包的时候才执行替换
    if (buildMode == "release") {

      buildProfileOpt['app']['signingConfigs'] = [
        {
          "name": "default",
          "type": "HarmonyOS",
          "material": {
            "certpath": getMainCertProp('certPath', buildMode),
            "storePassword": "00000019A463BD3D8A31AA82532327FA246C9812B796A91347061967CD224CE8E3AB30DC44710F74C8",
            "keyAlias": getMainCertProp('keyAlias', buildMode),
            "keyPassword": "0000001949783A95F45ED64D26E49C1B35C53D6A7656C16B035FF1279AFA1DB3A394301D1B5AD9EEF5",
            "profile": getApptypeProp('certProfile', buildMode),
            "signAlg": "SHA256withECDSA",
            "storeFile": getMainCertProp('storeFile', buildMode)
          }
        }
      ];

      buildProfileOpt['app']['products'] = [
        {
          "name": "default",
          "signingConfig": "default",
          "compatibleSdkVersion": "5.0.0(12)",
          "runtimeOS": "HarmonyOS",
          "output": {
            "artifactName": APP_TYPE  // 打包文件名称
          }
        }
      ]

      appContext.setBuildProfileOpt(buildProfileOpt);

      setBundleName()
    } else if (buildMode == "debug") {

      const appName = getApptypeProp('appName', buildMode);
      // const appName = '高职单招考试聚题库';
      let curAppP7b = `./entry/hwcert/debug/${appName}-调试证书.p7b`;

      const setBuildProfile = () => {
        buildProfileOpt['app']['signingConfigs'][0] =
          {
            "name": "default",
            "type": "HarmonyOS",
            "material": {
              "certpath": "./entry/hwcert/debug/debug.cer",
              "storePassword": "00000019C625FC192474743429CBB35A3643F009B1891FFBCFB3BCD0A7067C572FFD93F8E86D1C4D28",
              "keyAlias": "debug",
              "keyPassword": "0000001942A46D42E221169A40F6C630E56ACA79FF89CA14D9EC4C11824B277CA186510822C31C1283",
              "profile": curAppP7b,
              "signAlg": "SHA256withECDSA",
              "storeFile": "./entry/hwcert/debug/debug.p12"
            }
          }
        appContext.setBuildProfileOpt(buildProfileOpt);
      }

      if (!isExistFile(curAppP7b)) {
        console.log("文件不存在,则使用默认的配置")
        curAppP7b = "./entry/hwcert/debug/高职单招考试聚题库-调试证书.p7b";
        setBuildProfile()
        setBundleName("com.atomicservice.5765880207855211755")
      } else {
        console.log("文件存在，更改配置")
        setBuildProfile()
        setBundleName()
      }

    }


  })
}


function preAppTypeConfig(params) {
  const rootNode = getNode(__filename);

  rootNode.afterNodeEvaluate(node => {
    const appContext = node.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
    const buildMode = appContext.getBuildMode();


    // 打包或运行前更新代码中的apptype与appName
    const apptypePath = "./entry/src/main/ets/http/appType.json";
    const apptypeJson = readJson(apptypePath)
    console.log("APP_TYPE", APP_TYPE)
    apptypeJson.appType = APP_TYPE;
    apptypeJson.appName = getApptypeProp('appName', buildMode);
    apptypeJson.bundleId =  getApptypeProp('bundleId', buildMode);
    apptypeJson.buildMode = buildMode;
    apptypeJson.appId = getApptypeProp('appId', buildMode) || "";
    apptypeJson.yuan_service_template = getMainCertProp('yuan_service_template', buildMode);
    writeJson(apptypePath, apptypeJson);

    if (buildMode == "debug") {
      let logo_y_path = `./vest/${APP_TYPE}/img/logo_y.png`;
      if (isExistFile(logo_y_path)) {
        FileUtil.copyFileSync(logo_y_path, './AppScope/resources/base/media/app_icon.png');
      }
    }

    // 替换 AppScope下的 string.json第一个数组项
    const scopeStringPath = "./AppScope/resources/base/element/string.json";
    const scopeStringJson = readJson(scopeStringPath)
    scopeStringJson['string'][0] = {
      "name": "app_name",
      "value": getApptypeProp('appName', buildMode)
    }
    writeJson(scopeStringPath, scopeStringJson);
  })

}


preAppTypeConfig()
replaceProfileJson5()


export default {
  system: appTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []         /* Custom plugin to extend the functionality of Hvigor. */
}