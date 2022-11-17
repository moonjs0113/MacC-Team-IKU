//
//  SelectWhichEyeView.swift
//  IKU
//
//  Created by KimJS on 2022/11/18.
//

import SwiftUI

enum Eyes {
    case left
    case right
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
            .foregroundColor(isSelected ? .black : .white.opacity(0.8))
            .background(isSelected ? background : nil)
            .onTapGesture {
                select()
            }
            .disabled(isSelected)
    }
    private var background: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(.white)
            .padding(.horizontal, -4)
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
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.gray))
        .frame(idealHeight:16)
        .environment(\.selectedSegmentTag, $selection)
    }
}

struct SelectWhichEyeView: View {
    
//    @Binding var isLeftEyeSelected: Bool
    @Binding var mode: Eyes
    var body: some View {
        VStack {
            CustomPicker(selection: $mode) {
                Image(systemName: "chevron.left").segmentedControlItemTag(Eyes.left)
                Image(systemName: "chevron.right").segmentedControlItemTag(Eyes.right)
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
