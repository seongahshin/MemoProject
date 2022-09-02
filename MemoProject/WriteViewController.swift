//
//  WriteViewController.swift
//  MemoProject
//
//  Created by 신승아 on 2022/08/31.
//

import UIKit
import SnapKit
import RealmSwift

class WriteViewController: UIViewController, UITextViewDelegate {
    
    let localRealm = try! Realm()
    
    var tasks: Results<MemoModel>!
    
    
    var textView: UITextView = {
        let view = UITextView()
        return view
    }()
    
    
    @objc func rightbarButtonItemClicked() {
        print(#function)
        let result = textView.text.split(separator: "\n", maxSplits: 2)
        
        let task = MemoModel(title: "\(result[0])", content: "\(result[1])", date: Date())
        try! localRealm.write {
            localRealm.add(task)
            print(task)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(rightbarButtonItemClicked))
        configureUI()
        textView.delegate = self
    }
    
    func configureUI() {
        [textView].forEach {
            view.addSubview($0)
        }
        
        textView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(0)
        }
    }
    
    
}
