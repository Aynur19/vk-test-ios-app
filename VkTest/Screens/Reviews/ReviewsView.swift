//
//  ReviewsView.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

import UIKit

final class ReviewsView: UIView {
    let tableView = UITableView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    deinit {
        print("deinit ReviewsView")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let safeAreaInsets = safeAreaInsets
        let bounds = bounds.inset(by: safeAreaInsets)

        // Устанавливаем фреймы для таблицы и toolbar
        addSubview(reviewsCountLabel)
        
        reviewsCountLabel.frame = CGRect(x: bounds.minX, y: bounds.maxY - 44, width: bounds.width, height: 44)
        tableView.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: bounds.height - 44)
    }
    
    private lazy var reviewsCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.reviewCount
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    func updateReviewsCount(count: Int) {
        reviewsCountLabel.text = "\(count) отзывов"
    }
}

// MARK: - Private
private extension ReviewsView {
    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
    }

    func setupTableView() {
        addSubview(tableView)
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
    }
}
