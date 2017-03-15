//
//  CustomActivity.swift
//

import UIKit

class CustomActivity: UIActivity {
    // 属性
    var type: UIActivityType
    var title: String
    var image: UIImage
    var customAction: () -> Void
    
    // 初始化器
    init(title: String, imageName: String, performAction: @escaping () -> Void) {
        self.title = title
        self.image = UIImage(named: imageName + (UI_USER_INTERFACE_IDIOM() == .pad ? "_76" : "_60"))!
        self.type = UIActivityType(rawValue: "Action \(title)")
        self.customAction = performAction
        super.init()
    }
    
    // 分享类型（在 completionWithItemsHandler 回调里可以用于判断）
    override var activityType: UIActivityType? {
        return type
    }
    
    // 分享框中的名称
    override var activityTitle: String? {
        return title
    }
    
    // 分享框中的图标
    override var activityImage: UIImage? {
        return image
    }
    
    // 是否显示分享按钮
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    // 解析分享数据
    override func prepare(withActivityItems activityItems: [Any]) {
        // Nothing to prepare
    }
    
    // 执行分享
    override func perform() {
        customAction()
        
        //activityDidFinish(true)
    }
}
