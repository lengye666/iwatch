// 巨魔 iWatch助手 v3 - 纯 Foundation API 版本
import UIKit
import Foundation
import Darwin

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ app: UIApplication, didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainVC()
        window?.makeKeyAndVisible()
        return true
    }
}

class MainVC: UIViewController {
    let modelLabel = UILabel(), currentLabel = UILabel(), msgLabel = UILabel(), spinner = UIActivityIndicatorView(style: .medium)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1)
        let sv = UIStackView()
        sv.axis = .vertical; sv.spacing = 10; sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sv)
        NSLayoutConstraint.activate([sv.centerXAnchor.constraint(equalTo: view.centerXAnchor), sv.centerYAnchor.constraint(equalTo: view.centerYAnchor), sv.widthAnchor.constraint(equalToConstant: 300)])

        [modelLabel, currentLabel, msgLabel].forEach {
            $0.textColor = UIColor(white: 0.7, alpha: 1); $0.textAlignment = .center; $0.numberOfLines = 0; $0.font = .systemFont(ofSize: 12)
        }
        modelLabel.font = .systemFont(ofSize: 15, weight: .bold)
        modelLabel.text = "📱 \(getModel()) · iOS \(UIDevice.current.systemVersion)"

        let readBtn = makeBtn("📋 读取当前状态", UIColor(white: 0.5, alpha: 1), UIColor(white: 0.15, alpha: 1))
        readBtn.addTarget(self, action: #selector(readState), for: .touchUpInside)

        let fixBtn = makeBtn("🔧 修复手表配对", .white, UIColor(red: 0.98, green: 0.55, blue: 0.2, alpha: 1))
        fixBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        fixBtn.addTarget(self, action: #selector(fixPairing), for: .touchUpInside)

        let rstBtn = UIButton(); rstBtn.setTitle("↩️ 还原原始配置", for: .normal)
        rstBtn.setTitleColor(UIColor(white: 0.4, alpha: 1), for: .normal); rstBtn.titleLabel?.font = .systemFont(ofSize: 13)
        rstBtn.addTarget(self, action: #selector(restoreConfig), for: .touchUpInside)

        spinner.color = .white; spinner.hidesWhenStopped = true

        let credit = UILabel()
        credit.text = "开发者冷夜 · WeChat: BuLu-0208"
        credit.font = .systemFont(ofSize: 10); credit.textColor = UIColor(white: 0.25, alpha: 1); credit.textAlignment = .center

        [modelLabel, currentLabel, readBtn, fixBtn, rstBtn, spinner, msgLabel, UIView(), credit].forEach { sv.addArrangedSubview($0) }
    }

    func makeBtn(_ t: String, _ tc: UIColor, _ bg: UIColor) -> UIButton {
        let b = UIButton(); b.setTitle(t, for: .normal); b.setTitleColor(tc, for: .normal)
        b.backgroundColor = bg; b.layer.cornerRadius = 12; b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false; b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        b.widthAnchor.constraint(equalToConstant: 280).isActive = true
        return b
    }

    @objc func readState() {
        spinner.startAnimating(); msgLabel.text = ""
        DispatchQueue.global().async { [weak self] in
            let d = try? Data(contentsOf: URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist"))
            let txt = d.flatMap { try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil) }
                .flatMap { ($0 as? [String:Any]).map { "\($0)" } } ?? "未修改"
            DispatchQueue.main.async {
                self?.currentLabel.text = txt
                self?.spinner.stopAnimating()
            }
        }
    }

    @objc func fixPairing() {
        spinner.startAnimating(); msgLabel.text = "正在修复..."
        DispatchQueue.global().async { [weak self] in
            let product = getModel()
            let plist: [String: Any] = [
                "maxPairingCompatibilityVersion": 999,
                "minPairingCompatibilityVersion": 1,
                "minPairingCompatibilityVersionWithChipID": 1,
                "minQuickSwitchCompatibilityVersion": 1
            ]
            self?.writePlist(plist, to: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")

            let idxPlist: [String: Any] = ["iPhone": [product: 999]]
            for dir in ["/var/mobile/Library/Caches/com.apple.NanoRegistry",
                         "/var/mobile/Library/Caches/com.apple.nanoregistryd"] {
                try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
                self?.writePlist(idxPlist, to: "\(dir)/NanoRegistryPairingCompatibilityIndex.plist")
            }

            DispatchQueue.main.async {
                self?.msgLabel.text = "✅ 修复完成 · 请重启手机后打开 Watch App 配对"
                self?.spinner.stopAnimating()
            }
        }
    }

    @objc func restoreConfig() {
        let alert = UIAlertController(title: nil, message: "确认还原原始配置？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认还原", style: .destructive) { _ in
            self.spinner.startAnimating(); self.msgLabel.text = "正在还原..."
            DispatchQueue.global().async { [weak self] in
                try? FileManager.default.removeItem(atPath: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
                try? FileManager.default.removeItem(atPath: "/var/mobile/Library/Caches/com.apple.NanoRegistry/NanoRegistryPairingCompatibilityIndex.plist")
                try? FileManager.default.removeItem(atPath: "/var/mobile/Library/Caches/com.apple.nanoregistryd/NanoRegistryPairingCompatibilityIndex.plist")
                DispatchQueue.main.async {
                    self?.msgLabel.text = "✅ 已还原 · 重启生效"
                    self?.spinner.stopAnimating()
                }
            }
        })
        present(alert, animated: true)
    }

    func writePlist(_ plist: [String: Any], to path: String) {
        try? FileManager.default.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
        guard let d = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0) else { return }
        try? d.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
}

func getModel() -> String {
    var info = utsname(); uname(&info)
    return Mirror(reflecting: info.machine).children.compactMap {
        guard let v = $0.value as? Int8, v != 0 else { return nil }
        return String(UnicodeScalar(UInt8(v)))
    }.joined()
}
