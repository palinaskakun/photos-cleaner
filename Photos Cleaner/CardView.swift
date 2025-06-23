//
//  CardView.swift
//  Photos Cleaner
//
//  Adds video playback support
//

import SwiftUI
import Photos
import AVKit          // ← NEW

struct CardView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    let asset: PHAsset
    
    // For still-image thumbnails (photos *or* video poster frame)
    @State private var uiImage: UIImage? = nil
    
    // For video playback
    @State private var player: AVPlayer? = nil
    
    var body: some View {
        ZStack {
            if asset.mediaType == .video {
                // Show video when player is ready; fall back to the thumbnail while loading
                if let player {
                    VideoPlayer(player: player)
                        .scaledToFit()
                        .onAppear { player.play() }            // auto-play only while on-screen
                        .onDisappear { player.pause() }
                } else {
                    thumbnailView
                }
            } else {
                // Plain photo
                thumbnailView
            }
        }
        .onAppear { loadAssetOrPlayer() }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private var thumbnailView: some View {
        if let image = uiImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Color.gray
        }
    }
    
    private func loadAssetOrPlayer() {
        if asset.mediaType == .video {
            // 1) Always fetch a thumbnail first so the card has something to show immediately
            loadAssetThumbnail()
            
            viewModel.playerItem(for: asset) { item in
                        if let item {
                            DispatchQueue.main.async {
                                self.player = AVPlayer(playerItem: item)
                            }
                        }
                    }
                } else {
                    loadAssetThumbnail()
                }
            }
    
    private func loadAssetThumbnail() {
        viewModel.image(for: asset) { image in
            self.uiImage = image    // keeps exactly the same behaviour as before
        }
    }
}
