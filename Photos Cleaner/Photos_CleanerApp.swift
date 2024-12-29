//
//  Photos_CleanerApp.swift
//  Photos Cleaner
//
//  Created by Palina Skakun on 12/28/24.
//

import SwiftUI
import Photos

@main
struct Photos_CleanerApp: App {
    @StateObject private var viewModel = PhotoLibraryViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
