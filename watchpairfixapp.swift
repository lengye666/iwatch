// 巨魔 iWatch助手 - TrollStore Apple Watch 配对修复
// 支持 iOS 14.0-17.0, 开发者冷夜~微信:BuLu-0208

import UIKit
import Foundation
import Darwin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ app: UIApplication, didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

class MainViewController: UIViewController {
    let scrollView = UIScrollView()
    let contentView = UIView()
    let statusLabel = UILabel()
    let currentLabel = UILabel()
    let readBtn = UIButton()
    let fixBtn = UIButton()
    let restoreBtn = UIButton()
    let spinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.08, alpha: 1)
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // ── 顶部区域 ──
        let iconLabel = UILabel()
        iconLabel.text = "⌚"
        iconLabel.font = .systemFont(ofSize: 52)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "巨魔 iWatch 助手"
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "解除 Apple Watch 配对版本限制"
        subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = UIColor(white: 0.5, alpha: 1)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ── 设备信息卡片 ──
        let deviceCard = makeCard()
        let deviceInfo = UILabel()
        deviceInfo.text = "\(getModel()) · iOS \(UIDevice.current.systemVersion)"
        deviceInfo.font = .systemFont(ofSize: 13, weight: .medium, design: .monospaced)
        deviceInfo.textColor = UIColor(white: 0.65, alpha: 1)
        deviceInfo.textAlignment = .center
        deviceInfo.translatesAutoresizingMaskIntoConstraints = false
        deviceCard.addSubview(deviceInfo)
        NSLayoutConstraint.activate([
            deviceInfo.topAnchor.constraint(equalTo: deviceCard.topAnchor, constant: 14),
            deviceInfo.bottomAnchor.constraint(equalTo: deviceCard.bottomAnchor, constant: -14),
            deviceInfo.centerXAnchor.constraint(equalTo: deviceCard.centerXAnchor),
        ])
        
        // ── 当前状态卡片 ──
        let stateCard = makeCard()
        let stateTitle = UILabel()
        stateTitle.text = "当前配对限制"
        stateTitle.font = .systemFont(ofSize: 11, weight: .semibold)
        stateTitle.textColor = UIColor(white: 0.4, alpha: 1)
        stateTitle.translatesAutoresizingMaskIntoConstraints = false
        
        currentLabel.text = "点击下方按钮读取"
        currentLabel.font = .systemFont(ofSize: 11, design: .monospaced)
        currentLabel.textColor = UIColor(white: 0.55, alpha: 1)
        currentLabel.numberOfLines = 0
        currentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stateCard.addSubview(stateTitle)
        stateCard.addSubview(currentLabel)
        NSLayoutConstraint.activate([
            stateTitle.topAnchor.constraint(equalTo: stateCard.topAnchor, constant: 12),
            stateTitle.leadingAnchor.constraint(equalTo: stateCard.leadingAnchor, constant: 14),
            currentLabel.topAnchor.constraint(equalTo: stateTitle.bottomAnchor, constant: 6),
            currentLabel.leadingAnchor.constraint(equalTo: stateCard.leadingAnchor, constant: 14),
            currentLabel.trailingAnchor.constraint(equalTo: stateCard.trailingAnchor, constant: -14),
            currentLabel.bottomAnchor.constraint(equalTo: stateCard.bottomAnchor, constant: -12),
        ])
        
        // ── 按钮 ──
        func makeBtn(_ title: String, color: UIColor, bgAlpha: CGFloat) -> UIButton {
            let b = UIButton()
            b.setTitle(title, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            b.setTitleColor(color, for: .normal)
            b.backgroundColor = color.withAlphaComponent(bgAlpha)
            b.layer.cornerRadius = 12
            b.translatesAutoresizingMaskIntoConstraints = false
            b.heightAnchor.constraint(equalToConstant: 48).isActive = true
            return b
        }
        
        readBtn.setTitle("📋  读取当前状态", for: .normal)
        readBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        readBtn.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        readBtn.backgroundColor = UIColor(white: 0.18, alpha: 1)
        readBtn.layer.cornerRadius = 12
        readBtn.translatesAutoresizingMaskIntoConstraints = false
        readBtn.heightAnchor.constraint(equalToConstant: 46).isActive = true
        readBtn.addTarget(self, action: #selector(readState), for: .touchUpInside)
        
        fixBtn.setTitle("🔧  修复手表配对", for: .normal)
        fixBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        fixBtn.setTitleColor(.white, for: .normal)
        fixBtn.backgroundColor = UIColor(red: 0.98, green: 0.55, blue: 0.2, alpha: 1)
        fixBtn.layer.cornerRadius = 14
        fixBtn.translatesAutoresizingMaskIntoConstraints = false
        fixBtn.heightAnchor.constraint(equalToConstant: 54).isActive = true
        fixBtn.addTarget(self, action: #selector(fixPairing), for: .touchUpInside)
        
        restoreBtn.setTitle("↩️  还原原始配置", for: .normal)
        restoreBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        restoreBtn.setTitleColor(UIColor(white: 0.45, alpha: 1), for: .normal)
        restoreBtn.translatesAutoresizingMaskIntoConstraints = false
        restoreBtn.addTarget(self, action: #selector(restoreConfig), for: .touchUpInside)
        
        // ── 状态 ──
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        
        statusLabel.text = ""
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = UIColor(white: 0.5, alpha: 1)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ── 说明卡片 ──
        let tipCard = makeCard()
        let tipLabel = UILabel()
        tipLabel.text = "修复后重启手机，打开 Watch App 即可配对\n支持 watchOS 8-26 全部版本"
        tipLabel.font = .systemFont(ofSize: 11)
        tipLabel.textColor = UIColor(white: 0.4, alpha: 1)
        tipLabel.numberOfLines = 0
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(tipLabel)
        NSLayoutConstraint.activate([
            tipLabel.topAnchor.constraint(equalTo: tipCard.topAnchor, constant: 12),
            tipLabel.bottomAnchor.constraint(equalTo: tipCard.bottomAnchor, constant: -12),
            tipLabel.leadingAnchor.constraint(equalTo: tipCard.leadingAnchor, constant: 14),
            tipLabel.trailingAnchor.constraint(equalTo: tipCard.trailingAnchor, constant: -14),
        ])
        
        // ── 底部 ──
        let creditLabel = UILabel()
        creditLabel.text = "开发者冷夜  ·  WeChat: BuLu-0208"
        creditLabel.font = .systemFont(ofSize: 10, weight: .medium)
        creditLabel.textColor = UIColor(white: 0.3, alpha: 1)
        creditLabel.textAlignment = .center
        creditLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ── 布局 ──
        let stack = UIStackView(arrangedSubviews: [
            iconLabel, titleLabel, subtitleLabel,
            makeSpacer(24),
            deviceCard,
            makeSpacer(12),
            stateCard,
            makeSpacer(20),
            readBtn, fixBtn,
            makeSpacer(14),
            restoreBtn,
            makeSpacer(8),
            spinner, statusLabel,
            makeSpacer(20),
            tipCard,
            makeSpacer(24),
            creditLabel,
            makeSpacer(16),
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置卡片宽度
        for card in [deviceCard, stateCard, tipCard] {
            card.translatesAutoresizingMaskIntoConstraints = false
            card.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40).isActive = true
        }
        for btn in [readBtn, fixBtn] {
            btn.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -40).isActive = true
        }
        
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.13, alpha: 1)
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        return v
    }
    
    func makeSpacer(_ h: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: h).isActive = true
        return v
    }
    
    @objc func readState() {
        spinner.startAnimating()
        statusLabel.text = "读取中..."
        DispatchQueue.global().async { [weak self] in
            let v = shell("cat /var/mobile/Library/Preferences/com.apple.NanoRegistry.plist 2>/dev/null | plutil -p - 2>/dev/null || echo '未修改'")
            DispatchQueue.main.async {
                self?.currentLabel.text = v.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.statusLabel.text = ""
                self?.spinner.stopAnimating()
            }
        }
    }
    
    @objc func fixPairing() {
        readBtn.isEnabled = false; fixBtn.isEnabled = false; restoreBtn.isEnabled = false
        spinner.startAnimating(); statusLabel.text = "正在修复..."
        
        DispatchQueue.global().async { [weak self] in
            let product = getModel()
            shell("mkdir -p /var/mobile/Library/Preferences")
            
            let plist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0"><dict>
            <key>maxPairingCompatibilityVersion</key><integer>999</integer>
            <key>minPairingCompatibilityVersion</key><integer>1</integer>
            <key>minPairingCompatibilityVersionWithChipID</key><integer>1</integer>
            <key>minQuickSwitchCompatibilityVersion</key><integer>1</integer>
            </dict></plist>
            """
            write(plist, to: "/var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
            
            let indexPlist = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0"><dict><key>iPhone</key><dict><key>\(product)</key><integer>999</integer></dict></dict></plist>
            """
            for dir in [
                "/var/mobile/Library/Caches/com.apple.NanoRegistry",
                "/var/mobile/Library/Caches/com.apple.nanoregistryd",
            ] {
                shell("mkdir -p '\(dir)'")
                write(indexPlist, to: "\(dir)/NanoRegistryPairingCompatibilityIndex.plist")
            }
            
            shell("chown mobile:mobile /var/mobile/Library/Preferences/com.apple.NanoRegistry.plist 2>/dev/null")
            shell("chmod 644 /var/mobile/Library/Preferences/com.apple.NanoRegistry.plist 2>/dev/null")
            
            DispatchQueue.main.async {
                self?.statusLabel.text = "✅ 修复完成 · 请重启手机后配对"
                self?.spinner.stopAnimating()
                self?.readBtn.isEnabled = true; self?.fixBtn.isEnabled = true; self?.restoreBtn.isEnabled = true
                self?.readState()
            }
        }
    }
    
    @objc func restoreConfig() {
        let alert = UIAlertController(title: nil, message: "确认删除配对版本修改，\n恢复原始状态？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "确认还原", style: .destructive) { [weak self] _ in
            self?.doRestore()
        })
        present(alert, animated: true)
    }
    
    func doRestore() {
        readBtn.isEnabled = false; fixBtn.isEnabled = false; restoreBtn.isEnabled = false
        spinner.startAnimating(); statusLabel.text = "正在还原..."
        DispatchQueue.global().async { [weak self] in
            shell("rm -f /var/mobile/Library/Preferences/com.apple.NanoRegistry.plist")
            shell("rm -f /var/mobile/Library/Caches/com.apple.NanoRegistry/NanoRegistryPairingCompatibilityIndex.plist")
            shell("rm -f /var/mobile/Library/Caches/com.apple.nanoregistryd/NanoRegistryPairingCompatibilityIndex.plist")
            DispatchQueue.main.async {
                self?.statusLabel.text = "✅ 已还原 · 重启生效"
                self?.spinner.stopAnimating()
                self?.readBtn.isEnabled = true; self?.fixBtn.isEnabled = true; self?.restoreBtn.isEnabled = true
                self?.readState()
            }
        }
    }
}

func getModel() -> String {
    var info = utsname(); uname(&info)
    return Mirror(reflecting: info.machine).children.compactMap {
        guard let v = $0.value as? Int8, v != 0 else { return nil }
        return String(UnicodeScalar(UInt8(v)))
    }.joined()
}

func shell(_ cmd: String) -> String {
    let argv: [UnsafeMutablePointer<CChar>?] = [
        strdup("/bin/sh"),
        strdup("-c"),
        strdup(cmd),
        nil
    ]
    defer { for a in argv { a.map { free($0) } } }
    
    let outPipe = Pipe()
    var pid: pid_t = 0
    var attr: posix_spawnattr_t? = nil
    posix_spawnattr_init(&attr)
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_CLOEXEC_DEFAULT)
    
    var fileActions: posix_spawn_file_actions_t? = nil
    posix_spawn_file_actions_init(&fileActions)
    posix_spawn_file_actions_adddup2(&fileActions, outPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
    posix_spawn_file_actions_adddup2(&fileActions, FileHandle.nullDevice.fileDescriptor, STDERR_FILENO)
    
    let ret = posix_spawn(&pid, "/bin/sh", &fileActions, &attr, argv, environ)
    if ret != 0 { return "" }
    outPipe.fileHandleForWriting.closeFile()
    let data = outPipe.fileHandleForReading.readDataToEndOfFile()
    waitpid(pid, nil, 0)
    return String(data: data, encoding: .utf8) ?? ""
}

func write(_ s: String, to path: String) {
    do { try s.write(toFile: path, atomically: true, encoding: .utf8) }
    catch { shell("cat > '\(path)' << 'ENDOFFILE'\n\(s)\nENDOFFILE") }
}
