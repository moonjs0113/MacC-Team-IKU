//
//  IKUCalendarView+Extension.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import UIKit

extension IKUCalendarView: CVCalendarViewDelegate, CVCalendarMenuViewDelegate {
    func presentationMode() -> CalendarMode { return .monthView }
    
    func firstWeekday() -> Weekday { return .sunday }
    
    func calendar() -> Calendar? { return .current }
    
    func shouldShowWeekdaysOut() -> Bool { return true }
    
    func shouldAnimateResizing() -> Bool { return true }
    
    func didShowNextMonthView(_ date: Date) {
        scrollCalendar(date)
    }
    
    func didShowPreviousMonthView(_ date: Date) {
        scrollCalendar(date)
    }
    
    func shouldSelectDayView(dayView: DayView) -> Bool { return false }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool { return false }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        guard let persistenceManager = try? PersistenceManager(),
              let resultData = try? persistenceManager.fetchVideo(.at(day: dayView.date.getDate())) else {
            return
        }
        if !resultData.isEmpty {
            guard let didSelectDayView = didSelectDayView else { return }
            didSelectDayView(resultData)
        }
    }
    
    func shouldShowCustomSingleSelection() -> Bool { return false }
}


extension IKUCalendarView: CVCalendarViewAppearanceDelegate {
    func spaceBetweenDayViews() -> CGFloat { return 2.5 }
    
    func spaceBetweenWeekViews() -> CGFloat { return 2.0 }
    
    func dayLabelFont(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIFont {
        .nexonGothicFont(ofSize: 13)
    }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        switch (weekDay, status) {
        case (.sunday, .in), (.saturday, .in): return .ikuCalendarWeekend
        case (_, .out): return .white
        default: return .black
        }
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        return .white
    }
}

extension IKUCalendarView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        (component == 0) ? Month.allCases.count : 101
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        (component == 0) ? Month.allCases[row].pickerTitle : String(displayYears[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedDate.month = row + 1
        } else {
            selectedDate.year = displayYears[row]
        }
    }
}
