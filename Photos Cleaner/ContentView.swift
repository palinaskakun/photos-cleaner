//
//  ContentView.swift
//  Photos Cleaner
//
//  Created by Palina Skakun on 12/28/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: PhotoLibraryViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // If we have a current asset, show it. Otherwise, "No more photos/videos!"
                if let asset = viewModel.currentAsset {
                    SingleAssetView(asset: asset)
                } else {
                    Text("No more photos/videos!")
                        .font(.title)
                }
                
                Divider()
                
                Text("Marked for deletion: \(viewModel.toDeleteAssets.count)")
                    .padding()
                
                Button("Delete Marked Items") {
                    viewModel.deleteMarkedAssets { success in
                        if success {
                            print("Deleted successfully")
                        } else {
                            print("Deletion error")
                        }
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(8)
            }
            .padding()
            .navigationTitle("Photos Cleaner")
        }
    }
}
