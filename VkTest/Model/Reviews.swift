//
//  Reviews.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

/// Модель отзывов.
struct Reviews: Decodable {
    /// Модели отзывов.
    let items: [Review]
    
    /// Общее количество отзывов.
    let count: Int
}
