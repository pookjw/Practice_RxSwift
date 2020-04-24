//
//  Chapter4PhotosCollectionViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import Photos
import RxSwift

private let reuseIdentifier = "Cell"

class Chapter6PhotosCollectionViewController: UICollectionViewController {
    
    // MARK: Private Properties
    private let bag = DisposeBag()
    private lazy var photos = Chapter4PhotosCollectionViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos: Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    private lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(width: cellSize.width * UIScreen.main.scale, height: cellSize.height * UIScreen.main.scale)
    }()
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotoOptions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        
        let authorized = PHPhotoLibrary.authorized.share()
        
        authorized
            .skipWhile { $0 == false }
            .take(1)
            .subscribe(
                onNext: { [weak self] _ in
                    self?.photos = Chapter4PhotosCollectionViewController.loadPhotos()
                    DispatchQueue.main.async {
                        self?.collectionView?.reloadData()
                    }
                }
        ).disposed(by: self.bag)
        
        /*
         authorized
         .skipWhile { $0 == false }
         .take(1)
         
         is same to...
         
         authorized
         .skip(1)
         .filter { $0 == false }
         
         authorized
         .takeLast(1)
         .filter { $0 == false }
         
         authorized
         .distinctUntilChanged()
         .takeLast(1)
         .filter { $0 == false }
         */
        
        authorized
        .skip(1)
        .takeLast(1)
            .filter { $0 == false}
        .subscribe(
            onNext: { [weak self] _ in
                guard let errorMessage = self?.errorMessage else { return }
                DispatchQueue.main.async(execute: errorMessage)
        }
        ).disposed(by: self.bag)
        
        /*
         also same to...
         
         authorized
         .skip(1)
         .filter { $0 == false }
         
         authorized
         .takeLast(1)
         .filter { $0 == false }
         
         authorized
         .distinctUntilChanged()
         .takeLast(1)
         .filter { $0 == false }
         */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedPhotosSubject.onCompleted()
        super.viewWillDisappear(animated)
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Chapter6PhotosCollectionViewCell", for: indexPath) as! Chapter6PhotosCollectionViewCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        })
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? Chapter6PhotosCollectionViewCell {
            cell.flash()
        }
        
        imageManager.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { [weak self] image, info in
            guard let image = image, let info = info else { return }
            
            if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                self?.selectedPhotosSubject.onNext(image)
            }
        })
    }
    
    private func errorMessage() {
        alert(title: "No access to Camera Roll", text: "You can grant access to Combinestagram from the Settings app")
        .asObservable()
            .take(5.0, scheduler: MainScheduler.instance)
        .subscribe(
            onCompleted: { [weak self] in
                //self?.dismiss(animated: true, completion: nil)
                _ = self?.navigationController?.popViewController(animated: true)
        }
        ).disposed(by: self.bag)
    }
    
}
