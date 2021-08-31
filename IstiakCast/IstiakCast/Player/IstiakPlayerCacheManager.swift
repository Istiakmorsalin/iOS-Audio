//
//  IstiakPlayerCacheManager.swift
//  Istiak cast
//

import UIKit

class IstiakPlayerCacheManager {

    public static let shared = IstiakPlayerCacheManager()
    
    private lazy var fileManager = FileManager.default
    private var cacheDirectoryParent: URL? {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    var cacheDirectory: URL? {
        guard let cacheDirectoryParent = cacheDirectoryParent else { return nil }
        
        //check if the folder called ClipCache was created in Cache
        let cacheDirectoryPath = cacheDirectoryParent.appendingPathComponent(Constants.ClipCache.path)
        if fileManager.fileExists(atPath: cacheDirectoryPath.path) {
            return cacheDirectoryPath
        } else { // create the folder ClipCache
            do {
                let pathToCreate = cacheDirectoryParent.path + "/" + Constants.ClipCache.path
                try fileManager.createDirectory(atPath: pathToCreate, withIntermediateDirectories: true, attributes: [:])
                return cacheDirectoryPath
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
    
    // Array to store the active request urls, an url will be removed when finished.
    private var activeDownloadURLS = [URL]()
    
    func cacheAudio(_ urlString: String) {
        
        guard let url = URL(string: urlString), let cacheDirectory = cacheDirectory else { return }
        let destination = cacheDirectory.appendingPathComponent(url.lastPathComponent + Constants.ClipCache.fileExtension)
        
        // Guard for file not already existing on disk
        guard !fileManager.fileExists(atPath: destination.path) else { return }
        
        // Guard for url is not already being actively downloaded
        guard !activeDownloadURLS.contains(url) else { return }
        
        // Download the audio file
        APIManager.shared.downloadFile(withURL: url, toDestination: destination, progressBlock: { (progress) in
            
        }) { [weak self] (result) in
            
            // Remove the url from the array, if it exists.
            if let index = self?.activeDownloadURLS.firstIndex(of: url) {
                 self?.activeDownloadURLS.remove(at: index)
            }
            
            switch result {
            case .success:
                debugPrint("[Download finished] - ", url)
            case .failure(let error):
                debugPrint("[Download failed]\n - \(error)")
            }
            
        }
        
        // Append the url to the array, in order to make sure that we won't request a download for it again.
        activeDownloadURLS.append(url)
        
    }
    
    func getCacheUrl(_ clipUrl: URL) -> URL? {
        guard let cacheDirectory = cacheDirectory else { return nil }
        let pathToClip = cacheDirectory.appendingPathComponent(clipUrl.lastPathComponent + Constants.ClipCache.fileExtension)
        guard fileManager.fileExists(atPath: pathToClip.path) else { return nil }
        return pathToClip
    }
    
    
    /// will clean the cache by all deleting files
    func clearCache() {
        guard
            let cacheDirectory = cacheDirectory
            else {
            return
        }
        
        // Delete clip cache folder
        do {
        let fileNames = try fileManager.contentsOfDirectory(atPath: cacheDirectory.path)
            for fileName in fileNames {
                let filePath = cacheDirectory.path + "/" + fileName
                try fileManager.removeItem(atPath: filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
        // Delete temporary download folder
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
        } catch {
           //catch the error somehow
        }
        
    }
    
    
}
