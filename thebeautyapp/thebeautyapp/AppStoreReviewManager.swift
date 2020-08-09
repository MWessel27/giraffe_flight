//
//  AppStoreReviewManager.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 8/9/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import StoreKit

enum AppStoreReviewManager {
    static func requestReviewIfAppropriate() {
        SKStoreReviewController.requestReview()
    }
}
