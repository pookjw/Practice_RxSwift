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

class Chapter4ViewController: UIViewController {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var viewTextTitle: UITextView!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    
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
            .subscribe(onNext: { [weak self] photos in
                self?.updateUI(photos: photos)
            }).disposed(by: self.bag)
        
        showMessage("Test Alert", description: "Hi!")
    }
    
    @IBAction func actionClear(_ sender: UIButton? = nil) {
        images.accept([])
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
        let photoViewController = storyboard!.instantiateViewController(withIdentifier: "Chapter4PhotosCollectionViewController") as! Chapter4PhotosCollectionViewController
        navigationController!.pushViewController(photoViewController, animated: true)
        
        photoViewController.selectedPhotos.subscribe(
            onNext: {[weak self] newImage in
                guard let images = self?.images else {return}
                images.accept(images.value + [newImage])
            },
            onCompleted: {
                print("completed photo selection")
        }
        ).disposed(by: self.bag)
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
