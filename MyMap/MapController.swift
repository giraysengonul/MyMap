//
//  MapController.swift
//  MyMap
//
//  Created by hakkı can şengönül on 16.10.2022.
//

import UIKit

class MapController: UIViewController {
    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
}
// MARK: - Helpers
extension MapController{
    private func style(){
        view.backgroundColor = .brown
    }
    private func layout(){
        
    }
}
