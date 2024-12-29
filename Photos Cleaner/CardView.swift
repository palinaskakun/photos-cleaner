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
                    // Instead of .scaledToFill(), we use .scaledToFit()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)  // optional: black letterbox
            } else {
                Color.gray
            }
        }
        .onAppear {
            loadAsset()
        }
    }
    
    private func loadAsset() {
        viewModel.image(for: asset) { image in
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }
    }
}
