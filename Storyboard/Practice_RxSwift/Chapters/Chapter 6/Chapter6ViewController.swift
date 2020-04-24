//
//  Chapter4ViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/2/20.
//  Copyright © 2020 pook. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class Chapter6ViewController: UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var miniImagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var viewTextTitle: UITextView!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    private var imageCache = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        images.subscribe(
            onNext: { [weak imagePreview] photos in
                guard let preview = imagePreview else {
                    return
                }
                preview.image = photos.collage(size: preview.frame.size)
            }
        ).disposed(by: self.bag)
        
        images.asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] photos in
                self?.updateUI(photos: photos)
            }).disposed(by: self.bag)
    }
    
    @IBAction func actionClear(_ sender: UIButton? = nil) {
        images.accept([])
        self.imageCache = []
    }
    
    @IBAction func actionSave(_ sender: UIButton) {
        guard let image = imagePreview.image else { return }
        Chapter4PhotoWriter.save(image)
            .asSingle()
            .subscribe(
                onSuccess: { [weak self] id in
                    self?.showMessage("Saved with id: \(id)")
                    self?.actionClear()
                },
                onError: { [weak self] error in
                    self?.showMessage("Error", description: error.localizedDescription)
                }
        ).disposed(by: self.bag)
    }
    
    @IBAction func actionAdd(_ sender: UIBarButtonItem) {
        //let newImages = self.images.value + [UIImage(named: "IMG_1907.jpg")!]
        //images.accept(newImages)
        let photoViewController = storyboard!.instantiateViewController(withIdentifier: "Chapter6PhotosCollectionViewController") as! Chapter6PhotosCollectionViewController
        navigationController!.pushViewController(photoViewController, animated: true)
        
        // WHY USE .share()?
        /*
         “The problem is that each time you call subscribe(...), this creates a new Observable for that subscription — and each copy is not guaranteed to be the same as the previous. And even when the Observable does produce the same sequence of elements, it’s overkill to produce those same duplicate elements for each subscription. There’s no point in doing that.”
         
         ...
         
         “ If all subscriptions to the shared sequence get disposed (e.g. there are no more subscribers), share will dispose the shared sequence as well. ”
         
         Excerpt From: By Marin Todorov. “RxSwift - Reactive Programming with Swift.” Apple Books.
         */
        let newPhotos = photoViewController.selectedPhotos.share()
        newPhotos
            .takeWhile { [weak self] image in
                let count = self?.imageCache.count ?? 0
                return count < 6
        }
        .filter { [weak self] newImage in
            let len = newImage.pngData()?.count ?? 0
            guard self?.imageCache.contains(len) == false else {
                print("Duplicated photo!")
                return false
            }
            self?.imageCache.append(len)
            return true
            /*
             newImage in
             return newImage.size.width > newImage.size.height*/
        }
        .subscribe(
            onNext: {[weak self] newImage in
                guard let images = self?.images else {return}
                images.accept(images.value + [newImage])
            },
            onCompleted: {
                print("completed photo selection")
        }
        ).disposed(by: self.bag)
        
        newPhotos
            .ignoreElements()
            .subscribe(
                onCompleted: { [weak self] in
                    self?.updateMiniPreview()
                }
        ).disposed(by: self.bag)
    }
    
    private func updateMiniPreview() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 40, height: 40))
            .withRenderingMode(.alwaysOriginal)
        
        self.miniImagePreview.image = icon
        // navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
    }
    
    private func updateUI(photos: [UIImage]) {
        self.buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        self.buttonClear.isEnabled = photos.count > 0
        //self.itemAdd.isEnabled = photos.count < 6
        self.viewTextTitle.text = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
        present(alert, animated: true, completion: nil)
    }
}
