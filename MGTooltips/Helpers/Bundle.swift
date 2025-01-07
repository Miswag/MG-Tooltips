//
//  Bundle.swift
//  MGTooltips
//
//  Created by Miswag on 07/01/2025.
//

import Foundation

// MARK: - Bundle Extension

/// Extension to fetch resources (like `Localizable.strings`) from this framework’s bundle.
extension Bundle {
    /// Locates the `MGTooltips` framework bundle using its identifier.
    static var frameworkBundle: Bundle {
        let bundleName = "mgtooltips.MGTooltips"
        guard let bundle = Bundle(identifier: bundleName) else {
            fatalError("Could not locate bundle for \(bundleName)")
        }
        return bundle
    }
}
