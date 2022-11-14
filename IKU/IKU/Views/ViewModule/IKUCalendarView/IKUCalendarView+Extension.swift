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
    
    func calendar() -> Calendar? { return Calendar(identifier: .gregorian) }
    
    func shouldShowWeekdaysOut() -> Bool { return true }
    
    func shouldAnimateResizing() -> Bool { return true }
    
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
