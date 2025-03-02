//
//  ReviewsViewModel.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }
    
    deinit {
        print("deinit ReviewsViewModel")
    }
}

// MARK: - Internal
extension ReviewsViewModel {
    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            reviewsProvider.getReviews(
                offset: state.offset,
                completion: { [weak self] result in
                    self?.gotReviews(result)
                }
            )
        }
    }
    
    func getReviewsCount() -> Int {
        state.items.count
    }
}

// MARK: - Private
private extension ReviewsViewModel {
    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(ReviewsDto.self, from: data)
            state.items += reviews.items.map { makeReviewItem($0) }
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            var item = state.items.first(where: { $0.id == id })
        else {
            return
        }
        
//        item.maxLines = .zero
//        state.items[index] = item
//        onStateChange?(state)
    }
}

// MARK: - Items
private extension ReviewsViewModel {
    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: ReviewDto) -> ReviewItem {
        let avatar = getAvatar(urlStr: review.avatarUrlStr)
        let username = "\(review.firstName) \(review.lastName)".attributed(font: .username)
        let rating = ratingRenderer.ratingImage(review.rating)
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        
        let item = ReviewItem(
            avatar: avatar,
            username: username,
            rating: rating,
            photos: [],
            reviewText: reviewText,
            created: created,
            onTapShowMore: { [weak self] id in  // избавляемся от retain cycle, захватывая слабую ссылку
                self?.showMoreReview(with: id)
            }
        )
     
        return item
    }
    
    
    private func getAvatar(urlStr: String?) -> UIImage {
        if let urlStr {
            return UIImage(named: "Images/avatar")!
        }
        
        return UIImage(named: "Images/avatar")!
    }
}

// MARK: - UITableViewDataSource
extension ReviewsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ReviewsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
}
