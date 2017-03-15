//
//  UrlUtil.swift
//

import Foundation

class UrlUtil {
    
    // 检查网址是否合法
    static func check(urlString: String) -> (changed: Bool, newString: String) {
        var newString = urlString
        
        // 如果网址前未输入前缀，给其添加缺省的 http://
        if !(newString.hasPrefix("http://") || newString.hasPrefix("https://")) {
            newString = "http://" + newString
        }
        
        // 主机名后缺少“/”的则补上
        let start = newString.index(newString.startIndex, offsetBy: newString.hasPrefix("http://") ? 7 : 8)
        if !newString.substring(from: start).contains("/") {
            newString = newString + "/"
        }
        
        return (urlString != newString, newString)
    }
    
    // 给网址加uuid参数
    static func addParam(url: URL) -> String {
        // 生成UUID
        let uuid = (CFUUIDCreateString(nil , CFUUIDCreate(nil)) as String).replacingOccurrences(of: "-", with: "")
        
        // 连接字符
        let joinStr = ((url.query == nil) ? "?" : "&")
        
        // uuid参数
        let uuidParam = "\(joinStr)uuid=\(uuid)"
        
        // 原网址
        let urlString = url.absoluteString
        
        // 新网址
        var newUrlString: String
        
        // 分析网址
        if urlString.hasSuffix("/") && !urlString.contains("#") {
            newUrlString = urlString + "#"
        } else if (urlString.range(of: "?uuid=") == nil) && (urlString.range(of: "&uuid=") == nil) {
            // 原网址中不含uuid参数
            if url.fragment == nil {
                // 无#，直接在后面拼接
                newUrlString = "\(url.absoluteString)\(uuidParam)"
            } else {
                // 有#，查找#的位置
                let range = urlString.range(of: "#")!
                newUrlString = urlString.replacingCharacters(in: range, with: "\(uuidParam)#")
            }
        } else {
            // 原网址中含有uuid参数
            newUrlString = urlString
        }
        
        return newUrlString
    }
}
