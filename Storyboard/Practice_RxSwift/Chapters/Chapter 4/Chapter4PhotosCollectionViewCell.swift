//
//  Chapter4PhotosCollectionViewCell.swift
//  Practice_RxSwift
//
//  Created by pook on 4/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit

class Chapter4PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var representedAssetIdentifier: String!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func flash() {
        imageView.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.imageView.alpha = 1
        })
    }
}
