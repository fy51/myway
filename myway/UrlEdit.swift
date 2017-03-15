//
//  UrlEdit.swift
//

import UIKit

class UrlEdit {
    var title = ""      // 弹框标题
    var message = ""    // 弹框信息
    
    var index: Int?     // 收藏索引（编辑时使用）
    var name = ""       // 收藏名称
    var site = ""       // 收藏网址
    
    // 属主视图控制器
    var vc: UIViewController? = nil
    
    init(vc: UIViewController) {
        self.vc = vc
    }
    
    init(vc: UIViewController, title: String, message: String) {
        self.title = title
        self.message = message
        self.vc = vc
    }

    // 显示
    func show(completion: (() -> Swift.Void)? = nil) {
        // 对话框
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // 索引存在（编辑时）
        if let index = self.index {
            self.name = userInfo.pageNames[index]
            self.site = userInfo.pageSites[index]
        }
        
        // 名称文本框
        ac.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "名称（例如：苹果官网）"
            textField.text = self.name
        })
        
        // 网址文本框
        ac.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            textField.placeholder = "网址（例如：https://apple.com/）"
            textField.autocorrectionType = .no
            textField.keyboardType = .URL
            textField.returnKeyType = .done
            textField.isUserInteractionEnabled = (self.title != "收藏网址")
            textField.text = self.site
        })
        
        // 确定按钮
        ac.addAction(UIAlertAction(title: "确定", style: .default, handler: { alert -> Void in
            // 空白字符
            let whitespace = CharacterSet.whitespacesAndNewlines
            
            // 名称
            let nameText = ac.textFields![0] as UITextField
            nameText.text = nameText.text?.trimmingCharacters(in: whitespace)
            guard let name = nameText.text else {
                return
            }
            
            // 网址
            let urlText = ac.textFields![1] as UITextField
            urlText.text = urlText.text?.trimmingCharacters(in: whitespace)
            guard var url = urlText.text else {
                return
            }
            
            // 判空
            if name.isEmpty || url.isEmpty {
                // TODO: 添加提示
                return
            }
            
//            // 如果网址前未输入前缀，给其添加缺省的 http://
//            if !(url.hasPrefix("http://") || url.hasPrefix("https://")) {
//                url = "http://" + url
//            }
//            
//            // 主机名后缺少“/”的则补上
//            let start = url.index(url.startIndex, offsetBy: url.hasPrefix("http://") ? 7 : 8)
//            if !url.substring(from: start).contains("/") {
//                url = url + "/"
//            }
            (_, url) = UrlUtil.check(urlString: url)
            
            if self.title == "编辑网址" {
                // 如果该页是主页，将主页地址页同步修改
                if userInfo.isHomePage(self.index!) {
                    userInfo.homePage = url
                }
                
                // 修改原索引处的收藏
                userInfo.pageNames[self.index!] = name
                userInfo.pageSites[self.index!] = url
                
            } else {
                // 检查网址是否存在
                if userInfo.pageSites.contains(url) {
                    // 网址已收藏，更新名称
                    let i = userInfo.pageSites.index(of: url)!
                    userInfo.pageNames[i] = name
                    
                } else {
                    // 网址未收藏，新增记录
                    userInfo.pageNames.append(name)
                    userInfo.pageSites.append(url)
                }
            }
            
            // 保存到文件
            userInfo.saveWebPages()
            
            // 调用外部方法
            if let completion = completion {
                completion()
            }
        }))
        
        // 取消按钮
        ac.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 显示
        vc?.present(ac, animated: true)
    }
}
