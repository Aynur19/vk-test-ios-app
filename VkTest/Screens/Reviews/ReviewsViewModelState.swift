//
//  ReviewsViewModelState.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {
    var items = [ReviewCellConfig]()
    var limit = 20
    var offset = 0
    var shouldLoad = true
}
