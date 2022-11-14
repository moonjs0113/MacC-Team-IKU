//
//  IKUCalendarView.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import UIKit

final class IKUCalendarView: UIView {
    // MARK: - Properties
    var isMonthYearSelecting: Bool = false
    var selectedDate: (month: Int, year: Int) = (Calendar.current.component(.month, from: Date.now),
                                                 Calendar.current.component(.year, from: Date.now)) {
        didSet {
            fetchMonthYearLabel()
        }
    }
    
    var displayYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date.now)
        let min = 1972
        let max = currentYear + 50
        return Array(min...max)
    }

    // UI Properties
    lazy private var calendarHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(todayLabel)
        view.addSubview(selectMonthYearView)
        
        NSLayoutConstraint.activate([
            selectMonthYearView.topAnchor.constraint(equalTo: view.topAnchor),
            selectMonthYearView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectMonthYearView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            todayLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            todayLabel.centerYAnchor.constraint(equalTo: selectMonthYearView.centerYAnchor),
        ])
        
        self.addSubview(view)
        return view
    }()
    
    lazy private var selectMonthYearView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        

        view.addSubview(monthYearLabel)
        let imageView = UIImageView(image: UIImage(systemName: "chevron.forward",
                                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            monthYearLabel.topAnchor.constraint(equalTo: view.topAnchor),
            monthYearLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            monthYearLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: monthYearLabel.trailingAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: monthYearLabel.bottomAnchor, constant: -1.5),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapMonthYearLabel(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        return view
    }()
    
    lazy private var monthYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let month = DateFormatter().shortMonthSymbols[selectedDate.month - 1].uppercased()
        label.text = "\(month) \(selectedDate.year)"
        label.font = .nexonGothicFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .left
        
        return label
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
    
    lazy private var datePicker: UIPickerView = {
        let view = UIPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.isHidden = true
        view.delegate = self
        view.dataSource = self
        view.selectRow(selectedDate.month - 1, inComponent: 0, animated: false)
        view.selectRow(50, inComponent: 1, animated: false)
        self.addSubview(view)
        return view
    }()
    
    lazy var calendarView: CVCalendarView = {
        let view = CVCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.calendarDelegate = self
        view.calendarAppearanceDelegate = self
        view.toggleCurrentDayView()
        self.addSubview(view)
        return view
    }(
    
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
            
            datePicker.topAnchor.constraint(equalTo: weeklyTitleStackView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    private func fetchMonthYearLabel() {
        let month = DateFormatter().shortMonthSymbols[selectedDate.month - 1].uppercased()
        monthYearLabel.text = "\(month) \(selectedDate.year)"
    }
    
    private func fetchCVCalendar() {
        let dateComponents = DateComponents(calendar: Calendar(identifier: .gregorian),
                                            year: selectedDate.year, month: selectedDate.month)
        guard let date = dateComponents.date else {
            return
        }
        calendarView.toggleViewWithDate(date)
    }
    
    public func commitCalendarViewUpdate() {
        calendarView.commitCalendarViewUpdate()
    }
    
    public func scrollCalendar(_ date: Date) {
        let dateComponents = Calendar.current.dateComponents([.month,.year], from: date)
        guard let month = dateComponents.month,
              let year = dateComponents.year else {
            return
        }
        selectedDate = (month, year)
    }
    
    // MARK: - Objc Methods
    @objc func tapMonthYearLabel(_ sender: UITapGestureRecognizer) {
        isMonthYearSelecting = datePicker.isHidden
        datePicker.isHidden = !datePicker.isHidden
        
        datePicker.selectRow(selectedDate.month - 1, inComponent: 0, animated: false)
        datePicker.selectRow(selectedDate.year - 2022 + 50, inComponent: 1, animated: false)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            if let iamgeView = sender.view?.subviews.last as? UIImageView {
                let rotationAngle = ((self?.isMonthYearSelecting ?? false) ? 1 : 0) * CGFloat(Double.pi) / 2
                iamgeView.transform = CGAffineTransform(rotationAngle: rotationAngle)
            }
        }
        fetchCVCalendar()
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
