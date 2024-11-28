//
//  CalendarView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

import UIKit

class CalendarView: UIView {
    
    // MARK: - UI Elements
    let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let totalStepsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    let planetLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
        return collectionView
    }()
    
    lazy var planetCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsPerRow: CGFloat = 4 // 한 줄에 4개
        let spacing: CGFloat = 10   // 셀 간 간격
        let totalSpacing = spacing * (itemsPerRow - 1) + 32 // 양쪽 여백(16 + 16)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        layout.scrollDirection = .vertical // 세로 방향으로 설정

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
        collectionView.isScrollEnabled = false // 스크롤 비활성화
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(monthLabel)
        addSubview(totalStepsLabel)
        addSubview(calendarCollectionView)
        addSubview(planetCollectionView)
        addSubview(planetLabel)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        planetCollectionView.translatesAutoresizingMaskIntoConstraints = false
        planetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            totalStepsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 14),
            totalStepsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
            calendarCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            calendarCollectionView.heightAnchor.constraint(equalToConstant: 300),
            
            planetLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 10),
            planetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            planetCollectionView.topAnchor.constraint(equalTo: planetLabel.bottomAnchor, constant: 20),
            planetCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            planetCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            planetCollectionView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func updateMonthLabel(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        monthLabel.text = formatter.string(from: date)
    }
    
    func updateTotalStepsLabel(with totalSteps: Int) {
        totalStepsLabel.text = "총 걸음 수: \(totalSteps)"
    }
    
    func updatePlanetLabel(with planetName: String) {
        planetLabel.text = planetName
    }
}
