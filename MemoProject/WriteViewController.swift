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

    var contextAll = ""
    var backActionHandler: (() -> ())?
    
    var textView: UITextView = {
        let view = UITextView()
        return view
    }()
    
    
    @objc func rightbarButtonItemClicked() {
        print(#function)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(rightbarButtonItemClicked))
        configureUI()
        textView.delegate = self
        textView.text = contextAll
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        backActionHandler?()
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
