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
            
            // Check if result is degraded and retry if needed
            if let info = info,
               let isDegraded = info[PHImageResultIsDegradedKey] as? Bool,
               isDegraded {
                // Don't process degraded results, wait for high quality
                return
            }
            
            if livePhoto == nil {
                self.handleAsset(asset, info: info, onCompletion: completionHandler)
            } else {
                self.handleLivePhoto(asset: livePhoto, info: info, onCompletion: completionHandler)
            }
        }
    }

    private func handleLivePhoto(asset: PHLivePhoto?,
                                 info: [AnyHashable: Any]?,
                                 onCompletion: @escaping (URL?, Error?) -> Void) {
        guard let asset = asset else { onCompletion(nil,nil); return}
        let resources = PHAssetResource.assetResources(for: asset)
        handleWritingData(resources: resources, info: info, onCompletion: onCompletion)
    }

    private func handleAsset(_ asset: PHAsset,
                             info: [AnyHashable: Any]?,
                             onCompletion: @escaping (URL?, Error?) -> Void) {
        let resources = PHAssetResource.assetResources(for: asset)
        handleWritingData(resources: resources, info: info, onCompletion: onCompletion)
    }

    private func handleWritingData(resources: [PHAssetResource],
                                   info: [AnyHashable: Any]?,
                                   onCompletion: @escaping (URL?, Error?) -> Void) {
        
        // Find highest quality video resource
        var targetResource: PHAssetResource?
        
        // Priority order: video -> fullSizeVideo -> pairedVideo
        for resource in resources {
            if resource.type == .video {
                targetResource = resource
                break
            }
        }
        
        if targetResource == nil {
            for resource in resources {
                if resource.type == .fullSizeVideo {
                    targetResource = resource
                    break
                }
            }
        }
        
        if targetResource == nil {
            for resource in resources {
                if resource.type == .pairedVideo {
                    targetResource = resource
                    break
                }
            }
        }
        
        guard let resource = targetResource else {
            onCompletion(nil, NSError(domain: "LivePhotoError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No video resources found"]))
            return
        }
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(resource.originalFilename)
        try? FileManager.default.removeItem(atPath: url.path)
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        
        PHAssetResourceManager.default().writeData(for: resource, toFile: url, options: options) { [weak self] (error) in
            guard let _ = self else { onCompletion(nil, nil); return }
            if (error != nil) {
                onCompletion(nil, error)
            } else {
                onCompletion(url, nil)
            }
        }
    }
}