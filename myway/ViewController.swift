//
//  ViewController.swift
//

import UIKit
import WebKit
import AVFoundation
import Photos


class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var webView: WKWebView!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
//    let appStoreLink = "https://itunes.apple.com/cn/app/迈威浏览器/id1209713461?mt=8".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    // 必要初始化器
    required init?(coder aDecoder: NSCoder) {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = .all
        } else {
            config.mediaPlaybackRequiresUserAction = false
        }
        self.webView = WKWebView(frame: CGRect.zero, configuration: config)
        
        super.init(coder: aDecoder)
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }

    // 页面装载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始WebView
        initWebView()

        // 标题
        navigationItem.title = "迈威浏览器"
        
        // 子页面返回按钮（只保留箭头）
        let item = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item;
        
        // 读取用户保存的信息
        userInfo.getAll()
        
        // 初始化工具栏按钮状态
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
        // 通知
        let nc = NotificationCenter.default
        nc.addObserver(forName: myNotification, object: nil, queue: nil, using: handleNotification)
        
        // 显示主页
        showHomePage()
    }

    // 转到扫码页面
    @IBAction func showScan(_ sender: UIBarButtonItem) {
        // 获取摄像头权限状态
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        switch authStatus {
            case .restricted:
                // 访问受限，例如：家长控制
                // TODO:改为适当的提示
                print("restricted")
                break
            
            case .denied:
                // 用户已拒绝，则提示并跳转到设置页面
                DispatchQueue.main.async(execute: { () -> Void in
                    let alertController = UIAlertController(title: "相机访问受限",
                                                        message: "点击“设置”，允许使用相机扫描二维码",
                                                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
                    let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
                        (action) -> Void in
                            self.goAppSetting()
                    })
                    alertController.addAction(cancelAction)
                    alertController.addAction(settingsAction)
                    self.present(alertController, animated: true, completion: nil)
                })
            
            case .notDetermined:
                // 用户未选择，则提示用户选择
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                    if granted {
                        // 用户授权，则转场到扫码页面
                        DispatchQueue.main.async(execute: {
                            self.goScan()
                        })
                    }
                })
            
            case .authorized:
                // 用户已授权，直接跳转到扫码页面
                goScan()
        }
    }
    
    func goScan() {
        performSegue(withIdentifier: "showScan", sender: self)
    }
    
    // 后退
    @IBAction func back(_ sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    // 前進
    @IBAction func forward(_ sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    // 分享
    @IBAction func share(_ sender: UIBarButtonItem) {
        // 分享网址
        guard let shareUrl = self.webView.url else {
            // 网址无效，弹框提示
            let ac = UIAlertController(title: "当前网址无效", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(ac, animated: true)
            
            return
        }
        let shareString = shareUrl.absoluteString
//        let isBlankPage = shareString == "about:blank"
        
        // 给网址加uuid参数（空白页／帮助页-->App Store中的链接）
//        let newUrlString = isBlankPage ? shareString : UrlUtil.addParam(url: shareUrl)
//        let newUrl = URL(string: newUrlString)!
        
//        // 获取相册权限
//        let authStatus = PHPhotoLibrary.authorizationStatus()
//        
//        switch authStatus {
//            
//        case .restricted:
//            // 访问受限，例如：家长控制
//            // TODO:改为适当的提示
//            print("restricted")
//            break
//            
//        case .denied:
//            // 用户已拒绝，则提示并跳转到设置页面
//            DispatchQueue.main.async(execute: { () -> Void in
//                let alertController = UIAlertController(title: "相册访问受限",
//                                                        message: "点击“设置”，允许存储二维码到相册",
//                                                        preferredStyle: .alert)
//                let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
//                let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
//                    (action) -> Void in
//                        self.goAppSetting()
//                })
//                alertController.addAction(cancelAction)
//                alertController.addAction(settingsAction)
//                self.present(alertController, animated: true, completion: nil)
//            })
//            
//        case .notDetermined:
//            // 用户未选择，则提示用户选择
//            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
//                if granted {
//
//                }
//            })
//            
//        case .authorized:
//            // 用户已授权
//            break
//        }
        
        // 分享文本
        let shareText = self.title ?? "迈威分享"
        
        // 分享图片
        let shareImage = QRCode.creatQRCodeImage(text: shareString, size: 300)

        // 分享内容数组
        let items: [Any] = [shareText, shareImage, shareUrl]
        
        // 分享到浏览器
        let safariActivity = ShareActivity(title: "Safari", imageName: "safari") { 
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(shareUrl)
            } else {
                UIApplication.shared.openURL(shareUrl)
            }
        }
        
        // 分享为二维码
        let codeActivity = ActionActivity(title: "二维码", imageName: "code") {
            self.performSegue(withIdentifier: "showCode", sender: self)
        }
        
        // 自定分享数组
        let activities = [safariActivity, codeActivity]
        
        // 排除数组
        var excludedTypes: [UIActivityType] = [
            UIActivityType.addToReadingList,
            UIActivityType.assignToContact,
            UIActivityType.postToFacebook,
            UIActivityType.postToVimeo,
            UIActivityType.postToWeibo,
            UIActivityType.postToFlickr,
            UIActivityType.postToTwitter
        ]
        if #available(iOS 9.0, *) {
            excludedTypes.append(UIActivityType.openInIBooks)
            excludedTypes.append(UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"))
            excludedTypes.append(UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension"))
        }
        
        // 显示分享视图
        let vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
        vc.excludedActivityTypes = excludedTypes
        vc.popoverPresentationController?.barButtonItem = self.toolbarItems?[2]
        present(vc, animated: true)
    }

    // 收藏
    @IBAction func favorite(_ sender: UIBarButtonItem) {
        // 检查网址
        guard let url = self.webView.url?.absoluteString else {
            // 网址无效则弹框提示
            let ac = UIAlertController(title: "当前网址无效", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(ac, animated: true)
            
            return
        }

        // 弹框（收藏网址）
        let ue = UrlEdit(vc: self, title: "收藏网址", message: "")
        ue.name = self.title ?? ""
        ue.site = url
        ue.show()
    }
    
    // 刷新
    @IBAction func reload(_ sender: UIBarButtonItem) {
        if webView.url?.absoluteString != "about:blank" {
            webView.reload()
        }
    }
    
    // 处理通知
    func handleNotification(notification: Notification) -> Void {
        guard let info = notification.userInfo,
            let type = info["type"] as? String,
            let url  = info["url"] as? String else {
            return
        }
        
        // 扫描网址
        if type == "scan" {
            // 检查网址是否已存在
            if !userInfo.pageSites.contains(url) {
                // 将该网址添加到收藏列表，并保存
                userInfo.pageNames.append(url)  // TODO:能否用标题，或让用户输入
                userInfo.pageSites.append(url)
                
                userInfo.saveWebPages()
                
                // 如果不存在主页，则将该网址设为主页，并保存
                if userInfo.homePage.isEmpty {
                    userInfo.homePage = url
                    userInfo.saveHomePage()
                }
            }
        }
        
        // 显示网页
        loadUrl(urlString: url)
    }
   
    // 初始WebView
    func initWebView() {
        // 新建WebView
        view.insertSubview(webView, belowSubview: progressView)
        
        // 禁止自动约束
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 自定义约束
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        // 添加观察器
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        
        // 添加手势支持
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // 显示主页
    func showHomePage() {
        if userInfo.homePage == "" {
            showHelp()
        } else {
            loadUrl(urlString: userInfo.homePage)
        }
    }
    
    // 显示帮助
    func showHelp() {
        let title = "<title>迈威浏览器</title>"
        
        let style = "padding: 30px 15px 0; line-height: 45px;color: #222; letter-spacing: .8px; font-size: 28px;"
        
        let help1 = "<p><center><b>首页使用说明</b></center>"
            + "1. 点击左上角“相机”图标，可扫描二维码，打开相应的网址。<br>"
            + "2. 点击右上角“编辑”图标，可管理收藏的网址、设置主页。<br>"
            + "3. 点击左下方“<”、“>”图标，可返回上一页或跳转下一页。<br>"
            + "4. 点击下方中间“分享”图标，可分享当前网页链接及二维码。<br>"
            + "5. 点击右下方“书签”图标，可将当前网址收藏起来。<br>"
            + "6. 点击右下方“刷新”图标，可刷新当前网页。<br>"
        
        let help2 = "<p><center><b>网址收藏页说明</b></center>"
            + "1. 点击网址收藏页右上角“+”号，可手工添加网址。<br>"
            + "2. 在网址上左滑，可设置主页、修改网址、删除网址。<br>"
            + "3. 在网址上点击，可打开该网址。<br>"
        
        let readme = "\(title)<body style='\(style)'>\(help1)<br>\(help2)</body>"
        webView.loadHTMLString(readme, baseURL: nil)
    }
    
    // 浏览网址
    func loadUrl(urlString: String) {
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
    }
    
    // 观察值的改变
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context:
        UnsafeMutableRawPointer?) {
        // 标题
        if (keyPath == "title") {
            title = webView.title
        }

        // 状态
        if (keyPath == "loading") {
            backButton.isEnabled = webView.canGoBack
            forwardButton.isEnabled = webView.canGoForward
        }
        
        // 進度
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }

    // 网页装载结束
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 重置進度
        progressView.setProgress(0.0, animated: false)
    }
    
    // 页面装载错误
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // 取消浏览（忽略此错误，可能是页面未加载完就另行操作造成的）
        if (error as NSError).code == NSURLErrorCancelled {
            return
        }
        
        // 其余错误，则弹出对话框
        let alert = UIAlertController(title: "错误", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // 处理弹出新窗口(target=_blank)
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // WKWebView 总体内存占用过大，页面即将白屏的时候调用，此时 webView.URL 取值尚不为 nil
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    // 准备转场
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCode" {
            let codeVC = segue.destination as! CodeViewController
            if let urlString = webView.url?.absoluteString {
                codeVC.urlString = urlString
            }
        }
    }
    
    // 跳转到应用程序（权限）设置页面
    func goAppSetting() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        
        if let url = url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}

