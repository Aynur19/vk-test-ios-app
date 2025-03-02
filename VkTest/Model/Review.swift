//
//  Review.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

/// Модель отзыва.
struct ReviewDto {
    /// URL аватара пользователя
    let avatarUrlStr: String?
    
    let photosUrls: [String]
    
    /// Имя  пользователя
    let firstName: String
    
    /// Фамилия  пользователя
    let lastName: String
    
    /// Текст отзыва.
    let text: String
    
    /// Рейтинг, оставленный пользователем
    let rating: Int
    
    /// Время создания отзыва.
    let created: String
}

extension ReviewDto: Decodable {
    enum CodingKeys: String, CodingKey {
        case avatarUrlStr = "avatar_url"
        case photosUrls = "photos_urls"
        case firstName = "first_name"
        case lastName = "last_name"
        case text = "text"
        case rating = "rating"
        case created = "created"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.avatarUrlStr = try container.decodeIfPresent(String.self, forKey: .avatarUrlStr)
        self.photosUrls = try container.decode([String].self, forKey: .photosUrls)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.text = try container.decode(String.self, forKey: .text)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.created = try container.decode(String.self, forKey: .created)
    }
}
