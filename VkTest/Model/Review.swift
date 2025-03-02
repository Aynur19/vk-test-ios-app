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
        case avatarUrlStr = "avatarUrl"
        case firstName = "first_name"
        case lastName = "last_name"
        case text = "text"
        case rating = "rating"
        case created = "created"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.avatarUrlStr = try container.decodeIfPresent(String.self, forKey: .avatarUrlStr)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.text = try container.decode(String.self, forKey: .text)
        self.rating = try container.decode(Int.self, forKey: .rating)
        self.created = try container.decode(String.self, forKey: .created)
    }
}

//import Foundation
//
//struct ReviewModel: Identifiable {
//    let id: UUID
//    let avatarUrlStr: URL?
//    let username: String
//    let text: String
//    let rating: Int
//    let created: String
//    
//    init(
//        id: UUID = UUID(),
//        avatarUrlStr: String?,
//        username: String,
//        text: String,
//        rating: Int,
//        created: String
//    ) {
//        self.id = id
//        self.avatarUrlStr = avatarUrlStr
//        self.username = username
//        self.text = text
//        self.rating = rating
//        self.created = created
//    }
//}
