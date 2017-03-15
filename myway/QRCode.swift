//
//  QRCode.swift
//

import UIKit

struct QRCode {
    
    // 生成二维码图像
    static func creatQRCodeImage(text: String, size: CGFloat) -> UIImage{
        // 创建滤镜
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        // 还原滤镜的默认属性
        filter?.setDefaults()
        
        // 设置需要生成二维码的数据
        filter?.setValue(text.data(using: String.Encoding.utf8), forKey: "inputMessage")
        
        // 从滤镜中取出生成的图片
        let ciImage = filter?.outputImage
        
        // 生成清晰度图
        let newImage = createNonInterpolatedUIImageFormCIImage(image: ciImage!, size: size)
        
        return newImage
    }
    
    // 根据CIImage生成指定大小的高清UIImage
    static func createNonInterpolatedUIImageFormCIImage(image: CIImage, size: CGFloat) -> UIImage {
        
        // CIImage没有frame与bounds属性，只有extent属性
        let ciextent: CGRect = image.extent.integral
        let scale: CGFloat = min(size/ciextent.width, size/ciextent.height)
        
        let context = CIContext(options: nil)  // 创建基于GPU的CIContext对象，性能和效果更好
        let bitmapImage: CGImage = context.createCGImage(image, from: ciextent)! // CIImage->CGImage
        
        let width = ciextent.width * scale
        let height = ciextent.height * scale
        let cs: CGColorSpace = CGColorSpaceCreateDeviceGray() // 灰度颜色通道
        let info_UInt32 = CGImageAlphaInfo.none.rawValue
        
        let bitmapRef = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: info_UInt32)! // 图形上下文，画布
        bitmapRef.interpolationQuality = CGInterpolationQuality.none // 写入质量
        bitmapRef.scaleBy(x: scale, y: scale) // 调整“画布”的缩放
        bitmapRef.draw(bitmapImage, in: ciextent)  // 绘制图片
        
        let scaledImage: CGImage = bitmapRef.makeImage()! // 保存
        return UIImage(cgImage: scaledImage)
    }
}
