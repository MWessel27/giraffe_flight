//
//  UIViewSnapshot.swift
//  Flawless
//
//  Created by Mikalangelo Wessel on 5/24/20.
//  Copyright © 2020 giraffeflight. All rights reserved.
//

import UIKit

extension UIView  {
    // render the view within the view's bounds, then capture it as image
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image(actions: { rendererContext in
        layer.render(in: rendererContext.cgContext)
    })
  }
}
