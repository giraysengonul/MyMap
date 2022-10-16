//
//  SearchInputView.swift
//  MyMap
//
//  Created by hakkı can şengönül on 16.10.2022.
//

import UIKit
private let reuseIdentifier = "SearchCell"
protocol SearchInputViewDelegate: AnyObject {
    func animateCenterMapButton(expansionState: SearchInputView.ExpansionState,hideButton: Bool)
}
class SearchInputView: UIView {
    // MARK: - Properties
    weak var delegate: SearchInputViewDelegate?
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 5
        view.alpha = 0.8
        return view
    }()
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var expansionState: ExpansionState!
    enum ExpansionState {
        case NotExpanded
        case PartiallyExpanded
        case FullyExpanded
    }
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Helpers
extension SearchInputView{
    private func style(){
        backgroundColor = .white
        //indicatorView style
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicatorView)
        configureSearchBar()
        configureTableView()
        configureGestureRecognizers()
        expansionState = .NotExpanded
    }
    private func layout(){
        //indicatorView layout
        NSLayoutConstraint.activate([
            indicatorView.widthAnchor.constraint(equalToConstant: 40),
            indicatorView.heightAnchor.constraint(equalToConstant: 8),
            indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    private func configureSearchBar(){
        searchBar = UISearchBar()
        searchBar.placeholder = "search for a place or address"
        searchBar.barStyle = .black
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.delegate = self
        addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            searchBar.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8),
            trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 8)
        ])
    }
    func configureTableView() {
        tableView = UITableView()
        tableView.rowHeight = 72
        tableView.register(SearchCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 100),
            trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    private func configureGestureRecognizers(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
    }
    private func animateInputView(targetPosition: CGFloat,completion: @escaping(Bool)-> Void){
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.frame.origin.y = targetPosition
        }, completion: completion)
    }
}

// MARK: - UITableViewDelegate/DataSource
extension SearchInputView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchCell
        return cell
    }
}
// MARK: - Selectors
extension SearchInputView{
    @objc func handleSwipeGesture(_ sender: UISwipeGestureRecognizer){
        if sender.direction == .up {
            
            if expansionState == .NotExpanded {
                delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
                animateInputView(targetPosition: self.frame.origin.y - 250) { _ in
                    self.expansionState = .PartiallyExpanded
                }
            }
            if expansionState == .PartiallyExpanded {
                delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
                animateInputView(targetPosition: self.frame.origin.y - 450) { _ in
                    self.expansionState = .FullyExpanded
                }
            }
            
        }else{
            if expansionState == .FullyExpanded {
                self.searchBar.showsCancelButton = false
                self.searchBar.endEditing(true)
                animateInputView(targetPosition: self.frame.origin.y + 450) { _ in
                    self.delegate?.animateCenterMapButton(expansionState: self.expansionState,hideButton: false)
                    self.expansionState = .PartiallyExpanded
                }
            }
            if expansionState == .PartiallyExpanded {
                self.delegate?.animateCenterMapButton(expansionState: self.expansionState,hideButton: false)
                animateInputView(targetPosition: self.frame.origin.y + 250) { _ in
                    self.expansionState = .NotExpanded
                }
            }
        }
    }
}
// MARK: - UISearchBarDelegate
extension SearchInputView: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if expansionState == .NotExpanded{
            self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
            animateInputView(targetPosition: self.frame.origin.y - 750) { _ in
                self.expansionState = .FullyExpanded
            }
        }
        if expansionState == .PartiallyExpanded{
            self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: true)
            animateInputView(targetPosition: self.frame.origin.y - 450) { _ in
                self.expansionState = .FullyExpanded
            }
        }
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        animateInputView(targetPosition: self.frame.origin.y + 450) { _ in
            self.delegate?.animateCenterMapButton(expansionState: self.expansionState, hideButton: false)
            self.expansionState = .PartiallyExpanded
        }
    }
}
