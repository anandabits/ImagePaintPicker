//
//  CompensatingImagePaint.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/18/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct SizedImage {
    let image: Image
    let size: CGSize
}

struct SizedImagePaint {
    var image: SizedImage
    var sourceRect: CGRect = .unit
    var scale: CGFloat = 1
}

extension SizedImagePaint {
    func paint(
        additionalScale: CGFloat = 1
    ) -> ImagePaint {
        ImagePaint(
            image: image.image,
            sourceRect: sourceRect,
            scale: additionalScale * scale
        )
    }
}
