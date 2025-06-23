//
//  SwipeDeckView.swift
//  Photos Cleaner
//
//  Enlarged card height so the VideoPlayer (or image) gets more vertical space.
//  Height now grows up to a 16 : 9 ratio (portrait‑leaning) but never exceeds 75 % of
//  the available screen height. Adjust the `maxHeightFraction` or the 16/9 ratio to
//  taste.
//
//  Originally created by Palina Skakun on 12/28/24.
//  Last modified on 06/17/25.
//

import SwiftUI
import Photos

struct SwipeDeckView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel

    @State private var dragOffset: CGSize = .zero

    /// Horizontal padding around the card (both sides)
    private let horizontalInset: CGFloat = 16
    /// Maximum fraction of the screen height the card may occupy
    private let maxHeightFraction: CGFloat = 0.75

    var body: some View {
        GeometryReader { proxy in
            // Card takes full width (minus insets)
            let cardWidth = proxy.size.width - horizontalInset * 2

            // Try to give the card a 16:9 *portrait*‑leaning ratio (≈1.78 × width).
            // If that’s taller than 75 % of the screen, cap it so it doesn’t hide the footer UI.
            let proposedHeight = cardWidth * 16 / 9
            let maxHeight      = proxy.size.height * maxHeightFraction
            let cardHeight     = min(proposedHeight, maxHeight)

            ZStack {
                // Bottom‑most asset at index 0, top‑most is last
                ForEach(viewModel.assets, id: \ .localIdentifier) { asset in
                    let isTop = (asset == viewModel.assets.last)

                    CardView(asset: asset)
                        .frame(width: cardWidth, height: cardHeight)
                        .offset(x: isTop ? dragOffset.width  : 0,
                                y: isTop ? dragOffset.height : 0)
                        .rotationEffect(isTop ? .degrees(Double(dragOffset.width / 10)) : .zero)
                        .zIndex(isTop ? 1 : 0)
                        .gesture(
                            // Only the top card responds to drag gestures
                            isTop ? DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    handleDragEnd(value, for: asset)
                                }
                            : nil
                        )
                        .animation(.spring(), value: dragOffset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // centre the deck
        }
    }

    // MARK: - Gesture handling

    private func handleDragEnd(_ value: DragGesture.Value, for asset: PHAsset) {
        let swipeThreshold: CGFloat = 100
        if value.translation.width < -swipeThreshold {
            // Left swipe → delete
            viewModel.markAssetForDeletion(asset)
            removeTopCard(asset)
        } else if value.translation.width > swipeThreshold {
            // Right swipe → keep / skip
            viewModel.skipAsset(asset)
            removeTopCard(asset)
        } else {
            // Snap back if drag is too small
            withAnimation { dragOffset = .zero }
        }
    }

    // MARK: - Deck management

    private func removeTopCard(_ asset: PHAsset) {
        viewModel.removeAsset(asset)

        withAnimation { dragOffset = .zero } // reset offset for next card

        // Always keep up to 5 items ready if more remain
        viewModel.fillDeckIfNeeded()
    }
}
