//
//  EditViewController.swift
//

import UIKit

class EditViewController: UITableViewController {

    // 页面装载
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 导航栏标题
        navigationItem.title = "网址收藏"

        // 导航栏右边：新增按钮
        let item2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUrl))
        navigationItem.rightBarButtonItem = item2
        
        // 去掉表格多余空行
        tableView.tableFooterView = UIView()
    }

    // 列表行数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfo.pageSites.count
    }

    // 列表数据
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let label = cell.contentView.viewWithTag(100) as! UILabel
        
        if userInfo.pageSites[indexPath.row] == userInfo.homePage {
            cell.accessoryType = .checkmark
            label.text = "★ " + userInfo.pageNames[indexPath.row]
        } else {
            cell.accessoryType = .none
            label.text = "☆ " + userInfo.pageNames[indexPath.row]
        }

        return cell
    }
    
    // 选择
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 发送通知
        let url = userInfo.pageSites[indexPath.row]
        let nc = NotificationCenter.default
        nc.post(name: myNotification, object: nil, userInfo: ["url": url, "type": "pick"])

        // 关闭页面
        _ = navigationController?.popViewController(animated: true)
    }

    // 自定义操作
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // 设置主页
        let home = UITableViewRowAction(style: .normal, title: "主页") {_, indexPath in
            self.setHomePage(indexPath.row)
        }
        home.backgroundColor = UIColor.blue
        
        // 修改网址
        let edit = UITableViewRowAction(style: .normal, title: "修改") {_, indexPath in
            self.editUrl(indexPath: indexPath)
            tableView.isEditing = false
        }
        edit.backgroundColor = UIColor.orange
        
        // 删除网址
        let delete = UITableViewRowAction(style: .destructive, title: "删除") {_, indexPath in
            self.deleteUrl(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete, edit, home]
    }
    
    // 设置主页
    func setHomePage(_ index: Int) {
        // 修改主页
        if userInfo.pageSites[index] != userInfo.homePage {
            userInfo.homePage = userInfo.pageSites[index]
            userInfo.saveHomePage()
            
            // 刷新列表
            tableView.reloadData()
        }
    }
    
    // 新增网址
    func addUrl() {
        let ue = UrlEdit(vc: self, title: "新增网址", message: "请给网址命名，并输入完整的网址。")
        ue.show {
            // 重新装载列表数据
            self.tableView.reloadData()
        }
    }
    
    // 编辑网址
    func editUrl(indexPath: IndexPath) {
        let ue = UrlEdit(vc: self, title: "编辑网址", message: "请给网址命名，并输入完整的网址。")
        ue.index = indexPath.row
        ue.show() {
            // 重新装载列表数据
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    // 删除网址
    func deleteUrl(_ index: Int) {
        if userInfo.isHomePage(index) {
            userInfo.homePage = ""
            userInfo.saveHomePage()
        }
        userInfo.remove(at: index)
        
        // 保存所有信息
        userInfo.saveAll()
    }
}
