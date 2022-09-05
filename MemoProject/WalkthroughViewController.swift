//
//  WalkthroughViewController.swift
//  MemoProject
//
//  Created by 신승아 on 2022/09/05.
//

import UIKit

import SnapKit

class WalkthroughViewController: UIViewController {
    
    
    var box: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "DarkMode")
        view.layer.cornerRadius = 20
        return view
    }()
    
    var button: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        view.backgroundColor = .systemOrange
        view.setTitle("확인", for: .normal)
        view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        view.setTitleColor(UIColor.white, for: .normal)
        view.layer.cornerRadius = 10
        return view
    }()
    
    var boxText: UILabel = {
        let view = UILabel()
        view.text = """
        처음 오셨군요!
        환영합니다:)
        
        당신만의 메모를 작성하고 관리해보세요!
        """
        view.numberOfLines = 0
        view.textColor = UIColor(named: "TextColor")
        view.font = UIFont.boldSystemFont(ofSize: 15)
        return view
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(named: "TextColor")!.withAlphaComponent(0.3)
//        self.view.backgroundColor = .blue
        configureUI()
    }
    
    func configureUI() {
        [box, button,boxText].forEach {
            view.addSubview($0)
        }
        
        box.addSubview(button)
        box.addSubview(boxText)
        
        box.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(200)
        }
        
        button.snp.makeConstraints { make in
            make.leadingMargin.equalTo(10)
            make.trailingMargin.equalTo(-10)
            make.bottomMargin.equalTo(-10)
            make.height.equalTo(35)
            
        }
        
        boxText.snp.makeConstraints { make in
            make.leadingMargin.equalTo(20)
            make.trailingMargin.equalTo(-10)
            make.topMargin.equalTo(10)
            make.bottomMargin.equalTo(button.snp.topMargin).inset(-10)
        }
    }
    
    @objc func buttonClicked() {
        UserDefaults.standard.set("No",forKey: "first")
        dismiss(animated: true)
    }
    
}
