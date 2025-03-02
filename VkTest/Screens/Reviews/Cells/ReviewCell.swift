//
//  ReviewCell.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

import UIKit

// MARK: - Typealia
fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout

// MARK: - Cell
final class ReviewCell: UITableViewCell {
    fileprivate var config: Config?
    
    fileprivate let avatarImageView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    
    fileprivate var photos = [UIImageView]()
    
    private let vStackView = UIStackView()
    private let hStackView = UIStackView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        
        avatarImageView.frame = layout.avatarFrame
        usernameLabel.frame = layout.usernameLabelFrame
        ratingImageView.frame = layout.ratingFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        
    }
}

// MARK: - Private
private extension ReviewCell {
    func setupCell() {
        setupAvatarImageView()
        setupUsernameLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupPhotosViews()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.contentMode = UIView.ContentMode.scaleAspectFit
        avatarImageView.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
        avatarImageView.clipsToBounds = true
    }
    
    func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
    }
    
    private func setupPhotosViews() {
        for _ in 0..<ReviewCellLayout.maxPhotoCount {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = ReviewCellLayout.photoCornerRadius
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.backgroundColor = .lightGray // Заглушка
            imageView.isHidden = true // Скрываем, пока нет изображений
            addSubview(imageView)
            photos.append(imageView)
        }
    }
}

// MARK: - Config
/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    
    let avatar: String
    
    /// Имя пользователя.
    let username: NSAttributedString
    
    let rating: UIImage
    
    let photosUrls: [String]
    let photos: [UIImage] = []
    
    /// Текст отзыва.
    let reviewText: NSAttributedString
    
    /// Время создания отзыва.
    let created: NSAttributedString
    
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    
    let onDidLoadPhotos: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()
    
    func toggleTextExpander() {
        layout.maxLines = (layout.maxLines == 3 ? 0 : 3)
    }
}

// MARK: - TableCellConfig
extension ReviewCellConfig: TableCellConfig {
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        
        cell.avatarImageView.image =  UIImage(named: "Images/avatar")!
        cell.usernameLabel.attributedText = username
        cell.ratingImageView.image = rating
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = layout.maxLines
        cell.createdLabel.attributedText = created
        cell.showMoreButton.addAction(UIAction { _ in
            onTapShowMore(id)
        }, for: .touchUpInside)
        cell.config = self
        
        ImageCacheManager.shared.fetchImage(from: avatar) { image in
            guard let image else { return }
                
            DispatchQueue.main.async {
                cell.avatarImageView.image = image
            }
        }
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Private
private extension ReviewCellConfig {
    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
}


// MARK: - Layout
/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    // MARK: - Размеры
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    fileprivate static var maxPhotoCount = 5
    fileprivate var maxLines = 3
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = ReviewCellConfig.showMoreText.size()

    // MARK: - Фреймы
    private(set) var avatarFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var photosFrames = [CGRect](repeating: CGRect.zero, count: maxPhotoCount)
    

    // MARK: - Отступы
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right

        var maxY = insets.top
        var maxX = insets.left
        var showShowMoreButton = false

        calculateAvatarImageLayout(config: config, width: width, maxX: &maxX)
        calculateUsernameTextLayout(config: config, width: width, maxX: maxX, maxY: &maxY)
        calculateRatingImageLayout(config: config, width: width, maxX: maxX, maxY: &maxY)
        calculatePhotosImageLayout(config: config, width: width, maxX: maxX, maxY: &maxY)
        calculateReviewTextLayout(config: config, width: width, maxX: maxX, maxY: &maxY, showShowMoreButton: &showShowMoreButton)
        calculateCreatedTextLayout(config: config, width: width, maxX: maxX, maxY: &maxY)

        return maxY + insets.bottom
    }
    
    private func calculateAvatarImageLayout(
        config: Config,
        width: CGFloat,
        maxX: inout CGFloat
    ) {
        avatarFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: ReviewCellLayout.avatarSize
        )
        
        maxX = avatarFrame.maxX + avatarToUsernameSpacing
    }
    
    private func calculateUsernameTextLayout(
        config: Config,
        width: CGFloat,
        maxX: CGFloat,
        maxY: inout CGFloat
    ) {
        let currentTextHeight = config.username.font()?.lineHeight ?? .zero
        usernameLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.username.boundingRect(width: width, height: currentTextHeight).size
        )
        maxY = usernameLabelFrame.maxY + usernameToRatingSpacing
    }
    
    private func calculateRatingImageLayout(
        config: Config,
        width: CGFloat,
        maxX: CGFloat,
        maxY: inout CGFloat
    ) {
        ratingFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.rating.size
        )
        maxY = ratingFrame.maxY + (config.photos.isEmpty ? ratingToTextSpacing : ratingToPhotosSpacing)
    }
    
    private func calculatePhotosImageLayout(
        config: Config,
        width: CGFloat,
        maxX: CGFloat,
        maxY: inout CGFloat
    ) {
        var localMaxX = maxX
        
        for photoIdx in config.photos.indices {
            photosFrames[photoIdx] = CGRect(
                origin: CGPoint(x: localMaxX, y: maxY),
                size: config.rating.size
            )
            
            localMaxX = photosFrames[photoIdx].maxX + photosSpacing
            maxY = photosFrames[photoIdx].maxY + photosToTextSpacing
        }
    }
    
    private func calculateReviewTextLayout(
        config: Config,
        width: CGFloat,
        maxX: CGFloat,
        maxY: inout CGFloat,
        showShowMoreButton: inout Bool
    ) {
        let maxWidth = width - (ReviewCellLayout.avatarSize.width + avatarToUsernameSpacing)
        
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(maxLines)
            
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: config.reviewText.boundingRect(width: maxWidth, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: Self.showMoreButtonSize
            )
            
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
    }
    
    private func calculateCreatedTextLayout(
        config: Config,
        width: CGFloat,
        maxX: CGFloat,
        maxY: inout CGFloat
    ) {
        createdLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.created.boundingRect(width: width).size
        )
        
        maxY = createdLabelFrame.maxY
    }
}
