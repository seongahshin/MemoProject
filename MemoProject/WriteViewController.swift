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
    
    @objc func rightsecondbarButtonItemClicked() {
        let shareText: String = "메모를 공유해보세요"
        var shareObject = [Any]()
        shareObject.append(textView.text!)
        
        let activityViewController = UIActivityViewController(activityItems : shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
       
        self.navigationItem.largeTitleDisplayMode = .always
        let doneButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(rightbarButtonItemClicked))
        let shareBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .done, target: self, action: #selector(rightsecondbarButtonItemClicked))
        navigationItem.rightBarButtonItems = [doneButtonItem, shareBarButtonItem]
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
            make.left.right.bottom.equalTo(0)
            make.top.equalToSuperview()
        }
    }
    
    
}
