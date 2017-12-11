//
//  DiseaseViewController.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/11/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import UIKit

class DetailsCell: UITableViewCell {
    
    
    @IBOutlet weak var cellLabel: UILabel!
    
    @IBOutlet weak var cellImage1: UIImageView!
    
    @IBOutlet weak var cellImage2: UIImageView!
    
    let tapRec = UITapGestureRecognizer() // WHY IS THIS HERE?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
}

class DetailsViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var detailsTable: UITableView!
    
    var detailsName:String = "Default Name"
    var matchBasis:Set<String> = ["none"]
    var searchTerms:String = "term"
    
    var detailsHeaders:[String] = []    // Final headers to be displayed
    var detailsItems:[[String]] = []    // Final data (rows) to be displayed
    
    struct AccessoryRelated{
        var term:String
        var related:[Related]
        var match:Set<String>
    }
    struct AccessoryWebView{
        var title:String
        var url:String
    }
    
    var accessoryRelated = [AccessoryRelated]()
    var accessoryWebView = [AccessoryWebView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set title
        navigationItem.title = detailsName
        let attributes = [
            //NSAttributedStringKey.foregroundColor : UIColor.red,
            NSAttributedStringKey.font : UIFont(name: "PingFangTC-Light", size: 30)!
        ]
        self.navigationController?.navigationBar.largeTitleTextAttributes = attributes
        
        // Set up overall background
        self.view.backgroundColor = DataManager.themeBackgroundColor
        detailsTable.backgroundColor = DataManager.themeBackgroundColor
        
        // Allow table cell to get bigger to fit multi-line content
        detailsTable.estimatedRowHeight = 44
        detailsTable.estimatedRowHeight = UITableViewAutomaticDimension
        detailsTable.rowHeight = UITableViewAutomaticDimension
        
        // Add poopover button to top right
        let popoverButton = UIBarButtonItem(image: UIImage(named: "barButtonItem_3lines"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(initiatePopover))
        popoverButton.tintColor = UIColor.black
        navigationItem.rightBarButtonItems = [popoverButton]
        
        // Get data
        DataManager.getSingleBug(bugName: detailsName){ (headers,data) -> () in
            self.detailsHeaders = headers
            self.detailsItems = data
            self.detailsTable.reloadData()
        }
        
    }

    
    // Handle initiation of popover
    @objc func initiatePopover(_ sender: AnyObject) {
        print("Requested popover")
        
        // get a reference to the view controller for the popover
        let popController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popoverController") as? PopoverTableViewController
         
         
        // set the presentation style
        popController?.modalPresentationStyle = UIModalPresentationStyle.popover
         
        // Set popover data (format as array: userfriendly,action)
        PopoverTableViewController.popoverOptions = ["Share/Save,share-save", "Suggest Change,suggest-change"]
         
        // set up the popover presentation controller
        popController?.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController?.popoverPresentationController?.delegate = self
        popController?.delegate = self
        popController?.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
         
        // present the popover
        self.present(popController!, animated: false, completion: nil)
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension DetailsViewController: PopoverTableViewDelegate{
    
    // Receive data from popover to determine which option was selected
    func sentPopoverData(option: String) {
        
        // Select correct action for chosen popover
        if option == "share-save" {
            print("Share/save popover action")
            //self.performSegue(withIdentifier: "suggestNewSegue", sender: self)
        } else if option == "suggest-change" {
            print("Suggest Change popover action")
            //self.performSegue(withIdentifier: "checkUpdatesSegue", sender: self)
            //self.checkDataUpdates()
        }
        
    }
}

extension DetailsViewController: UITableViewDataSource{
    
    // Table style
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = DataManager.themeMainColor
    }
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.clear
    }
    
    // Table functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailsItems[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return detailsHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "customDetailsCell") as! DetailsCell
        
        let itemText = detailsItems[indexPath.section][indexPath.row].firstUppercased
        
        // Highlight searched text
        let itemHighlighted = NSMutableAttributedString.init(string: itemText)
        let splitSearchArray = searchTerms.components(separatedBy: " ")
        
        if matchBasis.contains(detailsHeaders[indexPath.section]){ // Only highlight matched term within matched section
            for searchTerm in splitSearchArray {
                var range = NSRange()
                if (itemText.lowercased() as NSString).contains(searchTerm.lowercased()){
                    range = (itemText.lowercased() as NSString).range(of: searchTerm.lowercased())
                } else if (itemText.lowercased() as NSString).contains(DataManager.convertAcronyms(searchTerm: searchTerm.lowercased())){
                    range = (itemText.lowercased() as NSString).range(of: DataManager.convertAcronyms(searchTerm: searchTerm.lowercased()))
                }
                itemHighlighted.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow , range: range)
            }
        }
        
        cell.cellLabel.attributedText = itemHighlighted
        
        
        // Setup Accessory Icons
        let relatedAccessory = DataManager.getAccessories(name: detailsName, table: detailsHeaders[indexPath.section], fact: detailsItems[indexPath.section][indexPath.row]).relatedAccessory
        let webViewAccessory = DataManager.getAccessories(name: detailsName, table: detailsHeaders[indexPath.section], fact: detailsItems[indexPath.section][indexPath.row]).webViewAccessory
        
        if !relatedAccessory.isEmpty{
            if UIImage(named: "cellAccessory_related") != nil{
                cell.cellImage1.image = UIImage(named: "cellAccessory_related")
                
                let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cellImage1Action))
                cell.cellImage1.isUserInteractionEnabled = true
                accessoryRelated.append(AccessoryRelated(term: detailsItems[indexPath.section][indexPath.row], related: relatedAccessory, match:[detailsHeaders[indexPath.section]]))
                cell.cellImage1.tag = (accessoryRelated.count-1)
                cell.cellImage1.addGestureRecognizer(tapGestureRecognizer1)
            }
            
        }
        
        if !webViewAccessory.isEmpty{
            
            if UIImage(named: "cellAccessory_webview") != nil{
                cell.cellImage2.image = UIImage(named: "cellAccessory_webview")
                
                let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(cellImage2Action))
                cell.cellImage2.isUserInteractionEnabled = true
                accessoryWebView.append(AccessoryWebView(title: detailsItems[indexPath.section][indexPath.row], url: webViewAccessory))
                cell.cellImage2.tag = (accessoryWebView.count-1)
                cell.cellImage2.addGestureRecognizer(tapGestureRecognizer2)
            }
            
        }
        
        /*if UIImage(named: "cellAccessory_related") != nil{
            cell.cellImage1.image = UIImage(named: "cellAccessory_related")
            
            let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(cellImage1Action))
            cell.cellImage1.isUserInteractionEnabled = true
            cell.cellImage1.tag = indexPath.row
            cell.cellImage1.addGestureRecognizer(tapGestureRecognizer1)
        }*/
        
        
        return cell
        
    }
    
    // Handle tapped accessory icons
    @objc func cellImage1Action(_ sender:AnyObject){
        //print("Title: \(accessoryRelated[sender.view.tag].term), URL: \(accessoryRelated[sender.view.tag].related)")
        //print("Web cell : \(sender.view.tag)")
        
        // Open Related View
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "relatedView") as! RelatedViewController
        nextViewController.passedName = detailsName
        nextViewController.passedTerm = accessoryRelated[sender.view.tag].term
        nextViewController.matchBasis = accessoryRelated[sender.view.tag].match
        nextViewController.relatedEntities = accessoryRelated[sender.view.tag].related
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    @objc func cellImage2Action(_ sender:AnyObject){
        //print("Web cell : \(sender.view.tag)")
        //print("Title: \(accessoryWebView[sender.view.tag].title), URL: \(accessoryWebView[sender.view.tag].url)")
        
        // Open Web View
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "webView") as! WebViewController
        nextViewController.passedTitle = accessoryWebView[sender.view.tag].title
        nextViewController.passedURL = accessoryWebView[sender.view.tag].url
        self.navigationController?.showDetailViewController(nextViewController, sender: self)
    }
    
}

extension DetailsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Make sure that tapping cell doesn't make it turn grey
        detailsTable.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
    }
    
}

// Capitalize first letter of sentence
extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
}
