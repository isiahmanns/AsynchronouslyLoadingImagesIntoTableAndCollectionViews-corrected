/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The Image cache.
*/
import UIKit
import Foundation
public class ImageCache {
    
    public static let publicCache = ImageCache()
    var placeholderImage = UIImage(systemName: "rectangle")!
    private let cachedImages = NSCache<NSURL, UIImage>()

    typealias CellConfigurationBlock = (Item, UIImage?) -> Swift.Void
    private var loadingResponses = [NSURL: [(Item, CellConfigurationBlock)]]()
    
    public final func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    /// - Tag: cache
    // Returns the cached image if available, otherwise asynchronously loads and caches it.
    final func load(url: NSURL, item: Item, indexPath: IndexPath, completion: @escaping (Item, UIImage?) -> Swift.Void) {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        }
        // In case there are more than one requestor for the image, we append their completion block.
        if loadingResponses[url] != nil {
            loadingResponses[url]?.append((item, completion))
            print("lining up...", indexPath)
            return
        } else {
            loadingResponses[url] = [(item, completion)]
            print("headliner...", indexPath)
        }
        // Go fetch the image.
        ImageURLProtocol.urlSession().dataTask(with: url as URL) { (data, response, error) in
            // Check for the error, then data and try to create the image.
            guard let responseData = data, let image = UIImage(data: responseData),
                let blocks = self.loadingResponses[url], error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            // Cache the image.
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            // Iterate over each requestor for the image and pass it back.
            for block in blocks {
                DispatchQueue.main.async {
                    print("executing block", indexPath)
                    let (item, cellConfigBlock) = block
                    cellConfigBlock(item, image)
                }
            }

            // TODO: - Should clear loadingResponses here, in case cache evicts value we want a clean start
        }.resume()
    }
        
}
