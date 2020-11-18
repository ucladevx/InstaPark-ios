//
//  SearchViewController.swift
//  InstaPark
//
//  Created by Tony Jiang on 11/16/20.
//

import UIKit

class SearchViewController: UISearchController {
//    @IBOutlet weak var blankView: UIView!
    var resultSearchController: UISearchController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "LocationSearchTable") as! LocationSearchTableViewController
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
//        blankView.addSubview(resultSearchController!.searchBar)using
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
}
