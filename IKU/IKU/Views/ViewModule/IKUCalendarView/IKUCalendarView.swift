//
//  IKUCalendarView.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import UIKit

class IKUCalendarView: UIView {
    // MARK: - Properties
    var calendarView: CVCalendarView = CVCalendarView()
    
    // MARK: - Methods
    func setupView() {
        backgroundColor = .ikuBackground
    }
    
    func setupCVCalendar() {
        calendarView.calendarDelegate = self
        calendarView.calendarAppearanceDelegate = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: topAnchor),
            calendarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupCVCalendar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
