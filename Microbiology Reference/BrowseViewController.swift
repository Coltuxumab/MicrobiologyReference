//
//  BrowseViewController.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/12/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController {
    
    @IBOutlet weak var browseTable: UITableView!
    
    var allData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        navigationItem.title = "Browse"
        let attributes = [
            //NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 30)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        // Allow table cell to get bigger to fit multi-line content
        browseTable.estimatedRowHeight = 44
        browseTable.estimatedRowHeight = UITableViewAutomaticDimension
        browseTable.rowHeight = UITableViewAutomaticDimension
        
        // Get data
        DataManager.getAllBugs(){ (data) -> () in
            self.allData = data
            self.browseTable.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension BrowseViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = allData[indexPath.row]
        
        // Get table image by name
        let imageName:String = DataManager.getTableImage(name: allData[indexPath.row])
        
        // Add image
        let image : UIImage = UIImage(named: imageName)!
        cell.imageView?.image = image
        
        return cell
        
    }
    
}

extension BrowseViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Make sure that tapping cell doesn't make it turn grey
        browseTable.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
        
        // Push to DiseaseViewController
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "detailsView") as! DetailsViewController
        
        nextViewController.detailsName = allData[indexPath.row]
        
        
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
}
