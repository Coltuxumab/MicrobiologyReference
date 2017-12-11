//
//  RelatedViewController.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/12/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import UIKit

class RelatedViewController: UITableViewController {

    @IBOutlet weak var relatedTable: UITableView!
    
    var passedName = "Default Name"
    
    var passedTerm = "Default Term"
    
    var matchBasis:Set<String> = ["Default"]
    
    var relatedEntities = [Related]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Sort
        relatedEntities = relatedEntities.sorted { $0.name < $1.name }
        
        // Set title
        navigationItem.title = passedName
        let attributes = [
            //NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 30)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        // Allow table cell to get bigger to fit multi-line content
        relatedTable.estimatedRowHeight = 44
        relatedTable.estimatedRowHeight = UITableViewAutomaticDimension
        relatedTable.rowHeight = UITableViewAutomaticDimension
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relatedEntities.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Related by: \(passedTerm)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = relatedEntities[indexPath.row].name
        cell.detailTextLabel?.text = relatedEntities[indexPath.row].match
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make sure that tapping cell doesn't make it turn grey
        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
        
        // Push to DiseaseViewController
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        
        nextViewController.detailsName = relatedEntities[indexPath.row].name
        nextViewController.searchTerms = passedTerm
        nextViewController.matchBasis = matchBasis
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }

}
