//
//  Reviews.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

/// Модель отзывов.
struct ReviewsDto: Decodable {
    /// Модели отзывов.
    let items: [ReviewDto]
    
    /// Общее количество отзывов.
    let count: Int
}
