//
//  ImagePaintSelector.swift
//  Processing
//
//  Created by Matthew Johnson on 7/16/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct ImagePaintSelector {
    @Binding var imagePaint: CompensatingImagePaint
    var lockAspectRatio = true
    var allowOverflowOnBothAxes = true
    var flipCompensation = true

    @GestureState var dragState = DragState()
    struct DragState {
        var originalSourceRect = CGRect.zero
        var proposedSourceRect = CGRect.zero
    }
}

extension ImagePaintSelector: View {
    var sourceRect: CGRect { imagePaint.sourceRect }
    var image: Image {
        flipCompensation ? imagePaint.image.flipped : imagePaint.image.original
    }

    var body: some View {
        GeometryReader { proxy in
            // TODO: when function builders support let bindings
            // let controlSize = proxy.size / 3
            ZStack {
                Color.gray.cornerRadius(12)
                self.dimmedBackgroundImage(size: proxy.size / 3)
                self.selectionOverlayImage(size: proxy.size / 3)
                self.resizeHandle(size: proxy.size / 3)
            }.onAppear {
                self.imagePaint.scale = proxy.size.width / 3 / self.imagePaint.image.size.width
            }
        }.aspectRatio(imagePaint.image.size, contentMode: .fit)
    }

    func dimmedBackgroundImage(size: CGSize) -> some View {
        Rectangle()
            .size(size)
            .offset(size)
            .fill(image.paint(
                scale: size.width / imagePaint.image.size.width)
            )
            .overlay(Color.black.opacity(0.6))
    }

    func selectionOverlayImage(size: CGSize) -> some View {
        Rectangle()
            .size(size * sourceRect.size)
            .fill(imagePaint.paint(flipCompensation: flipCompensation))
            .shadow(color: Color.white.opacity(0.35), radius: 4, x: 0, y: 0)
            .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 0)
            .offset(size + CGSize(point: sourceRect.origin) * size)
            .gesture(makeDragGesture(size: size))
    }

    var handleSize: CGSize { CGSize(width: 30, height: 30) }
    func resizeHandle(size: CGSize) -> some View {
        Circle()
            .size(handleSize)
            .fill(Color(white: 0.5).opacity(0.5))
            .shadow(color: Color(white: 0.5).opacity(0.6), radius: 1)
            .offset(CGSize(point: sourceRect.origin) * size + size - handleSize / 2)
            .gesture(makeDragGesture(size: size, resize: true))
    }

    func makeDragGesture(size: CGSize, resize: Bool = false) -> some Gesture {
        DragGesture()
            .updating($dragState) { gestureState, dragState, _ in
                if dragState.originalSourceRect == .zero {
                    dragState.originalSourceRect = self.sourceRect
                }
                let unitTranslation = gestureState.translation / size

                var proposedSize = dragState.originalSourceRect.size
                if resize {
                    proposedSize -= unitTranslation
                    proposedSize.width.clamp(to: 0.000000001...1)
                    proposedSize.height.clamp(to: 0.000000001...1)

                    if self.lockAspectRatio {
                        proposedSize.width = proposedSize.height
                    }
                }

                dragState.proposedSourceRect = CGRect(
                    origin: dragState.originalSourceRect.origin + CGPoint(size: unitTranslation),
                    size: proposedSize
                )
                dragState.proposedSourceRect.clampOffset(
                    overflow: self.allowOverflowOnBothAxes
                                ? .both
                                : self.sourceRect.overflow ?? .either
                )
            }.onChanged { state in
                self.imagePaint.sourceRect = self.dragState.proposedSourceRect
            }
    }
}

private enum Overflow {
    case vertical
    case horizontal
    case either
    case both
}

private extension CGRect {
    var overflow: Overflow? {
        let horizontal = origin.x < 0 || maxX > 1
        let vertical = origin.y < 0 || maxY > 1
        return horizontal
            ? (vertical ? .both : .horizontal)
            : (vertical ? .vertical : nil)

    }

    /// Clamps the source rect to ensure it overlaps at least a small portion of the unit rect.
    /// - precondition: `self` is a unit rect
    mutating func clampOffset(overflow: Overflow = .either) {
        let maxOffset: CGFloat = 0.999999

        if origin.x > maxOffset {
            origin.x -= origin.x - maxOffset
        }
        if maxX < 0 {
            origin.x = -width + 1 - maxOffset
        }

        let allowHorizontalOverflow = overflow != .vertical
        if maxX > 1 && !allowHorizontalOverflow {
            origin.x -= maxX - 1
        }
        if origin.x < 0 && !allowHorizontalOverflow {
            origin.x = 0
        }

        if origin.y > maxOffset {
            origin.y -= origin.y - maxOffset
        }
        if maxY < 0 {
            origin.y = -height + 1 - maxOffset
        }

        let hasHorizontalOverflow = origin.x < 0 || maxX > 1
        let allowVerticalOverflow = overflow != .horizontal && (!hasHorizontalOverflow || overflow == .both)
        if maxY > 1 && !allowVerticalOverflow {
            origin.y -= maxY - 1
        }
        if origin.y < 0 && !allowVerticalOverflow {
            origin.y = 0
        }
    }
}
