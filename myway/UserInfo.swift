//
//  UserInfo.swift
//

import Foundation

class UserInfo {
    private let homePageKey = "HomePage"        // 主页地址
    private let pageNamesKey = "PageNames"      // 网页名称
    private let pageSitesKey = "PageSites"      // 网页地址
    
    var homePage: String = ""
    var pageNames: [String] = []
    var pageSites: [String] = []
    
    // 获取所有信息
    func getAll() {
        // 升级老版参数
        update()
        
        if let homePage = UserDefaults.standard.string(forKey: homePageKey) {
            self.homePage = homePage
        }

        if let pageNames = UserDefaults.standard.array(forKey: pageNamesKey) {
            self.pageNames = pageNames as! [String]
        }
        
        if let pageSites = UserDefaults.standard.array(forKey: pageSitesKey) {
            self.pageSites = pageSites as! [String]
        }
        
        // 检查所有网址
        checkUrl()
    }
    
    // 升级参数名称
    func update() {
        // 老参数：BookMarkNames （v1.1）
        if let names = UserDefaults.standard.array(forKey: "BookMarkNames") {
            // 删除老参数，保存为新参数
            UserDefaults.standard.removeObject(forKey: "BookMarkNames")
            UserDefaults.standard.set(names, forKey: pageNamesKey)
        }
        
        // 老参数：BookMarkUrls （v1.1）
        if let urls = UserDefaults.standard.array(forKey: "BookMarkUrls") {
            // 删除老参数，保存为新参数
            UserDefaults.standard.removeObject(forKey: "BookMarkUrls")
            UserDefaults.standard.set(urls, forKey: pageSitesKey)
        }
    }
    
    // 检查所有网址，修正不符合要求的网址
    func checkUrl() {
        // 检查网页地址
        var needSave = false
        for i in 0..<pageSites.count {
            let page = UrlUtil.check(urlString: pageSites[i])
            if page.changed {
                needSave = true
                pageSites[i] = page.newString
            }
        }
        if needSave {
            savePageSites()
        }
    }
    
    // 保存主页信息
    func saveHomePage() {
        UserDefaults.standard.set(self.homePage, forKey: homePageKey)
    }
    
    // 保存收藏网址名称
    func savePageNames() {
        UserDefaults.standard.set(self.pageNames, forKey: pageNamesKey)
    }
    
    // 保存收藏网址地址
    func savePageSites() {
        UserDefaults.standard.set(self.pageSites, forKey: pageSitesKey)
    }
    
    // 保存收藏网址
    func saveWebPages() {
        savePageNames()
        savePageSites()
    }
    
    // 保存所有信息
    func saveAll() {
        saveHomePage()
        saveWebPages()
    }
    
    // 删除指定的网址
    func remove(at index: Int) {
        self.pageNames.remove(at: index)
        self.pageSites.remove(at: index)
    }
    
    // 判断是否时主页
    func isHomePage(_ index: Int) -> Bool {
        return pageSites[index] == homePage
    }
 
}
