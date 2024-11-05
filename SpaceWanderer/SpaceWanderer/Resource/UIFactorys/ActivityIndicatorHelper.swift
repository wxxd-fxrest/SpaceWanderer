//
//  ActivityIndicatorHelper.swift
//  BubblyToDo
//
//  Created by 밀가루 on 9/16/24.
//

import UIKit
import SnapKit

class ActivityIndicatorHelper: UIView {
    var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubviews(activityIndicator)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = .green
        
        activityIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
