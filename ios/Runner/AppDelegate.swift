import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Flutter 플러그인 등록 (Google Maps 포함)
    GeneratedPluginRegistrant.register(with: self)

    // Google Maps API 키 설정 (플러그인 등록 후)
    GMSServices.provideAPIKey("AIzaSyA3cKQUER5YaPEi5-9iWP_n5rFcXzlRn6c")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
