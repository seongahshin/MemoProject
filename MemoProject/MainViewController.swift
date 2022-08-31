//
//  ViewController.swift
//  MemoProject
//
//  Created by 신승아 on 2022/08/31.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var tableView: UITableView = {

        let view = UITableView(frame: CGRect.zero, style: .insetGrouped)
        view.backgroundColor = .lightGray
        view.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier)
        
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
        
    }
    
    func configureUI() {

        [tableView].forEach {
            view.addSubview($0)
        }

        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
    }

}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("고정된 메모", comment: "고정된 메모")
        case 1:
            sectionName = NSLocalizedString("메모", comment: "메모")
        default:
            sectionName = ""
        }
        return sectionName
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier) as! MainTableViewCell
        cell.backgroundColor = .green
        return cell
    }
    
}

