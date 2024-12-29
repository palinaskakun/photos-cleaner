//
//  SwipeDeckView.swift
//  Photos Cleaner
//
//  Created by Palina Skakun on 12/28/24.
//

import SwiftUI
import Photos

struct SwipeDeckView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    
    @State private var dragOffset: CGSize = .zero
    
    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 400
    
    var body: some View {
        ZStack {
            // The bottom-most item is at index 0, top-most is the last in the array
            ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                let isTop = (asset == viewModel.assets.last)
                
                CardView(asset: asset)
                    .frame(width: cardWidth, height: cardHeight)
                    .offset(x: isTop ? dragOffset.width : 0,
                            y: isTop ? dragOffset.height : 0)
                    .rotationEffect(isTop ? .degrees(Double(dragOffset.width / 10)) : .zero)
                    .zIndex(isTop ? 1 : 0)
                    .gesture(
                        // Only top card is draggable
                        isTop ? DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let swipeThreshold: CGFloat = 100
                                if value.translation.width < -swipeThreshold {
                                    // Left swipe => delete
                                    viewModel.markAssetForDeletion(asset)
                                    removeTopCard(asset)
                                } else if value.translation.width > swipeThreshold {
                                    // Right swipe => keep/skip
                                    viewModel.skipAsset(asset)
                                    removeTopCard(asset)
                                } else {
                                    // Not enough drag => snap back
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                            }
                        : nil
                    )
                    .animation(.spring(), value: dragOffset)
            }
        }
    }
    
    private func removeTopCard(_ asset: PHAsset) {
        viewModel.removeAsset(asset)
        
        // Reset offset
        withAnimation {
            dragOffset = .zero
        }
        
        // Always fill the deck up to 5 items if more remain
        viewModel.fillDeckIfNeeded()
    }
}
