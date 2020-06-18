import Flutter
import UIKit

public class SwiftDataoversoundPlugin: NSObject, FlutterPlugin {
  var _arguments: [String : Any]?;
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dataoversound", binaryMessenger: registrar.messenger())
    let instance = SwiftDataoversoundPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
