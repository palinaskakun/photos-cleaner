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
                if viewModel.assets.isEmpty {
                    Text("No more photos/videos!")
                        .font(.title)
                } else {
                    SwipeDeckView()
                }
                
                Divider()
                
                Text("Marked for deletion: \(viewModel.toDeleteAssets.count)")
                    .padding()
                
                Button(action: {
                    viewModel.deleteMarkedAssets { success in
                        if success {
                            print("Deleted successfully")
                        } else {
                            print("Deletion error")
                        }
                    }
                }) {
                    Text("Delete Marked Items")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Photos Cleaner")
        }
    }
}
