import 'dart:typed_data';

class Util {
  static Uint8List toByte(String hexString) {
    int len = hexString.length ~/ 2;
    Uint8List _result;
    for (int i = 0; i < len; i++) {
      _result.add(int.parse(hexString.substring(2 * i, 2 * i + 2), radix: 16));
    }
    return _result;
  }

  static String toHex(Uint8List buf) {
    if (buf == null) return "";
    StringBuffer result = new StringBuffer(2 * buf.length);
    for (int i = 0; i < buf.length; i++) {
      appendHex(result, buf[i]);
//              if(i > 0 && i%16 == 0){
//            	  result.append("\n");
//              }
      if (i > 0 && i % 4 == 0) {
        result.write(" ");
      }
    }
    return result.toString();
  }

  static final String HEX = "0123456789ABCDEF";
  
  static void appendHex(StringBuffer sb, var b) {
    sb.write(HEX[(b >> 4) & 0x0f]);
    sb.write(HEX[(b & 0x0f)]);
  }
}
