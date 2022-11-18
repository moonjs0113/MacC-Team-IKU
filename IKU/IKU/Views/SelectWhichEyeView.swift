//
//  SelectWhichEyeView.swift
//  IKU
//
//  Created by KimJS on 2022/11/18.
//

import SwiftUI

enum Eyes: String {
    case left = "왼쪽 눈"
    case right = "오른쪽 눈"
}

private struct SelectedSegmentTagKey: EnvironmentKey {
    static var defaultValue: Any?
}

private extension EnvironmentValues {
    var selectedSegmentTag: Any? {
        get { self[SelectedSegmentTagKey.self] }
        set { self[SelectedSegmentTagKey.self] = newValue }
    }
}

public extension View {
    func segmentedControlItemTag<SelectionValue: Hashable>(_ tag: SelectionValue) -> some View {
        return SegmentedControlItemContainer(tag: tag,
                                             content: self)
    }
}

private struct SegmentedControlItemContainer<SelectionValue, Content>: View
where SelectionValue: Hashable, Content: View {
    @Environment(\.selectedSegmentTag) var selectedSegmentTag
    let tag: SelectionValue
    let content: Content
    @ViewBuilder var body: some View {
        content
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .background(isSelected ? background : nil)
            .onTapGesture {
                select()
            }
            .disabled(isSelected)
    }
    
    // 선택된 그림의 흰 색 배경
    private var background: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(.white)
            .shadow(radius: 10, x:-4)
    }
    private var isSelected: Bool {
        let selectedTag = (selectedSegmentTag as? Binding<SelectionValue>)?.wrappedValue
        return tag == selectedTag
    }
    private func select() {
        if let binding = selectedSegmentTag as? Binding<SelectionValue> {
            binding.wrappedValue = tag
        }
    }
}

public struct CustomPicker<SelectionValue, Content> : View where SelectionValue : Hashable, Content : View {
    @Binding private var selection: SelectionValue
    private let content: Content
    public init(selection: Binding<SelectionValue>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    public var body: some View {
        HStack(spacing: 0) {
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.ikuEyeSelectBackground))
        .environment(\.selectedSegmentTag, $selection)
    }
}

struct SelectWhichEyeView: View {
    
    //MARK: - Properties
    @Binding var mode: Eyes
    
    var body: some View {
        VStack {
            CustomPicker(selection: $mode) {
                Image("lefteye").segmentedControlItemTag(Eyes.left)
                Image("righteye").segmentedControlItemTag(Eyes.right)
            }
            .frame(width: 300)
        }
        .frame(width:400, height: 400, alignment: .center)
    }
}

struct SelectWhichEyeView_Previews: PreviewProvider {
    static var previews: some View {
        SelectWhichEyeView(mode: .constant(Eyes.left))
    }
}
