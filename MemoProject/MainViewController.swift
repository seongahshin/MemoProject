//
//  ViewController.swift
//  MemoProject
//
//  Created by 신승아 on 2022/08/31.
//

import UIKit
import SnapKit
import RealmSwift
import Toast

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
        onBoarding()
        searchBarDesign()
        favoriteTasks = localRealm.objects(MemoModel.self).filter("pinned == true").sorted(byKeyPath: "date", ascending: false)
        tasks = localRealm.objects(MemoModel.self).filter("pinned == false").sorted(byKeyPath: "date", ascending: false)
        
        // 네비바
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        // 메모 개수
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let memoCount = numberFormatter.string(for: self.localRealm.objects(MemoModel.self).count)!
        navigationItem.title = "\(String(describing: memoCount))개의 메모"
        
        // 툴바
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.backgroundColor = UIColor(named: "DarkMode")
        var items = [UIBarButtonItem]()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(flexibleSpace)
        items.append(UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(writeButtonClicked)))
        self.toolbarItems = items
        
        configureUI()
        
        // 헤더
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "customHeader")
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
//        writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        memoCountTitle()
    }
    
    func memoCountTitle() {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let memoCount = numberFormatter.string(for: self.localRealm.objects(MemoModel.self).count)!
        navigationItem.title = "\(String(describing: memoCount))개의 메모"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
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
        
    
        let realm = try! Realm()
        print(Realm.Configuration.defaultConfiguration.fileURL!)

        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as? WriteViewController else { return }
        
        vc.backActionHandler = { [self] in
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
            
            
            
            let task = MemoModel(title: title, content: content, rawContent: vc.textView.text, date: self.dateCalculate(date: Date()), pinned: false)
            
            try! self.localRealm.write {
                self.localRealm.add(task)
                print(task)
                self.tableView.reloadData()
                self.viewWillAppear(false)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dateCalculate(date: Date) -> String {
        let today = date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        formatter.dateFormat = "yyyy.MM.dd a hh:mm"
        return formatter.string(from: today)
    }
    
    func configureUI() {

        [tableView].forEach {
            view.addSubview($0)
        }
        
        

        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func searchBarIsEmpty() -> Bool {
      
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
     
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func onBoarding() {
        if UserDefaults.standard.object(forKey: "first") == nil {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController else { return }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "customHeader")
        let textLabel = UILabel()
        header?.addSubview(textLabel)
        
        if section == 0 {
            header?.textLabel?.text = isFiltering() ? "\(allTasks.count)개 찾음" : "고정된 메모"
        } else {
            header?.textLabel?.text = "메모"
        }
        
        header?.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        header?.textLabel?.textColor = UIColor(named: "TextColor")
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
                
            let view: UIView = {
                let v = UIView(frame: .zero)
                return v
            }()
                
            header.backgroundView = view
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
        return 60
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
                
                if favoriteTasks.count == 5 {
                    self.view.makeToast("", duration: 1.5,
                                        point: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height/2),
                                           title: "더이상 고정시킬 수 없어요",
                                           image: nil,
                                           style: .init(),
                                           completion: nil)
                    return
                } else {
                    let taskUpdate = self.tasks[indexPath.row]
                    try! self.localRealm.write {
                        taskUpdate.pinned = !taskUpdate.pinned
                        print("task update: \(self.favoriteTasks)")
                        tableView.reloadData()
                    }
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
        
        if indexPath.section == 0 && !searchController.isActive {
            let delete = UIContextualAction(style: .normal, title: "") { [self] action, view, completionHandler in
                completionHandler(true)
                var row = isFiltering() ? allTasks[indexPath.row] : favoriteTasks[indexPath.row]
                try! self.localRealm.write {
                    self.localRealm.delete(row)
                    self.memoCountTitle()
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                    print(self.favoriteTasks!)
                    tableView.reloadData()
                }
            }
            delete.image = UIImage(systemName: "trash")
            delete.backgroundColor = .red
            let config = UISwipeActionsConfiguration(actions: [delete])
            return config
        } else if indexPath.section == 1 {
            let delete = UIContextualAction(style: .normal, title: "") { [self] action, view, completionHandler in
                completionHandler(true)
                var row = tasks[indexPath.row]
                try! self.localRealm.write {
                    self.localRealm.delete(row)
                    self.memoCountTitle()
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                    print(self.favoriteTasks!)
                    tableView.reloadData()
                }
            }
            delete.image = UIImage(systemName: "trash")
            delete.backgroundColor = .red
            let config = UISwipeActionsConfiguration(actions: [delete])
            return config
        } else {
            let delete = UIContextualAction(style: .normal, title: "") { [self] action, view, completionHandler in
                completionHandler(true)
                var row = allTasks[indexPath.row]
                try! self.localRealm.write {
                    self.localRealm.delete(row)
                    self.memoCountTitle()
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
        
        
        let delete = UIContextualAction(style: .normal, title: "") { [self] action, view, completionHandler in
            completionHandler(true)

            var row = tasks[indexPath.row]

            if indexPath.section == 0 {
                row = isFiltering() ? allTasks[indexPath.row] : favoriteTasks[indexPath.row]
                print(indexPath.row)
            }

            try! self.localRealm.write {
                self.localRealm.delete(row)
                self.memoCountTitle()
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
        
        // 여기서(고정된 메모)를 select하면 앱이 꺼지는데, 어떻게 해결해야할지를 모르겠어요 ...
        if indexPath.section == 0 && !searchController.isActive {
            taskUpdate = isFiltering() ? allTasks[indexPath.row] : favoriteTasks[indexPath.row]
        }
        
        vc.contextAll = taskUpdate.rawContent
        vc.backActionHandler = { [self] in
            
            var title = ""
            var content = ""
            
            
            // 공백
            if vc.textView.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try! self.localRealm.write {
                    taskUpdate.title = title
                    taskUpdate.content = content
                    taskUpdate.rawContent = vc.textView.text
                    taskUpdate.date = self.dateCalculate(date: Date())
                    
                    self.tableView.reloadData()
                }
                
                try! self.localRealm.write {
                    self.localRealm.delete(taskUpdate)
                    tableView.reloadData()
                    self.viewWillAppear(false)
                }
            }
            
            // 수정했는데 같을 경우
            else if taskUpdate.rawContent == vc.textView.text {
                return
            }
            
            // 한줄
            else if !vc.textView.text!.contains("\n") {
                title = vc.textView.text!
                try! self.localRealm.write {
                    taskUpdate.title = title
                    taskUpdate.content = content
                    taskUpdate.rawContent = vc.textView.text
                    taskUpdate.date = self.dateCalculate(date: Date())
                    
                    self.tableView.reloadData()
                }
            }
            
            // 개행
            else {
                title = String(vc.textView.text!.split(separator: "\n").first!)
                content = String(vc.textView.text.dropFirst(title.count+1))
                try! self.localRealm.write {
                    taskUpdate.title = title
                    taskUpdate.content = content
                    taskUpdate.rawContent = vc.textView.text
                    taskUpdate.date = self.dateCalculate(date: Date())
                    
                    self.tableView.reloadData()
                }
            }
            
            
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


