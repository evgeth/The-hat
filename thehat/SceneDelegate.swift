import UIKit

/// Owns the app's window. Apps built with the iOS 27 SDK must adopt the UIScene
/// lifecycle or UIKit terminates them at launch, so the window lives here rather
/// than on AppDelegate. The Hat runs a single scene (multiple scenes are disabled
/// in Info.plist).
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// The delegate of the app's one connected scene.
    static var current: SceneDelegate? {
        UIApplication.shared.connectedScenes
            .compactMap { $0.delegate as? SceneDelegate }
            .first
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // UISceneStoryboardFile in Info.plist makes UIKit create `window` and
        // load Main.storyboard before this is called.
        guard let window = window else { return }
        window.tintColor = AppColors.primaryDark
        ScreenshotMode.presentRequestedScreen(in: window)
    }

    /// Rebuilds the UI from the storyboard, e.g. after switching language at runtime.
    func reloadRootView() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootController = storyboard.instantiateViewController(withIdentifier: "appNavigationController") as? UINavigationController
        window?.rootViewController = rootController
    }
}
