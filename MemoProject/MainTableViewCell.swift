//
//  MainTableViewCell.swift
//  MemoProject
//
//  Created by 신승아 on 2022/08/31.
//

import UIKit
import SnapKit

class MainTableViewCell: UITableViewCell {
    
    var memoTitle: UILabel = {
        let view = UILabel()
        return view
    }()
    
    var memoDate: UILabel = {
        let view = UILabel()
        return view
    }()
    
    var memoText: UILabel = {
        let view = UILabel()
        return view
    }()
    
    static var identifier: String {
        return "MainTableViewCell"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [memoTitle, memoDate, memoText].forEach {
            contentView.addSubview($0)
        }
        
        memoTitle.snp.makeConstraints { make in
            make.leadingMargin.equalTo(5)
            make.trailingMargin.equalTo(-5)
            make.top.equalTo(5)
            make.height.equalTo(25)
        }
        
        memoDate.snp.makeConstraints { make in
            make.leadingMargin.equalTo(5)
            make.bottom.equalTo(-2)
            make.height.equalTo(15)
            make.width.equalTo(100)
        }
        
        memoText.snp.makeConstraints { make in
            make.leadingMargin.equalTo(memoDate.snp.trailingMargin).offset(5)
            make.bottom.equalTo(-2)
            make.height.equalTo(15)
            make.trailingMargin.equalTo(-5)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
