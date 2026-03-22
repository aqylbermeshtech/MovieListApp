import UIKit

let imageCache = NSCache<NSString, UIImage>()

final class ImageLoader {

    static func load(url: URL, completion: @escaping (UIImage?) -> Void) {

        if let cached = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cached)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                // Dispatch the failure completion to the main thread
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            imageCache.setObject(image, forKey: url.absoluteString as NSString)

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
