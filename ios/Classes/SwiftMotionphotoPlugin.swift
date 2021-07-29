import Flutter
import UIKit
import PhotosUI

@available(iOS 10.0, *)
public class SwiftMotionphotoPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "io.ente/motionphoto", binaryMessenger: registrar.messenger())
        let instance = SwiftMotionphotoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "getPlatformVersion") {
            result("iOS Version: " + UIDevice.current.systemVersion)
        }
        else if (call.method == "mediaSubTypes") {
            if let args = call.arguments as? Dictionary<String, String?>,let assetID = args["id"]! {
                let assetsFound = PHAsset.fetchAssets(withLocalIdentifiers: [assetID],
                                                      options: PHFetchOptions())
                if (assetsFound.count == 0) {
                    result(-1)
                } else {
                    result(assetsFound[0].mediaSubtypes.rawValue)
                }
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "Bad input", details: nil))
            }
        } else if(call.method == "getLivePhotoUrl") {
            if let args = call.arguments as? Dictionary<String, String?>,let assetID = args["id"]! {
                let assetsFound = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: PHFetchOptions())
                if(assetsFound.count == 0) {
                    result(nil)
                } else {
                    fetchLivePhotoUrl(asset: assetsFound[0]) { [weak self] (url, err) in
                        guard let _ = self else { result(nil); return }
                        if (url != nil) {
                            print(url?.path)
                            result(url?.path)
                        } else {
                            result(nil)
                        }
                    }
                }
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "Bad input", details: nil))
            }
        }
    }

    func fetchLivePhotoUrl(asset: PHAsset, completionHandler: @escaping (URL?, Error?) -> Void) {
        let option = PHLivePhotoRequestOptions()
        option.deliveryMode = .highQualityFormat
        option.isNetworkAccessAllowed = true
        PHImageManager.default().requestLivePhoto(for: asset, targetSize: CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight)),
                                                  contentMode: .default,
                                                  options: option) { [weak self] (livePhoto, info) in
            guard let self = self else { completionHandler(nil, nil); return }
            self.handleLivePhoto(asset: livePhoto, info: info, onCompletion: completionHandler)
        }
    }

    private func handleLivePhoto(asset: PHLivePhoto?,
                                 info: [AnyHashable: Any]?,
                                 onCompletion: @escaping (URL?, Error?) -> Void) {
        guard let asset = asset else { onCompletion(nil,nil); return}
        let resources = PHAssetResource.assetResources(for: asset)
        for resource in resources {
            print(resource.originalFilename)
            if resource.type == .video || resource.type == .pairedVideo {
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(resource.originalFilename)
                try? FileManager.default.removeItem(atPath: url.path)
                PHAssetResourceManager.default().writeData(for: resource, toFile: url, options: nil) { [weak self] (error) in
                    guard let _ = self else { onCompletion(nil, nil); return }
                    if (error != nil) {
                        onCompletion(nil, error)
                    } else {
                        onCompletion(url, nil)
                    }
                    return
                }
            }
        }
    }

}
