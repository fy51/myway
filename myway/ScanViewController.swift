//
//  ScanViewController.swift
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var session: AVCaptureSession!  //输入输出的中间桥梁
    
    var myInput: AVCaptureDeviceInput!  //创建输入流
    var myOutput: AVCaptureMetadataOutput!  //创建输出流
    
    var bgView = UIView()
    var barcodeView = UIView()
    
    var timer = Timer()
    var scanLine = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏标题
        navigationItem.title = "扫描二维码"
        
        // 设置定时器，延迟2秒启动
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(moveScannerLayer(_:)), userInfo: nil, repeats: true)
        
        // 初始化链接对象
        self.session = AVCaptureSession.init()
        
        // 设置高质量采集率
        self.session.canSetSessionPreset(AVCaptureSessionPresetHigh)
        
        // 获取摄像设备
        let device: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        // 捕捉异常，并处理
        do {
            self.myInput = try AVCaptureDeviceInput.init(device: device)
            self.myOutput = AVCaptureMetadataOutput.init()
            self.session.addInput(self.myInput)
            self.session.addOutput(self.myOutput)
        } catch {
            print("error")
        }
        
        // 创建预览视图
        self.createBackGroundView()
        
        // 设置扫描范围(横屏)
        self.myOutput.rectOfInterest = CGRect(x: 0.35, y: 0.2, width: UIScreen.main.bounds.width * 0.6 / UIScreen.main.bounds.height, height: 0.6)
        
        // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        myOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
        
        // 创建串行队列
        let dispatchQueue = DispatchQueue(label: "queue", attributes: [])
        
        // 设置输出流的代理
        self.myOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        
        // 创建预览图层
        let myLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
        myLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill  // 设置预览图层的填充方式
        myLayer?.frame = self.view.layer.bounds  // 设置预览图层的frame
        self.bgView.layer.insertSublayer(myLayer!, at: 0)  // 将预览图层(摄像头画面)插入到预览视图的最底部
        
        // 开始扫描
        self.session.startRunning()
        self.timer.fire()
    }
    
    
    // 扫描结果，代理
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects != nil && metadataObjects.count > 0 {
            
            // 停止扫描
            self.session.stopRunning()
            timer.invalidate()
            
            // 获取第一个
            let metaData = metadataObjects.first as! AVMetadataMachineReadableCodeObject
            let url = metaData.stringValue!
            print(url)
            
            DispatchQueue.main.async(execute: {
                // 扫描到之后
                
                // 检查网址是否合法（以 http:// 或 https:// 开头）
                if url.hasPrefix("http://") || url.hasPrefix("https://") {
                    // 网址有效，发送通知
                    let nc = NotificationCenter.default
                    nc.post(name: myNotification, object: nil, userInfo: ["url": url, "type": "scan"])
                } else {
                    // 网址无效，弹框提示
                    let ac = UIAlertController(title: "网址无效", message: url, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "确定", style: .default))
                    self.present(ac, animated: true)
                }
                
                // 关闭当前页
                _ = self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // 创建预览视图
    func createBackGroundView() {
        
        self.bgView.frame = UIScreen.main.bounds
        self.bgView.backgroundColor = UIColor.black
        self.view.addSubview(self.bgView)
        
        // 灰色蒙版
        let topView = UIView(frame: CGRect(x: 0, y: 0,  width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.35))
        
        let leftView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height * 0.35, width: UIScreen.main.bounds.size.width * 0.2, height: UIScreen.main.bounds.size.width * 0.6))
        
        let rightView = UIView(frame: CGRect(x: UIScreen.main.bounds.size.width * 0.8, y: UIScreen.main.bounds.size.height * 0.35, width: UIScreen.main.bounds.size.width * 0.2, height: UIScreen.main.bounds.size.width * 0.6))
        
        let bottomView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.width * 0.6 + UIScreen.main.bounds.size.height * 0.35, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height * 0.65 - UIScreen.main.bounds.size.width * 0.6))
        
        topView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        bottomView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        leftView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        rightView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        // 文字说明
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: UIScreen.main.bounds.size.width, height: 21))
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.text = "将二维码/条形码放入扫描框内，即自动扫描"
        bottomView.addSubview(label)
        
        self.bgView.addSubview(topView)
        self.bgView.addSubview(bottomView)
        self.bgView.addSubview(leftView)
        self.bgView.addSubview(rightView)
        
        // 屏幕中间扫描区域视图（透明）
        barcodeView.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.2, y: UIScreen.main.bounds.size.height * 0.35, width: UIScreen.main.bounds.size.width * 0.6, height: UIScreen.main.bounds.size.width * 0.6)
        barcodeView.backgroundColor = UIColor.clear
        barcodeView.layer.borderWidth = 1.0
        barcodeView.layer.borderColor = UIColor.white.cgColor
        self.bgView.addSubview(barcodeView)
        
        // 扫描线
        scanLine.frame = CGRect(x: 0, y: 0, width: barcodeView.frame.size.width, height: 5)
        scanLine.image = UIImage(named: "QRCodeScanLine")
        barcodeView.addSubview(scanLine)
    }
    
    // 扫描线滚动
    func moveScannerLayer(_ timer : Timer) {
        self.scanLine.frame = CGRect(x: 0, y: 0, width: self.barcodeView.frame.size.width, height: 12)
        
        UIView.animate(withDuration: 2) {
            self.scanLine.frame = CGRect(x: self.scanLine.frame.origin.x, y: self.scanLine.frame.origin.y + self.barcodeView.frame.size.height - 10, width: self.scanLine.frame.size.width, height: self.scanLine.frame.size.height)
        }
    }

}
