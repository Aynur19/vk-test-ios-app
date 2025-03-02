//
//  ReviewsViewController.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

import UIKit

final class ReviewsViewController: UIViewController {
    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit ReviewsViewController")
        
        
        reviewsView.tableView.delegate = nil
        reviewsView.tableView.dataSource = nil
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//    }
}

// MARK: - Private
private extension ReviewsViewController {
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                reviewsView.tableView.reloadData()
                updateReviewsCount(count: viewModel.getReviewsCount())
            }
        }
        
        viewModel.onChangeCellHeight = { [weak self] index in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                reviewsView.tableView.reloadRows(
                    at: [IndexPath(row: index, section: 0)],
                    with: .none
                )
            }
        }
    }
    
    func updateReviewsCount(count: Int) {
        reviewsView.updateReviewsCount(count: count)
    }
}
