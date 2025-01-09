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
    /// Locates the `MGTooltips` framework bundle dynamically based on integration method.
    static var frameworkBundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: MGTooltip.self)
        #endif
    }
}

