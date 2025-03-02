//
//  Review.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

/// Модель отзыва.
struct Review: Decodable {
    /// Текст отзыва.
    let text: String
    
    /// Время создания отзыва.
    let created: String
}
