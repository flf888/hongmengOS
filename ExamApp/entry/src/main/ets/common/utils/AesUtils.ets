import cryptoFramework from '@ohos.security.cryptoFramework';
import util from '@ohos.util';

export default class AesUtils{
  private static key: string = "meitejuheng66666";
  // 把密钥、明文等转换成输入数据需要的格式
  static stringToUint8Array(str: string, len?: number): Uint8Array {
    let arr = new Uint8Array(len || str.length);
    for (let i = 0; i < arr.length; i++) {
      arr[i] = i < str.length ? str.charCodeAt(i) : 0;
    }
    return arr;
  }

  // 解密内容转换成字符串 用于将字节数组解码为字符串
  static uint8ArrayToString(uint8Array: Uint8Array): string {
    let str = '';
    let i = 0;

    while (i < uint8Array.length) {
      let byte = uint8Array[i];

      if (byte < 128) {
        // ASCII码范围（0 - 127），直接转换为字符
        str += String.fromCharCode(byte);
        i++;
      } else if ((byte & 0xE0) === 0xC0) {
        // 2字节UTF-8字符
        let nextByte = uint8Array[i + 1];
        if (nextByte && ((nextByte & 0xC0) === 0x80)) {
          // 确保第二个字节符合UTF-8规则
          let charCode = ((byte & 0x1F) << 6) | (nextByte & 0x3F);
          str += String.fromCharCode(charCode);
          i += 2;
        } else {
          // 字节序列不符合规则，处理错误情况（这里简单跳过）
          i++;
        }
      } else if ((byte & 0xF0) === 0xE0) {
        // 3字节UTF-8字符
        let nextByte1 = uint8Array[i + 1];
        let nextByte2 = uint8Array[i + 2];
        if (nextByte1 && ((nextByte1 & 0xC0) === 0x80) && nextByte2 && ((nextByte2 & 0xC0) === 0x80)) {
          // 确保后续两个字节符合UTF-8规则
          let charCode = ((byte & 0x0F) << 12) | ((nextByte1 & 0x3F) << 6) | (nextByte2 & 0x3F);
          str += String.fromCharCode(charCode);
          i += 3;
        } else {
          // 字节序列不符合规则，处理错误情况（这里简单跳过）
          i++;
        }
      } else if ((byte & 0xF8) === 0xF0) {
        // 4字节UTF-8字符
        let nextByte1 = uint8Array[i + 1];
        let nextByte2 = uint8Array[i + 2];
        let nextByte3 = uint8Array[i + 2];
        if (nextByte1 && ((nextByte1 & 0xC0) === 0x80) && nextByte2 && ((nextByte2 & 0xC0) === 0x80) && nextByte3 && ((nextByte3 & 0xC0) === 0x80)) {
          // 确保后续三个字节符合UTF-8规则
          let charCode = ((byte & 0x07) << 18) | ((nextByte1 & 0x3F) << 12) | ((nextByte2 & 0x3F) << 6) | (nextByte3 & 0x3F);
          str += String.fromCharCode(charCode);
          i += 4;
        } else {
          // 字节序列不符合规则，处理错误情况（这里简单跳过）
          i++;
        }
      } else {
        // 未知的字节情况，处理错误情况（这里简单跳过）
        i++;
      }
    }

    return str;
  }

  static async aesECBDecrypt(encryptText: string): Promise<string> {
    const cipherAlgName = 'AES128|ECB|PKCS7';
    const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES128');

    try {
      const symKey = await symKeyGenerator.convertKey({
        data: AesUtils.stringToUint8Array("meitejuheng66666", 16),
      });

      const cipher = cryptoFramework.createCipher(cipherAlgName);
      console.info(`xx cipher algName: ${cipher.algName}`);

      await cipher.init(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, null);

      const base64 = new util.Base64Helper();
      const decodedData = base64.decodeSync(encryptText);


      const output = await cipher.doFinal({
        data: decodedData
      });

      return AesUtils.uint8ArrayToString(output.data);
    } catch (error) {
      // Handle the error here or rethrow it.
      // For example:
      console.error(`xx decryption failed, ${error}`);
      return ''
    }
  }
  static aesECBDecryptSync(encryptText: string) {
    const cipherAlgName = 'AES128|ECB|PKCS7';
    const symKeyGenerator = cryptoFramework.createSymKeyGenerator('AES128');
    const symKey = symKeyGenerator.convertKeySync({
      data: AesUtils.stringToUint8Array(AesUtils.key, 16),
    });

    const cipher = cryptoFramework.createCipher(cipherAlgName);

    cipher.initSync(cryptoFramework.CryptoMode.DECRYPT_MODE, symKey, null);

    const base64 = new util.Base64Helper();
    const decodedData = base64.decodeSync(encryptText);

    const output = cipher.doFinalSync({
      data: decodedData
    });

    return AesUtils.uint8ArrayToString(output.data);
  }
}
