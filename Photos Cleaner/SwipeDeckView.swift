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
    
    // Track the drag offset of the top (single) card
    @State private var dragOffset: CGSize = .zero
    
    // For consistent sizing
    private let cardWidth: CGFloat = 300
    private let cardHeight: CGFloat = 400
    
    var body: some View {
        ZStack {
            if let topAsset = viewModel.assets.last {
                CardView(asset: topAsset)
                    .frame(width: cardWidth, height: cardHeight)
                    .offset(x: dragOffset.width, y: dragOffset.height)
                    .rotationEffect(.degrees(Double(dragOffset.width / 10)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let swipeThreshold: CGFloat = 100
                                if value.translation.width < -swipeThreshold {
                                    // Left swipe => delete
                                    viewModel.markAssetForDeletion(topAsset)
                                    handleSwipe(topAsset)
                                } else if value.translation.width > swipeThreshold {
                                    // Right swipe => keep/skip
                                    viewModel.skipAsset(topAsset)
                                    handleSwipe(topAsset)
                                } else {
                                    // Not enough drag => snap back
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .animation(.spring(), value: dragOffset)
            } else {
                // If there's no top asset (assets.isEmpty), you can show a fallback view
                Text("No more photos/videos!")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func handleSwipe(_ asset: PHAsset) {
        // Remove from our current deck
        viewModel.removeAsset(asset)
        
        // Reset the drag offset
        withAnimation {
            dragOffset = .zero
        }
        
        // Refill the deck if there are more assets
        viewModel.fillDeckIfNeeded()
    }
}
