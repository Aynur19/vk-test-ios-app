//
//  String+Ext.swift
//  VkTest
//
//  Created by Aynur Nasybullin on 02.03.2025.
//

import UIKit

extension String {
    /// Метод создаёт из строки атрибутированную с данным шрифтом `font` и цветом `color`.
    func attributed(
        font: UIFont = .systemFont(ofSize: UIFont.labelFontSize),
        color: UIColor? = nil
    ) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
        ]

        if let color {
            attributes[.foregroundColor] = color
        }

        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString
    }
}
