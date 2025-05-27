import UIKit
import Flutter
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 1. Firebase SDK 초기화
    FirebaseApp.configure()

    // 2. UNUserNotificationCenter delegate 등록
    let center = UNUserNotificationCenter.current()
    center.delegate = self

    // 3. 원격 푸시 알림 등록 요청
    application.registerForRemoteNotifications()

    // 4. Flutter 플러그인들 등록
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // 5. APNs 로부터 받은 device token을 Flutter/FirebaseMessaging에 전달
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // 6. 포그라운드 상태에서도 배너·사운드·뱃지 표시
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // [.banner]는 iOS 14+, iOS13 이전은 .alert
    completionHandler([.banner, .sound, .badge])
  }
}