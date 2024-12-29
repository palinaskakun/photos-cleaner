//
//  SingleAssetView.swift
//  Photos Cleaner
//
//  Created by Palina Skakun on 12/29/24.
//

import SwiftUI
import Photos

struct SingleAssetView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    let asset: PHAsset
    
    @State private var uiImage: UIImage? = nil
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        // The single "card"
        ZStack {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit() // preserve aspect ratio
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 10)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let swipeThreshold: CGFloat = 100
                                if value.translation.width < -swipeThreshold {
                                    // Left Swipe => mark for deletion
                                    viewModel.markAssetForDeletion(asset)
                                    goToNext()
                                } else if value.translation.width > swipeThreshold {
                                    // Right Swipe => skip/keep
                                    viewModel.skipAsset(asset)
                                    goToNext()
                                } else {
                                    // Snap back
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                            }
                    )
                    .animation(.spring(), value: dragOffset)
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            viewModel.image(for: asset) { image in
                DispatchQueue.main.async {
                    self.uiImage = image
                }
            }
        }
    }
    
    private func goToNext() {
        // Reset the drag offset
        withAnimation {
            dragOffset = .zero
        }
        
        // Advance to next index
        viewModel.goToNextAsset()
    }
}
