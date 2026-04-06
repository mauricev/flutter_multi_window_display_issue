import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let project = FlutterDartProject()
    let engine = FlutterEngine(name: "ReproFlutterEngine", project: project)
    let enableMultiViewSelector = NSSelectorFromString("enableMultiView")
    if engine.responds(to: enableMultiViewSelector) {
      _ = engine.perform(enableMultiViewSelector)
    }
    _ = engine.run(withEntrypoint: nil)

    let flutterViewController = FlutterViewController(
      engine: engine,
      nibName: nil,
      bundle: nil
    )
    let windowFrame = self.frame

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    setupChannel(controller: flutterViewController)

    super.awakeFromNib()

    self.alphaValue = 0
    self.orderOut(nil)
  }

  private func setupChannel(controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "repro/window",
      binaryMessenger: controller.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(
          FlutterError(
            code: "window_unavailable",
            message: "Main window released",
            details: nil
          )
        )
        return
      }

      switch call.method {
      case "arrangeReproWindows":
        self.arrangeReproWindows()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func arrangeReproWindows() {
    let hostBackgroundColor = NSColor(
      calibratedRed: 232.0 / 255.0,
      green: 110.0 / 255.0,
      blue: 47.0 / 255.0,
      alpha: 1
    )

    let reproWindows = NSApp.windows
      .filter { $0 !== self && $0.title == "Native macOS Host Window (Repro)" }
      .sorted { $0.windowNumber < $1.windowNumber }

    for window in reproWindows {
      window.isOpaque = true
      window.backgroundColor = hostBackgroundColor
      window.contentView?.wantsLayer = true
      window.contentView?.layer?.backgroundColor = hostBackgroundColor.cgColor
      window.contentView?.layer?.isOpaque = true
      if let flutterController = window.contentViewController as? FlutterViewController {
        flutterController.backgroundColor = hostBackgroundColor
        flutterController.view.wantsLayer = true
        flutterController.view.layer?.backgroundColor = hostBackgroundColor.cgColor
        flutterController.view.layer?.isOpaque = true
      }
    }

    guard reproWindows.count >= 2,
          let screen = NSScreen.main ?? NSScreen.screens.first else {
      return
    }

    let visibleFrame = screen.visibleFrame
    let gap: CGFloat = 24
    let first = reproWindows[0]
    let second = reproWindows[1]
    let totalWidth = first.frame.width + second.frame.width + gap
    let originY = visibleFrame.midY - (first.frame.height / 2)
    let originX = visibleFrame.midX - (totalWidth / 2)

    first.setFrameOrigin(NSPoint(x: originX, y: originY))
    second.setFrameOrigin(
      NSPoint(x: originX + first.frame.width + gap, y: originY)
    )
    second.orderFrontRegardless()
    first.orderFrontRegardless()
  }
}
