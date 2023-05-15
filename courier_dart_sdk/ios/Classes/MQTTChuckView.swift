import CourierMQTTChuck
import Flutter
#if canImport(SwiftUI)
import SwiftUI
#endif
import UIKit

class MQTTChuckViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private let logger = MQTTChuckLogger()

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FlutterMQTTChuckView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            logger: self.logger,
            binaryMessenger: messenger)
    }
}

class FlutterMQTTChuckView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let logger: MQTTChuckLogger
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        logger: MQTTChuckLogger,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        self.logger = logger
        super.init()
        createNativeView()
    }
    
    func view() -> UIView {
        return _view
    }
    
    func createNativeView(){
        if #available(iOS 15, *) {
            let topVC = (UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first)!.rootViewController
            let mqttChuckView = MQTTChuckView(logger: self.logger)
            let hostingController = UIHostingController(rootView: mqttChuckView)
            let navigationController = UINavigationController(rootViewController: hostingController)
            let swiftuiView = navigationController.view!
            swiftuiView.translatesAutoresizingMaskIntoConstraints = false
            topVC!.addChild(navigationController)
            _view.addSubview(swiftuiView)

            NSLayoutConstraint.activate([
                swiftuiView.leadingAnchor.constraint(equalTo: _view.leadingAnchor),
                swiftuiView.trailingAnchor.constraint(equalTo: _view.trailingAnchor),
                swiftuiView.topAnchor.constraint(equalTo: _view.topAnchor),
                swiftuiView.bottomAnchor.constraint(equalTo: _view.bottomAnchor)
            ])
            navigationController.didMove(toParent: topVC)
        } else {
            let nativeLabel = UILabel()
            nativeLabel.text = "MQTT Chuck is only supported on iOS 15 and above."
            nativeLabel.textColor = UIColor.white
            nativeLabel.textAlignment = .center
            nativeLabel.frame = CGRect(x: 0, y: 0, width: 180, height: 48.0)
            _view.addSubview(nativeLabel)
        }
    }
}
