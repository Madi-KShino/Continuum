//
//  ViewControllerExtension.swift
//  Continuum
//
//  Created by Madison Kaori Shino on 7/11/19.
//  Copyright © 2019 Madi S. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentSimpleAlertWith(title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        present(alertController, animated: true)
    }
}

