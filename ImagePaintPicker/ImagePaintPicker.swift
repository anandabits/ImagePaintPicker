//
//  ImagePaintPicker.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/17/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct ImagePaintPicker: View {
    @State var imagePicker: Modal?
    @State var isPickingImage = true
    @State var imagePaint = CompensatingImagePaint(
        image: SizedImage(
            original: Image(systemName: "photo"),
            flipped: Image(systemName: "photo"),
            size: .unit
        ),
        sourceRect: .unit,
        scale: 1
    )

    @State var flipCompensation = true
    @State var sourceRectCompensation = true
    @State var scaleCompensation: CompensatingImagePaint.ScaleCompensation? = .horizontal
    @State var lockAspectRatio = true
    @State var allowOverflowOnBothAxes = true
    @State var additionalScale: CGFloat = 1

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            ViewBuilder.of {
                if isPickingImage {
                    imagePickerButton
                } else {
                    imagePaintPicker
                }
            }
        }
        .statusBar(hidden: true)
    }

    var imagePickerButton: some View {
        Button(action: {
            self.imagePicker = Modal(ImagePicker {
                self.imagePicker = nil
                if let image = $0 {
                    self.imagePaint.image = image
                    self.isPickingImage = false
                }
            }) { self.imagePicker = nil }
        }) {
            Text("Choose Image")
                .font(.headline)
                .foregroundColor(Color(white: 0.8))
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .foregroundColor(.init(.sRGB, white: 0.8, opacity: 1))
        }.presentation(imagePicker)
    }

    var imagePaintPicker: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(imagePaint.paint(
                    flipCompensation: flipCompensation,
                    sourceRectCompensation: sourceRectCompensation,
                    scaleCompensation: scaleCompensation,
                    additionalScale: additionalScale
                ))
                .edgesIgnoringSafeArea(.top)
                .padding(.bottom, 10)

            ImagePaintSelector(
                imagePaint: $imagePaint,
                lockAspectRatio: lockAspectRatio,
                allowOverflowOnBothAxes: allowOverflowOnBothAxes,
                flipCompensation: flipCompensation
            )
            .background(Color.gray)
            .cornerRadius(4)
            .border(Color(white: 0.2), width: 2, cornerRadius: 4)

            topControlRow
            additionalControlsAndReadouts
        }
    }

    var topControlRow: some View {
        HStack(spacing: 10) {
            Text("scale compensation")
            SegmentedControl(selection: $scaleCompensation) {
                Text("horizontal")
                    .tag(.horizontal as CompensatingImagePaint.ScaleCompensation?)
                Text("vertical")
                    .tag(.vertical as CompensatingImagePaint.ScaleCompensation?)
                Text("none")
                    .tag(nil as CompensatingImagePaint.ScaleCompensation?)
            }
            .background(Color(white: 0.2))
                .cornerRadius(12)
                .padding(.trailing, 50)

            Button(action: {
                withAnimation { self.isPickingImage = true }
            }) {
                Text("change image")
                    .padding(.all, 8)
                    .padding(.horizontal, 4)
            }
            .background(Color(white: 0.2))
                .cornerRadius(12)
        }
        .foregroundColor(Color(white: 0.8))
        .frame(width: 660)
        .padding(.vertical, 8)
    }

    var additionalControlsAndReadouts: some View {
        HStack(spacing: 20) {
            VStack {
                Toggle("flip compensation", isOn: $flipCompensation)//.onChange {
                    //self.imagePaint.image = $0 ? self.image.flippedImage : self.image.originalImage
                //})
                Toggle("source rect compensation", isOn: $sourceRectCompensation)
                Toggle("lock aspect ratio", isOn: $lockAspectRatio)
                Toggle("allow overflow on both axes", isOn: $allowOverflowOnBothAxes)
                HStack {
                    Text("additional scale")
                    Slider(value: $additionalScale, from: 0.000001, through: 4)
                }
            }
            .saturation(0)
                .frame(width: 300)
                .foregroundColor(Color(white: 0.8))
            makeReadout(
                title: Text("without compensation"),
                rect: imagePaint.sourceRect,
                scale: imagePaint.scale
            )
            makeReadout(
                title: Text("with compensation"),
                rect: imagePaint.verticallyCompensatedSourceRect,
                scale: imagePaint.horizontallyCompensatedScale
            )
        }
    }

    func makeReadout(title: Text, rect: CGRect, scale: CGFloat) -> some View {
        VStack {
            title
            Text("x: \(rect.origin.x)")
            Text("y: \(rect.origin.y)")
            Text("width: \(rect.size.width)")
            Text("height: \(rect.size.height)")
            Text("scale: \(scale * additionalScale)")
        }
        .foregroundColor(Color(white: 0.8))
        .padding(.vertical, 10)
    }
}
