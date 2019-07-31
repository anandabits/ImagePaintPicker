//
//  SwiftUI+Extensions.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/17/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

extension View {
    func frame(size: CGSize, alignment: Alignment = .center) -> some View {
        frame(width: size.width, height: size.height, alignment: alignment)
    }
}

extension ViewBuilder {
    /// Used to enter a ViewBuilder context in an ad-hoc fashion to build a view.
    ///
    /// - note: This is especially useful when you want to choose a view based on a condition.
    static func of<V: View>(@ViewBuilder _ factory: () -> V) -> V {
        factory()
    }
}

extension Image {
    func paint(
        sourceRect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1),
        scale: CGFloat = 1
    ) -> ImagePaint {
        ImagePaint(image: self, sourceRect: sourceRect, scale: scale)
    }
}

extension Binding where Value: Equatable {
    func onChange(_ action: @escaping (Value) -> Void) -> Binding {
        Binding(
            get: { self.wrappedValue },
            set: {
                let oldValue = self.wrappedValue
                self.wrappedValue = $0
                let newValue = self.wrappedValue
                if newValue != oldValue {
                    action(newValue)
                }
            }
        )
    }
}
