import { FileUtil } from '@ohos/hvigor'
import pythonBuild from "./pythonBuild.json"
import appBranchConfig from "./appBranchConfig.json"

// console.log("pythonBuild", pythonBuild);
// console.log("appBranchConfig",appBranchConfig);

export const hviConfig = {
  // APP_TYPE: "senioriup",
  APP_TYPE: pythonBuild.APP_TYPE,
  bundleId: pythonBuild.bundleId,
  oauthClientId: pythonBuild.oauthClientId,
  appId: pythonBuild.appId,
  certName: pythonBuild.certName,
  certPath: pythonBuild.certPath,
  keyAlias: pythonBuild.keyAlias,
  storeFile: pythonBuild.storeFile,
  appName: pythonBuild.appName,
  certProfile: pythonBuild.certProfile,
  yuan_service_template: pythonBuild.yuan_service_template,
}

// 主体配置
const mainCertObj = {
  lex: {
    desc: '勒克斯主体',
    certPath: './entry/hwcert/lex/lex.cer',
    keyAlias: 'lex',
    storeFile: './entry/hwcert/lex/lex.p12',
    yuan_service_template: 2
  },
  taxagent: {
    desc: '聚优主体',
    certPath: './entry/hwcert/taxagent/taxagent.cer',
    keyAlias: 'fireman',
    storeFile: './entry/hwcert/taxagent/taxagent.p12',
    yuan_service_template: 2
  },
  agentassist: {
    desc: '聚雄主体',
    certPath: './entry/hwcert/agentassist/agentassist.cer',
    keyAlias: 'agentassist',
    storeFile: './entry/hwcert/agentassist/agentassist.p12',
    yuan_service_template: 3
  },
  clearDirt: {
    desc: '清灰主体', // 又叫集合主体
    certPath: './entry/hwcert/clear/jihe.cer',
    keyAlias: 'hhuawei',
    storeFile: './entry/hwcert/clear/hhuawei.p12',
    yuan_service_template: 1
  },
  bojuCer: {
    desc: '长沙博聚主题',
    certpath: './entry/hwcert/boju/boju.cer',
    keyAlias: 'boju',
    storeFile: './entry/hwcert/boju/boju.p12',
    yuan_service_template: 3
  },
  yunshu2: {
    desc: '昀树主体',
    certPath: './entry/hwcert/yunshu2/昀树发布证书.cer',
    keyAlias: 'yunshu',
    storeFile: './entry/hwcert/yunshu2/yunshu.p12',
    yuan_service_template: 1
  },
  mangguo: {
    desc: '芒果主体',
    certPath: './entry/hwcert/yunshu2/芒果发布证书.cer',
    keyAlias: 'mangguo',
    storeFile: './entry/hwcert/mangguo/mangguo.p12',
    yuan_service_template: 1
  }
}

// 获取对应appType的主体配置
export const getMainCertProp = (prop, buildMode) => {
  if (hviConfig[prop] != undefined) {
    return hviConfig[prop];
  } else {
    const mainCert = appBranchConfig[hviConfig.APP_TYPE]['mainCert'];
    return mainCertObj[mainCert][prop];
  }

}

export const getApptypeProp = (prop, buildMode) => {
  if (hviConfig[prop] != undefined) {
    return hviConfig[prop];
  } else {
    const propValue = appBranchConfig[hviConfig.APP_TYPE][prop] || "";
    return propValue;
  }

}

// 获取对应appType的路由文件配置
export const getProfilePages = () => {
  const profilePages = appBranchConfig[hviConfig.APP_TYPE]['profilePages'] || 'main_pages';
  return '$profile:' + profilePages;
}

export function readJson(path) {
  const jsonStr = FileUtil.readFileSync(path)
  const jsonData = JSON.parse(jsonStr);
  return jsonData;
}

export function writeJson(path, jsonData) {
  const jsonStr = JSON.stringify(jsonData, null, 2);
  console.log('writeJson', path, jsonStr);
  FileUtil.writeFileSync(path, jsonStr);
}

//  判断文件是否存在
export function isExistFile(filePath) {
  return FileUtil.exist(filePath);
}