//
//  MonthSelectionViewController.swift
//  SpaceWanderer
//
//  Created by 밀가루 on 11/15/24.
//

import UIKit

// MARK: - MonthSelectionViewControllerDelegate 프로토콜
protocol MonthSelectionViewControllerDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

class MonthSelectionViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    weak var delegate: MonthSelectionViewControllerDelegate?
    var selectedDate = Date()
    
    // 년도와 월 배열
    private var years: [Int] = []
    private var months: [Int] = Array(1...12)
    
    private let pickerView = UIPickerView()
    
    // 확인/취소 버튼
    private let confirmButton = UIButton()
    private let cancelButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SpecialColors.MainViewBackGroundColor
        setupPickerView()
        setupYears()
        setInitialDateSelection()
        setupTapGestureToDismiss()
        setupButtons()
    }
    
    private func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        
        view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupYears() {
        let currentYear = Calendar.current.component(.year, from: Date())
        years = Array(currentYear - 10...currentYear) // 예시로 10년 전부터 10년 후까지 표시
    }
    
    private func setInitialDateSelection() {
        let currentYear = Calendar.current.component(.year, from: selectedDate)
        let currentMonth = Calendar.current.component(.month, from: selectedDate)
        
        // 년도와 월을 초기 선택값으로 설정
        if let yearRow = years.firstIndex(of: currentYear) {
            pickerView.selectRow(yearRow, inComponent: 0, animated: false)
        }
        pickerView.selectRow(currentMonth - 1, inComponent: 1, animated: false)
    }
    
    private func setupButtons() {
        // 확인 버튼
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.backgroundColor = .green // 원하는 색상으로 변경
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        // 취소 버튼
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.backgroundColor = .red // 원하는 색상으로 변경
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        // 버튼 레이아웃 설정
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            confirmButton.widthAnchor.constraint(equalToConstant: 100),
            
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // 확인 버튼 액션
    @objc private func confirmAction() {
        dateChanged()
    }
    
    // 취소 버튼 액션
    @objc private func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func dateChanged() {
        // 선택된 년도와 월을 기반으로 날짜 생성
        let selectedYear = years[pickerView.selectedRow(inComponent: 0)]
        let selectedMonth = pickerView.selectedRow(inComponent: 1) + 1
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        let newDate = Calendar.current.date(from: components) ?? Date()
        
        delegate?.didSelectDate(newDate)
        dismiss(animated: true, completion: nil)
    }
    
    // 뒷 배경을 탭하면 바텀 시트를 내려가도록 설정
    private func setupTapGestureToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 년도, 월 두 개의 컴포넌트
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: // 년도
            return years.count
        case 1: // 월
            return months.count
        default:
            return 0
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: // 년도
            return "\(years[row])년"
        case 1: // 월
            return "\(months[row])월"
        default:
            return nil
        }
    }
    
    // MARK: - UIPickerViewDelegate (Attributed Titles for Row)
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title: String
        switch component {
        case 0: // 년도
            title = "\(years[row])년"
        case 1: // 월
            title = "\(months[row])월"
        default:
            return nil
        }
        
        // 글자 색상 변경
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: SpecialColors.WhiteColor // 원하는 색상으로 변경
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }
}
