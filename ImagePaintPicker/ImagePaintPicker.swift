//
//  ImagePaintPicker.swift
//  ImagePaintPicker
//
//  Created by Matthew Johnson on 7/17/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct ImagePaintPicker: View {
    @State var isPickingImage = true
    @State var isPresentingImagePicker = false
    @State var imagePaint = SizedImagePaint(
        image: SizedImage(
            image: Image(systemName: "photo"),
            size: .unit
        ),
        sourceRect: .unit,
        scale: 1
    )

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
        .sheet(isPresented: $isPresentingImagePicker) {
            ImagePicker {
                self.isPresentingImagePicker = false
                if let image = $0 {
                    self.imagePaint.image = image
                    self.isPickingImage = false
                }
            }
        }
        .statusBar(hidden: true)
    }

    var imagePickerButton: some View {
        Button(action: { self.isPresentingImagePicker = true }) {
            Text("Choose Image")
                .font(.headline)
                .foregroundColor(Color(white: 0.8))
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .foregroundColor(.init(.sRGB, white: 0.8, opacity: 1))
        }
    }

    var imagePaintPicker: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(imagePaint.paint(
                    additionalScale: additionalScale
                ))
                .edgesIgnoringSafeArea(.top)
                .padding(.bottom, 10)

            ImagePaintSelector(
                imagePaint: $imagePaint,
                lockAspectRatio: lockAspectRatio,
                allowOverflowOnBothAxes: allowOverflowOnBothAxes
            )
            .background(Color.gray)
            .cornerRadius(4)
            .border(Color(white: 0.2), width: 2)

            Button(action: {
                withAnimation { self.isPickingImage = true }
            }) {
                Text("change image")
                    .padding(.all, 8)
                    .padding(.horizontal, 4)
            }
            .background(Color(white: 0.2))
            .cornerRadius(12)
            .foregroundColor(Color(white: 0.8))
            .padding(.vertical, 8)

            additionalControlsAndReadouts
        }
    }


    var additionalControlsAndReadouts: some View {
        HStack(spacing: 40) {
            VStack {
                Toggle("lock aspect ratio", isOn: $lockAspectRatio)
                Toggle("allow overflow on both axes", isOn: $allowOverflowOnBothAxes)
                HStack {
                    Text("additional scale")
                    Slider(value: $additionalScale, in: 0.000001...4, label: { Text("additional scale") })
                }
            }
            // uncommenting this line gives the desired visual appearance but breaks interactivity
            //.saturation(0)
            .frame(width: 300)
            .foregroundColor(Color(white: 0.8))

            VStack {
                Text("source rect")
                Text("x: \(imagePaint.sourceRect.origin.x)")
                Text("y: \(imagePaint.sourceRect.origin.y)")
                Text("width: \(imagePaint.sourceRect.size.width)")
                Text("height: \(imagePaint.sourceRect.size.height)")
                Text("scale: \(imagePaint.scale * additionalScale)")
            }
            .foregroundColor(Color(white: 0.8))
            .padding(.vertical, 10)
        }
    }
}
