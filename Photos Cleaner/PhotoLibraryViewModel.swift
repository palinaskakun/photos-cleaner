//
//  PhotoLibraryViewModel.swift
//  Photos Cleaner
//
//  Created by Palina Skakun on 12/28/24.
//

import Foundation
import SwiftUI
import Photos

class PhotoLibraryViewModel: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var toDeleteAssets: [PHAsset] = []
    
    /// A set of asset identifiers that the user has chosen to keep/skip.
    /// We persist this so if they skip an item, it won’t show again across app launches.
    private var skipSet: Set<String> = []
    
    private let imageManager = PHCachingImageManager()
    
    private var allAssets: PHFetchResult<PHAsset>?
    private var currentIndex: Int = 0
    
    // We'll show up to `deckSize` items at a time in-memory
    private let deckSize = 5
    
    // For storing skipSet in UserDefaults
    private let skipSetKey = "SkipSetKey"
    
    init() {
        // Load skipSet from UserDefaults
        if let data = UserDefaults.standard.data(forKey: skipSetKey),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            skipSet = decoded
        }
        
        requestPhotoLibraryAccess()
    }
    
    private func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                self.fetchAssets()
            default:
                print("Photo library access not granted.")
            }
        }
    }
    
    private func fetchAssets() {
        let options = PHFetchOptions()
        // Sort by creation date descending (most recent first)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let result = PHAsset.fetchAssets(with: options)
        
        DispatchQueue.main.async {
            self.allAssets = result
            self.fillDeckIfNeeded()
        }
    }
    
    /// Refill the deck until we reach `deckSize` or run out of unskipped/unmarked assets.
    func fillDeckIfNeeded() {
        guard let allAssets = allAssets else { return }
        
        while assets.count < deckSize && currentIndex < allAssets.count {
            let asset = allAssets.object(at: currentIndex)
            currentIndex += 1
            
            let alreadySkipped = skipSet.contains(asset.localIdentifier)
            let alreadyMarked = toDeleteAssets.contains(where: {
                $0.localIdentifier == asset.localIdentifier
            })
            
            // Only add if it's not in skipSet and not in toDeleteAssets
            if !alreadySkipped && !alreadyMarked {
                assets.append(asset)
            }
        }
    }
    
    /// Save the skipSet to UserDefaults after each update
    private func persistSkipSet() {
        if let data = try? JSONEncoder().encode(skipSet) {
            UserDefaults.standard.set(data, forKey: skipSetKey)
        }
    }
    
    // MARK: - Image Loading
    
    func image(
        for asset: PHAsset,
        targetSize: CGSize = CGSize(width: 300, height: 300),
        completion: @escaping (UIImage?) -> Void
    ) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill, // We'll let SwiftUI show it with aspect fit
            options: options
        ) { image, _ in
            completion(image)
        }
    }
    
    // MARK: - Swiping & Deletion
    
    func markAssetForDeletion(_ asset: PHAsset) {
        DispatchQueue.main.async {
            self.toDeleteAssets.append(asset)
        }
    }
    
    /// User wants to keep this asset; skip it from ever showing again
    func skipAsset(_ asset: PHAsset) {
        DispatchQueue.main.async {
            self.skipSet.insert(asset.localIdentifier)
            self.persistSkipSet()  // Persist to disk so it won't appear next time
        }
    }
    
    /// Remove the asset from the in-memory deck
    func removeAsset(_ asset: PHAsset) {
        DispatchQueue.main.async {
            self.assets.removeAll { $0.localIdentifier == asset.localIdentifier }
        }
    }
    
    /// Actually delete everything we’ve marked for deletion
    func deleteMarkedAssets(completion: @escaping (Bool) -> Void) {
        let assetsToDelete = self.toDeleteAssets
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { success, error in
            if success {
                DispatchQueue.main.async {
                    // Clear them from local memory so they don't re-show
                    self.toDeleteAssets.removeAll()
                }
            }
            completion(success)
        }
    }
}
