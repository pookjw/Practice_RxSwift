//
//  UIViewController.swift
//  Practice_RxSwift
//
//  Created by pook on 4/6/20.
//  Copyright © 2020 pook. All rights reserved.
//

import Foundation
import RxSwift

extension UIViewController {
    func alert(title: String, text: String?) -> Completable {
        return Completable.create { [weak self] completable in
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Close", style: .default, handler: { _ in
                completable(.completed)
            }))
            self?.present(alertVC,animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
