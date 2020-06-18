import Cocoa
import FlutterMacOS
//import 

public class DataoversoundPlugin: NSObject, FlutterPlugin {

  var _arguments: [String : Any]?;

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "dataoversound", binaryMessenger: registrar.messenger)
    let instance = DataoversoundPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "playTone":
        self.playTone(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

   private func playTone(result: FlutterResult) {
        
    let wavFile = self._arguments!["wavFile"] as? String
       
        if wavFile != nil {
            let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
                     //get where the file is
            let url = URL(fileURLWithPath: library.path).appendingPathComponent(wavFile!)
                   
            
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: url.path) {
                   print("FILE AVAILABLE")

                AudioAnalisys.open_audiofile(url: url)
               } else {
                   print("FILE NOT AVAILABLE")
               }
            
            result("Tone Played")
        } else {
            result(FlutterError(code: "UNAVAILABLE",
                                message: "Cannot play tone",
                                details: nil))
            
        }
    }
}
