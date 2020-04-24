//
//  Chapter4PhotoWriter.swift
//  Practice_RxSwift
//
//  Created by pook on 4/3/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation
import UIKit
import Photos
import RxSwift

class Chapter4PhotoWriter {
    enum Errors: Error {
        case couldNotSavePhoto
    }
    
    static func save(_ image: UIImage) -> Observable<String> {
        return Observable.create { observer in
            var savedAssetId: String?
            PHPhotoLibrary.shared().performChanges(
                {
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    savedAssetId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success, let id = savedAssetId {
                        observer.onNext(id)
                        observer.onCompleted()
                    } else {
                        observer.onError(error ?? Errors.couldNotSavePhoto)
                    }
                }
            }
            )
            return Disposables.create()
        }
    }
}
