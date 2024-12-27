import { hapTasks, OhosHapContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { getNode } from '@ohos/hvigor'
import { hviConfig, getApptypeProp} from "../hviUtils"
import appTypeJson from "./src/main/ets/http/appType.json"


const APP_TYPE = hviConfig.APP_TYPE;

// 根据apptype动态修改module.json5
function reaplceModule() {
  const entryNode = getNode(__filename);
  entryNode.afterNodeEvaluate(node => {
    const hapContext = node.getContext(OhosPluginId.OHOS_HAP_PLUGIN) as OhosHapContext;
    const moduleJsonOpt = hapContext.getModuleJsonOpt();


    const buildMode = appTypeJson.buildMode;
    console.log('reaplceModule buildMode', buildMode);


    if (!getApptypeProp('oauthClientId', buildMode)) {
      throw new Error("未设置oauthClientId，请在线上后台的打包管理-华为推送-鸿蒙应用-Client ID字段拿该字段");
      return;
    }

    // client_id
    moduleJsonOpt['module']['metadata'][0].value = getApptypeProp('oauthClientId', buildMode);

    hapContext.setModuleJsonOpt(moduleJsonOpt);
  })
}

reaplceModule()


export default {
  system: hapTasks, /* Built-in plugin of Hvigor. It cannot be modified. */
  plugins: []         /* Custom plugin to extend the functionality of Hvigor. */
}