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
    
    func calendar() -> Calendar? {
        return .current
//        let calendar: Calendar = .current//Calendar(identifier: .gregorian)
//        return calendar
    }
    
    func shouldShowWeekdaysOut() -> Bool { return true }
    
    func shouldAnimateResizing() -> Bool { return true }
    
    func didShowNextMonthView(_ date: Date) {
        let dateComponents = Calendar.current.dateComponents([.month,.year], from: date)
        guard let month = dateComponents.month,
              let year = dateComponents.year else {
            return
        }
        selectedDate = (month, year)
        
    }
    
    func didShowPreviousMonthView(_ date: Date) {
        let dateComponents = Calendar.current.dateComponents([.month,.year], from: date)
        guard let month = dateComponents.month,
              let year = dateComponents.year else {
            return
        }
        selectedDate = (month, year)
    }
    
    func shouldSelectDayView(dayView: DayView) -> Bool { return false }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool { return false }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        // Code
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
