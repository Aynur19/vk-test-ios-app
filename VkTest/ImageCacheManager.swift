//
//  ImageCacheManager.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

import UIKit

import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let cacheSizeLimit: Int = 100 * 1024 * 1024
    private let fileManager = FileManager.default
    
    private init() {
        cache.totalCostLimit = cacheSizeLimit
    }
    
    // MARK: - Кеш в памяти
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        // Дополнительно сохраняем на диск
        saveImageToDisk(image, forKey: key)
    }
    
    // MARK: - Кеш на диске
    private func getDiskCacheURL(forKey key: String) -> URL? {
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key
        return cacheDir.appendingPathComponent(fileName)
    }
    
    private func saveImageToDisk(_ image: UIImage, forKey key: String) {
        guard let fileURL = getDiskCacheURL(forKey: key),
              let data = image.pngData() else { return }
        
        DispatchQueue.global(qos: .background).async {
            try? data.write(to: fileURL)
        }
    }
    
    private func loadImageFromDisk(forKey key: String) -> UIImage? {
        guard let fileURL = getDiskCacheURL(forKey: key),
              let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // Если нашли на диске — добавляем в кэш памяти
        cache.setObject(image, forKey: key as NSString)
        return image
    }
    
    // MARK: - Загрузка изображений
    
    func fetchImage(
        from urlStr: String,
        completion: @escaping (UIImage?) -> Void
    ) {
        // 1. Проверяем кеш в памяти
        if let cachedImage = getImage(forKey: urlStr) {
            return completion(cachedImage)
        }
        
        // 2. Проверяем диск
        if let diskImage = loadImageFromDisk(forKey: urlStr) {
            return completion(diskImage)
        }
        
        // 3. Загружаем из сети
        guard let url = URL(string: urlStr) else {
            return completion(nil)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let imageData = try? Data(contentsOf: url),
                  let image = UIImage(data: imageData)
            else {
                return completion(nil)
            }
            
            // Сохраняем в кэш памяти и на диск
            self.setImage(image, forKey: urlStr)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func fetchImages(
        from urlsStrings: [String],
        completion: @escaping ([UIImage]) -> Void
    ) {
        var loadedImages: [UIImage] = []
        let group = DispatchGroup()
        
        for urlStr in urlsStrings {
            // Проверяем сначала в памяти
            if let cachedImage = getImage(forKey: urlStr) {
                loadedImages.append(cachedImage)
                continue
            }
            
            // Проверяем на диске
            if let diskImage = loadImageFromDisk(forKey: urlStr) {
                loadedImages.append(diskImage)
                continue
            }
            
            // Если нет — грузим из сети
            guard let url = URL(string: urlStr) else {
                continue
            }

            group.enter()
            DispatchQueue.global(qos: .background).async {
                defer { group.leave() }
                
                guard let imageData = try? Data(contentsOf: url),
                      let image = UIImage(data: imageData)
                else { return }
                
                // Кешируем изображение
                self.setImage(image, forKey: urlStr)
                
                DispatchQueue.main.async {
                    loadedImages.append(image)
                }
            }
        }
        
        // Вызываем completion после загрузки всех изображений
        group.notify(queue: .main) {
            completion(loadedImages)
        }
    }
}
