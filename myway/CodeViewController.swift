//
//  CodeViewController.swift
//

import UIKit

class CodeViewController: UIViewController {
    
    var urlString: String = ""
    var urlTitle: String = ""

    @IBOutlet weak var imageView: UIImageView!
    
    // 页面装载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置标题
        title = "二维码"
        
        // 显示生成的二维码
        let image = QRCode.creatQRCodeImage(text: urlString, size: 300)
        imageView.image = image
    }
}
