//
//  SearchCell.swift
//  MyMap
//
//  Created by hakkı can şengönül on 16.10.2022.
//

import UIKit
class SearchCell: UITableViewCell {
    // MARK: - Properties
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Helpers
extension SearchCell{
    private func setup(){
        
    }
}
