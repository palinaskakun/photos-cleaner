//
//  CardView.swift
//  Photos Cleaner
//
//  Created by Palina Skakun on 12/28/24.
//

import SwiftUI
import Photos

struct CardView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    let asset: PHAsset
    
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()    // <-- Key: preserve aspect ratio
                    // no .clipped() so we don't cut off landscape photos
            } else {
                Color.gray
            }
        }
        .onAppear {
            loadAsset()
        }
    }
    
    private func loadAsset() {
        // The image manager returns something sized ~300x300, but .scaledToFit will keep aspect ratio.
        viewModel.image(for: asset) { image in
            self.uiImage = image
        }
    }
}
