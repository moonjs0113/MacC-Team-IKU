//
//  IKUCalendarView.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import UIKit

final class IKUCalendarView: UIView {
    // MARK: - Properties
    lazy private var calendarHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        let month = DateFormatter().shortMonthSymbols[Calendar.current.component(.month, from: Date.now) - 1].uppercased()
        let year = Calendar.current.component(.year, from: Date.now)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(month) \(year)"
        label.font = .nexonGothicFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .left
        view.addSubview(label)
        
        let imageView = UIImageView(image: UIImage(systemName: "chevron.forward",
                                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 3),
            imageView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: -1.5),
        ])
        
        view.addSubview(todayLabel)
        NSLayoutConstraint.activate([
            todayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            todayLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor),
        ])
        
        self.addSubview(view)
        //        DateFormatter().shortMonthSymbols
        return view
    }()
    
    lazy private var todayLabel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let todayCircle = UIView()
        todayCircle.translatesAutoresizingMaskIntoConstraints = false
        todayCircle.backgroundColor = .ikuBlue
        todayCircle.layer.cornerRadius = 5
        todayCircle.clipsToBounds = true
        view.addSubview(todayCircle)
        
        let todayLabel = UILabel()
        todayLabel.translatesAutoresizingMaskIntoConstraints = false
        todayLabel.text = "오늘"
        todayLabel.font = .nexonGothicFont(ofSize: 14)
        todayLabel.textColor = .black
        view.addSubview(todayLabel)
        
        NSLayoutConstraint.activate([
            todayLabel.topAnchor.constraint(equalTo: view.topAnchor),
            todayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            todayLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            todayCircle.widthAnchor.constraint(equalToConstant: 10),
            todayCircle.heightAnchor.constraint(equalToConstant: 10),
            todayCircle.centerYAnchor.constraint(equalTo: todayLabel.centerYAnchor),
            todayCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            todayCircle.trailingAnchor.constraint(equalTo: todayLabel.leadingAnchor, constant: -4),
        ])
        return view
    }()
    
    lazy private var weeklyTitleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        DateFormatter().shortWeekdaySymbols.forEach {
            let label = UILabel()
            label.text = $0.uppercased()
            label.font = .nexonGothicFont(ofSize: 13)
            label.textColor = .ikuCalendarWeeklyTitle
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        self.addSubview(stackView)
        return stackView
    }()
    
    lazy private var calendarView: CVCalendarView = {
        let view = CVCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.calendarDelegate = self
        view.calendarAppearanceDelegate = self
        self.addSubview(view)
        return view
    }()
    
    // MARK: - Methods
    private func setupView() {
        backgroundColor = .ikuBackground
    }
    
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            calendarHeaderView.topAnchor.constraint(equalTo: topAnchor),
            calendarHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            calendarHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            weeklyTitleStackView.topAnchor.constraint(equalTo: calendarHeaderView.bottomAnchor, constant: 10),
            weeklyTitleStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            weeklyTitleStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            calendarView.heightAnchor.constraint(equalToConstant: 300),
            calendarView.topAnchor.constraint(equalTo: weeklyTitleStackView.bottomAnchor, constant: 5),
            calendarView.bottomAnchor.constraint(equalTo: bottomAnchor),
            calendarView.leadingAnchor.constraint(equalTo: leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    public func commitCalendarViewUpdate() {
        calendarView.commitCalendarViewUpdate()
    }
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupLayoutConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
