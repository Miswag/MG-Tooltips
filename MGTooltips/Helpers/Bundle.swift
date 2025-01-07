//
//  Bundle.swift
//  MGTooltips
//
//  Created by Miswag on 07/01/2025.
//

import Foundation

// Helper function to fetch localized strings from the framework bundle
extension Bundle {
    static var frameworkBundle: Bundle {
        let bundleName = "mgtooltips.MGTooltips"
        guard let bundle = Bundle(identifier: bundleName) else {
            fatalError("Could not locate bundle for \(bundleName)")
        }

        return bundle
    }
}


// Extension to localize a string
public extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, bundle: .frameworkBundle, comment: comment)
    }
}


