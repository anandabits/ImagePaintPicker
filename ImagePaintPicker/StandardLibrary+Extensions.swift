//
//  StandardLibrary+Extensions.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/17/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

extension Numeric where Self: Comparable {
    func clamped(to: ClosedRange<Self>) -> Self {
        guard self > to.lowerBound else { return to.lowerBound }
        guard self < to.upperBound else { return to.upperBound }
        return self
    }
    
    mutating func clamp(to: ClosedRange<Self>) {
        if self < to.lowerBound {
            self = to.lowerBound
        } else if self > to.upperBound {
            self = to.upperBound
        }
    }
}
