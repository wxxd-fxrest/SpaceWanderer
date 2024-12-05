//
//  CalendarView.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/29/24.
//

//import UIKit
//
//class CalendarView: UIView {
//    
//    // MARK: - UI Elements
//    let monthLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 18)
//        label.textColor = .white
//        label.isUserInteractionEnabled = true
//        return label
//    }()
//    
//    let totalStepsLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .white
//        return label
//    }()
//    
//    let planetLabel: UILabel = {
//        let label = UILabel()
//        label.font = .boldSystemFont(ofSize: 18)
//        label.textColor = .white
//        label.isUserInteractionEnabled = true
//        return label
//    }()
//    
//    lazy var calendarCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = 2
//        layout.minimumInteritemSpacing = 2
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
//        return collectionView
//    }()
//    
//    lazy var planetCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        let itemsPerRow: CGFloat = 4 // 한 줄에 4개
//        let spacing: CGFloat = 10   // 셀 간 간격
//        let totalSpacing = spacing * (itemsPerRow - 1) + 32 // 양쪽 여백(16 + 16)
//        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemsPerRow
//
//        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
//        layout.minimumInteritemSpacing = spacing
//        layout.minimumLineSpacing = spacing
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
//        layout.scrollDirection = .vertical // 세로 방향으로 설정
//
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        collectionView.backgroundColor = SpecialColors.MainViewBackGroundColor
//        collectionView.isScrollEnabled = false // 스크롤 비활성화
//        return collectionView
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupViews()
//    }
//    
//    private func setupViews() {
//        addSubview(monthLabel)
//        addSubview(totalStepsLabel)
//        addSubview(calendarCollectionView)
//        addSubview(planetCollectionView)
//        addSubview(planetLabel)
//        
//        monthLabel.translatesAutoresizingMaskIntoConstraints = false
//        totalStepsLabel.translatesAutoresizingMaskIntoConstraints = false
//        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        planetCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        planetLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            monthLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
//            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            
//            totalStepsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 14),
//            totalStepsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            
//            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 10),
//            calendarCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            calendarCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            calendarCollectionView.heightAnchor.constraint(equalToConstant: 300),
//            
//            planetLabel.topAnchor.constraint(equalTo: calendarCollectionView.bottomAnchor, constant: 10),
//            planetLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//
//            planetCollectionView.topAnchor.constraint(equalTo: planetLabel.bottomAnchor, constant: 20),
//            planetCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            planetCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            planetCollectionView.heightAnchor.constraint(equalToConstant: 200)
//        ])
//    }
//    
//    func updateMonthLabel(with date: Date) {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy년 MM월"
//        monthLabel.text = formatter.string(from: date)
//    }
//    
//    func updateTotalStepsLabel(with totalSteps: Int) {
//        totalStepsLabel.text = "총 걸음 수: \(totalSteps)"
//    }
//    
//    func updatePlanetLabel(with planetName: String) {
//        planetLabel.text = planetName
//    }
//}


import UIKit
import SnapKit
import Then

class CalendarView: UIView {
    // MARK: - UI Elements
    var monthLabel = UIFactory.makeLabel(text: "month", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .semiBold, size: 18, isScaled: true), textAlignment: .center)
    var totalStepsLabel = UIFactory.makeLabel(text: "total steps", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 16, isScaled: true), textAlignment: .center)
    var planetLabel = UIFactory.makeLabel(text: "planet", textColor: SpecialColors.WhiteColor, font: UIFont.pretendard(style: .regular, size: 18, isScaled: true), textAlignment: .center)

    lazy var calendarCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 2
            $0.minimumInteritemSpacing = 2
            
            let itemsPerRow: CGFloat = 7
            let totalSpacing = $0.minimumInteritemSpacing * (itemsPerRow - 1)
            let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemsPerRow
            $0.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    ).then {
        $0.backgroundColor = SpecialColors.MainViewBackGroundColor
        $0.isScrollEnabled = false
    }

    lazy var planetCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            let itemsPerRow: CGFloat = 4 // 한 줄에 4개
            let spacing: CGFloat = 10   // 셀 간 간격
            let totalSpacing = spacing * (itemsPerRow - 1) + 32 // 양쪽 여백(16 + 16)
            let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemsPerRow

            $0.itemSize = CGSize(width: itemWidth, height: itemWidth)
            $0.minimumInteritemSpacing = spacing
            $0.minimumLineSpacing = spacing
            $0.sectionInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            $0.scrollDirection = .vertical // 세로 방향
        }
    ).then {
        $0.backgroundColor = SpecialColors.MainViewBackGroundColor
        $0.isScrollEnabled = false // 스크롤 비활성화
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // calendarCollectionView 유동적 높이
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCalendarHeight()
    }

    private func updateCalendarHeight() {
        let contentHeight = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
        calendarCollectionView.snp.updateConstraints {
            $0.height.equalTo(contentHeight)
            $0.top.equalTo(monthLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
    }

    func reloadCalendar() {
        calendarCollectionView.reloadData()
        updateCalendarHeight()
    }
    
    private func setupViews() {
        monthLabel.isUserInteractionEnabled = true
        planetLabel.isUserInteractionEnabled = true

        addSubviews(monthLabel, totalStepsLabel, calendarCollectionView, planetCollectionView, planetLabel)

        monthLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(16)
        }
        
        totalStepsLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(14)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        planetLabel.snp.makeConstraints {
            $0.top.equalTo(calendarCollectionView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(16)
        }
        
        planetCollectionView.snp.makeConstraints {
            $0.top.equalTo(planetLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
        }
    }
    
    func updateMonthLabel(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        monthLabel.text = formatter.string(from: date)
    }
    
    func updateTotalStepsLabel(with totalSteps: Int) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal // 세자리마다 쉼표 추가
        if let formattedSteps = numberFormatter.string(from: NSNumber(value: totalSteps)) {
            totalStepsLabel.text = "총 걸음 수: \(formattedSteps)"
        } else {
            totalStepsLabel.text = "총 걸음 수: \(totalSteps)" // 포매팅 실패 시 기본 값
        }
    }
    
    func updatePlanetLabel(with planetName: String) {
        planetLabel.text = planetName
    }
}
