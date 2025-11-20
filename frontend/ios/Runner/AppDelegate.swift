import Flutter
import UIKit

#if canImport(GoogleMaps)
import GoogleMaps
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Flutter 플러그인 등록 (Google Maps 포함)
    GeneratedPluginRegistrant.register(with: self)

    // Google Maps API 키 설정 (플러그인 등록 후)
    // .env에서 GOOGLE_PUBLIC_API_KEY 사용
    #if canImport(GoogleMaps)
    GMSServices.provideAPIKey("AIzaSyDgutqY6sdUtjQ_nCZOfb5_GwZmz7mHiAY")
    #endif

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
