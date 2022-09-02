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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationItem.title = "0개의 메모"
        self.navigationController?.navigationBar.backgroundColor = .red
        self.navigationItem.titleView = searchBar
        
        configureUI()
        tableView.dataSource = self
        tableView.delegate = self
        
        writeButton.addTarget(self, action: #selector(writeButtonClicked), for: .touchUpInside)
        
        self.tasks = self.localRealm.objects(MemoModel.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    @objc func writeButtonClicked() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "WriteViewController") as? WriteViewController else { return }
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

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("메모", comment: "메모")
        default:
            sectionName = ""
        }
        return sectionName
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier) as! MainTableViewCell
        let row = tasks[indexPath.row]

        cell.backgroundColor = .green
        cell.memoTitle.text = row.title
        cell.memoDate.text = "\(row.date)"
        cell.memoText.text = "\(row.content)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .normal, title: "") { [self] action, view, completionHandler in
            completionHandler(true)
            try! self.localRealm.write {
                self.localRealm.delete(self.tasks[indexPath.row])
                tableView.reloadData()
            }
        }
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        let config = UISwipeActionsConfiguration(actions: [delete])
        return config
    }
    
}

