//
//  ViewController.swift
//  MemoProject
//
//  Created by 신승아 on 2022/08/31.
//

import UIKit
import SnapKit
import RealmSwift

class ViewController: UIViewController {
    
    let localRealm = try! Realm()
    
    var tasks: Results<MemoModel>! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var favoriteTasks: Results<MemoModel>!{
        didSet {
            tableView.reloadData()
        }
    }
    
    var allTasks: Results<MemoModel>!{
        didSet {
            tableView.reloadData()
        }
    }

    
    var tableView: UITableView = {

        let view = UITableView(frame: CGRect.zero, style: .insetGrouped)
        view.backgroundColor = .lightGray
        view.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        
        return view
    }()
    
    var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    var writeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        view.tintColor = .systemYellow
        return view
    }()
    
    var searchController:  UISearchController!
    var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let searchBar = UISearchBar()
        searchBarDesign()
        tasks = localRealm.objects(MemoModel.self).filter("pinned == false").sorted(byKeyPath: "date", ascending: false)
        favoriteTasks = localRealm.objects(MemoModel.self).filter("pinned == true").sorted(byKeyPath: "date", ascending: false)
//        allTasks = localRealm.objects(MemoModel.self).sorted(byKeyPath: "date", ascending: false)

        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationItem.title = "0개의 메모"
        self.navigationController?.navigationBar.backgroundColor = .red
//        self.navigationItem.titleView = searchBar
        
        configureUI()
        tableView.dataSource = self
        tableView.delegate = self
        
        writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        tableView.reloadData()
    }
    
    func searchBarDesign() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "검색"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        searchController.searchBar.tintColor = .systemOrange
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.searchController = searchController
    }
    
    @objc func writeButtonClicked() {

        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as? WriteViewController else { return }
        
        vc.backActionHandler = {
            var title = ""
            var content = ""
            
            // 공백일 경우
            if vc.textView.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
            }
            
            // 한 줄일 경우
            else if !vc.textView.text!.contains("\n") {
                title = vc.textView.text!
            }
            
            // 개행 있을 경우
            else {
                
                let result = vc.textView.text.split(separator: "\n", maxSplits: 2)
                title = String(vc.textView.text!.split(separator: "\n").first!)
                content = "\(result[1])"
                
            }
            
            let task = MemoModel(title: title, content: content, rawContent: vc.textView.text, date: Date(), pinned: false)
            
            try! self.localRealm.write {
                self.localRealm.add(task)
                print(task)
                self.tableView.reloadData()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func configureUI() {

        [tableView, bottomView, writeButton].forEach {
            view.addSubview($0)
        }
        
        

        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(100)
        }
        
        writeButton.snp.makeConstraints { make in
            make.bottom.equalTo(-75)
            make.trailingMargin.equalTo(-2)
            make.height.width.equalTo(20)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
      
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
     
        return searchController.isActive && !searchBarIsEmpty()
    }

}

extension ViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        allTasks = localRealm.objects(MemoModel.self).filter("rawContent CONTAINS '\(searchController.searchBar.text!)'").sorted(byKeyPath: "date", ascending: false)
        searchText = searchController.searchBar.text!
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        updateSearchResults(for: searchController)
    }
    
    
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return isFiltering() ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if section == 0 {
            return isFiltering() ? "검색" : "고정된 메모"
        } else {
            return "메모"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
        
            return isFiltering() ? allTasks.count : favoriteTasks.count
            
            
        } else {
            
            return tasks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            print(#function)
            
            let row = isFiltering() ? allTasks[indexPath.row] : favoriteTasks[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            cell.memoTitle.text = row.title
            cell.memoText.text = row.content
            cell.memoDate.text = "\(row.date)"
            return cell
        } else {
            print(#function)
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            cell.memoTitle.text = tasks[indexPath.row].title
            cell.memoText.text = tasks[indexPath.row].content
            cell.memoDate.text = "\(tasks[indexPath.row].date)"
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
        if indexPath.section == 0 && !searchController.isActive {
            let favorite = UIContextualAction(style: .normal, title: "", handler: { [self] action, view, completionHandler in
                completionHandler(true)
                let taskUpdate = self.favoriteTasks[indexPath.row]
                try! self.localRealm.write {
                    taskUpdate.pinned = !taskUpdate.pinned
                    print("favorite task update: \(taskUpdate)")
                    tableView.reloadData()
                }
                
            })
            favorite.backgroundColor = .systemOrange
            favorite.image = UIImage(systemName: "pin.slash.fill")
            return UISwipeActionsConfiguration(actions: [favorite])
        } else if indexPath.section == 1 {
            let favorite = UIContextualAction(style: .normal, title: "", handler: { [self] action, view, completionHandler in
                completionHandler(true)
                let taskUpdate = self.tasks[indexPath.row]
                try! self.localRealm.write {
                    taskUpdate.pinned = !taskUpdate.pinned
                    print("task update: \(self.favoriteTasks)")
                    tableView.reloadData()
                }
            })
            favorite.backgroundColor = .systemOrange
            favorite.image = UIImage(systemName: "pin.fill")
            return UISwipeActionsConfiguration(actions: [favorite])
        } else {
            let row = allTasks[indexPath.row]
            let favorite = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHandler in
                completionHandler(true)
                try! self.localRealm.write {
                    row.pinned = !row.pinned
                    print("task update: \(row)")
                    tableView.reloadData()
                }
            })
            favorite.backgroundColor = .systemOrange
            favorite.image = row.pinned ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
            return UISwipeActionsConfiguration(actions: [favorite])
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { [self] action, view, completionHandler in
            completionHandler(true)

            var row = tasks[indexPath.row]

            if indexPath.section == 0 {
                row = isFiltering() ? allTasks[indexPath.row] : favoriteTasks[indexPath.row]
                print(indexPath.row)
            }

            try! self.localRealm.write {
                self.localRealm.delete(row)
                print(Realm.Configuration.defaultConfiguration.fileURL!)
                print(self.favoriteTasks!)
                tableView.reloadData()
            }
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as? WriteViewController else { return }
        var taskUpdate = tasks[indexPath.row]
        
        if indexPath.section == 0 {
            taskUpdate = isFiltering() ? allTasks[indexPath.row] : favoriteTasks[indexPath.row]
            print(favoriteTasks)
        }
        
        vc.contextAll = taskUpdate.rawContent
        vc.backActionHandler = {
            
            var title = ""
            var content = ""
            
            // 공백
            if vc.textView.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try! self.localRealm.write {
                    self.localRealm.delete(taskUpdate)
                    tableView.reloadData()
                }
            }
            
            // 수정했는데 같을 경우
            else if taskUpdate.rawContent == vc.textView.text {
                return
            }
            
            // 한줄
            else if !vc.textView.text!.contains("\n") {
                title = vc.textView.text!
            }
            
            // 개행
            else {
                title = String(vc.textView.text!.split(separator: "\n").first!)
                content = String(vc.textView.text.dropFirst(title.count+1))
            }
            
            try! self.localRealm.write {
                taskUpdate.title = title
                taskUpdate.content = content
                taskUpdate.rawContent = vc.textView.text
                taskUpdate.date = Date()
                
                self.tableView.reloadData()
            }
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


