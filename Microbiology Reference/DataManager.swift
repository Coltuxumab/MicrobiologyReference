//
//  DataManager.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/13/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import UIKit
import Foundation
import CoreData

struct BugElement {
    var rank: Int
    var name: String
    var match: Set<String> // Unique and unordered
}
struct RecentBugElement {
    var time: String
    var name: String
    var match: Set<String>
}
struct BugFilter {
    var phrases: [String]
    var category_restricted: [String:String]
    var acronyms: [String:String]
}
struct Related{
    var name: String
    var match: String
}

class DataManager {
    // MARK: - Core Data stack

    private init(){}
    
    // BEGIN: Custom functions
    
    static var editsMade:Bool = false
    
    static var updatesInProgress:Bool = false
    
    static var diseases:[[String]] = []
    
    static var debug:Bool = false // true = print messages
    
    static let url_bugs:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=0&single=true&output=csv"
    static let url_disease:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=163756307&single=true&output=csv"
    static let url_laboratory:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=1305314672&single=true&output=csv"
    static let url_signs:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=2024846196&single=true&output=csv"
    static let url_sources:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=978989366&single=true&output=csv"
    static let url_treatment:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=640752851&single=true&output=csv"
    static let url_settings:String = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQNIN7mTNIDAZnRu1S0hR4e__SsYfnQ0QadvwtvJjuljY-8aIqSdIFUbWJmoYPg6_N32EWEidcdhjzS/pub?gid=1504880105&single=true&output=csv"
    
    static let themeMainColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    static let themeBackgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    
    static var storedSearchRank:[[(Int, String)]] = []
    
    static var storedBugElements:[[BugElement]] = []
    
    static var bugFilter = BugFilter(
        phrases:
        ["gram p", "gram n", "oxidase p", "oxidase n", "catalase p", "catalase n"], // Must be 2 words. Only type unique prefix of second word
        category_restricted:
        ["rod":"morphology", "coccobacillus":"morphology", "cocci":"morphology", "diplococci":"morphology", "meningitis":"disease"],
        acronyms:
        ["pcn":"penicillin", "penicillin":"pcn", "rod":"coccobacillus", "coccobacillus":"rod"] // For now, need to write in both directions (can update code to auto-reverse)
    )
    
    static func searchAllTables(searchText:String, completion: @escaping ((_ returnResults:[BugElement])->())) {
        
        
        
        var bugElements:[BugElement] = []
        var bugElementShell:[BugElement] = []
        
        var returnValueRank:Int = 0
        var categoryRestriction:String = "all" // Search all categories by default
        var numSearchTerms:Int = searchText.components(separatedBy: " ").count
        let searchTerm:String = self.getSearchPhrases(searchTerms: searchText.components(separatedBy: " ")).1
        numSearchTerms = self.getSearchPhrases(searchTerms: searchText.components(separatedBy: " ")).0
        
        // Set category restriciton if needed
        if self.bugFilter.category_restricted[searchTerm.lowercased()] != nil{
            categoryRestriction = self.bugFilter.category_restricted[searchTerm.lowercased()]!
        }
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        do {
            let diseases = try DataManager.context.fetch(fetchRequest)
            
            for bug in diseases{
                
                // Points system (all matches past array are worth 1)
                var matchValue_name:[Int] = [10, 8, 4]
                var matchValue_disease:[Int] = [8, 4, 3]
                var matchValue_general:[Int] = [5, 3, 2]
                var matchValue_gramstain:[Int] = [5, 3, 2]
                var matchValue_keypoints:[Int] = [5, 3, 2]
                var matchValue_laboratory:[Int] = [2]
                var matchValue_morphology:[Int] = [5, 3, 2]
                var matchValue_prevention:[Int] = [2]
                var matchValue_signs:[Int] = [1]
                var matchValue_treatment:[Int] = [5, 3, 2]
                var matchValue_type:[Int] = [1]
                
                // Break down by word
                var matchedNameTerms:Int = 0
                var matchedDiseaseTerms:Int = 0
                var matchedGeneralTerms:Int = 0
                var matchedGramStainTerms:Int = 0
                var matchedKeyPointsTerms:Int = 0
                var matchedLaboratoryTerms:Int = 0
                var matchedMorphologyTerms:Int = 0
                var matchedPreventionTerms:Int = 0
                var matchedSignsTerms:Int = 0
                var matchedTreatmentTerms:Int = 0
                var matchedTypeTerms:Int = 0
                
                
                // BEGIN: By term
                
                var matchBasis = Set<String>()
                
                if categoryRestriction == "all" || categoryRestriction == "name"{
                    if bug.name.lowercased().contains(searchTerm.lowercased()){
                        matchedNameTerms += 1
                        
                        // Matched based on disease name
                        if matchedNameTerms > (matchValue_name.count-1){
                            // Match beyond point assignment
                            returnValueRank += 1
                        } else {
                            // Matched within point assignment, add those points
                            returnValueRank += matchValue_name[(matchedNameTerms-1)]
                        }
                        
                        // Append name if first match
                        if matchedNameTerms == 1{
                            matchBasis.insert("Name")
                        }
                        
                    }
                }
                
                // Get Disease
                if categoryRestriction == "all" || categoryRestriction == "disease"{
                    let disease = bug.related_disease?.allObjects as! [Disease]
                    if !disease.isEmpty {
                        if disease.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedDiseaseTerms += 1
                            
                            // Matched based on Disease
                            if matchedDiseaseTerms > (matchValue_disease.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_disease[(matchedDiseaseTerms-1)]
                            }
                            
                            // Append Disease if first match
                            if matchedDiseaseTerms == 1{
                                matchBasis.insert("Disease")
                            }
                        }
                    }
                }
                
                // Get General
                if categoryRestriction == "all" || categoryRestriction == "general"{
                    let general = bug.related_general?.allObjects as! [General]
                    if !general.isEmpty {
                        if general.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedGeneralTerms += 1
                            
                            // Matched based on General
                            if matchedGeneralTerms > (matchValue_general.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_general[(matchedGeneralTerms-1)]
                            }
                            
                            // Append patient if first match
                            if matchedGeneralTerms == 1{
                                matchBasis.insert("General")
                            }
                        }
                    }
                }
                
                // Get GramStain
                if categoryRestriction == "all" || categoryRestriction == "gramstain"{
                    let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                    if !gramstain.isEmpty {
                        if gramstain.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedGramStainTerms += 1
                            
                            // Matched based on GramStain
                            if matchedGramStainTerms > (matchValue_gramstain.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_gramstain[(matchedGramStainTerms-1)]
                            }
                            
                            // Append GramStain if first match
                            if matchedGramStainTerms == 1{
                                matchBasis.insert("Gram Stain")
                            }
                        }
                    }
                }
                
                // Get KeyPoints
                if categoryRestriction == "all" || categoryRestriction == "keypoints"{
                    let keypoints = bug.related_keypoints?.allObjects as! [KeyPoints]
                    if !keypoints.isEmpty {
                        if keypoints.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedKeyPointsTerms += 1
                            
                            // Matched based on KeyPoints
                            if matchedKeyPointsTerms > (matchValue_keypoints.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_keypoints[(matchedKeyPointsTerms-1)]
                            }
                            
                            // Append KeyPoint if first match
                            if matchedKeyPointsTerms == 1{
                                matchBasis.insert("Key Points")
                            }
                        }
                    }
                }
                
                // Get Laboratory
                if categoryRestriction == "all" || categoryRestriction == "laboratory"{
                    let laboratory = bug.related_laboratory?.allObjects as! [Laboratory]
                    if !laboratory.isEmpty {
                        if laboratory.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedLaboratoryTerms += 1
                            
                            // Matched based on Laboratory
                            if matchedLaboratoryTerms > (matchValue_laboratory.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_laboratory[(matchedLaboratoryTerms-1)]
                            }
                            
                            // Append Laboratory if first match
                            if matchedLaboratoryTerms == 1{
                                matchBasis.insert("Laboratory")
                            }
                        }
                    }
                }
                
                // Get Morphology
                if categoryRestriction == "all" || categoryRestriction == "morphology"{
                    let morphology = bug.related_morphology?.allObjects as! [Morphology]
                    if !morphology.isEmpty {
                        if morphology.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedMorphologyTerms += 1
                            
                            // Matched based on Morphology
                            if matchedMorphologyTerms > (matchValue_morphology.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_morphology[(matchedMorphologyTerms-1)]
                            }
                            
                            // Append Morphology if first match
                            if matchedMorphologyTerms == 1{
                                matchBasis.insert("Morphology")
                            }
                        }
                    }
                }
                
                // Get Prevention
                if categoryRestriction == "all" || categoryRestriction == "prevention"{
                    let prevention = bug.related_prevention?.allObjects as! [Prevention]
                    if !prevention.isEmpty {
                        if prevention.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedPreventionTerms += 1
                            
                            // Matched based on Prevention
                            if matchedPreventionTerms > (matchValue_prevention.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_prevention[(matchedPreventionTerms-1)]
                            }
                            
                            // Append Prevention if first match
                            if matchedPreventionTerms == 1{
                                matchBasis.insert("Prevention")
                            }
                        }
                    }
                }
                
                // Get Signs
                if categoryRestriction == "all" || categoryRestriction == "signs"{
                    let signs = bug.related_signs?.allObjects as! [Signs]
                    if !signs.isEmpty {
                        if signs.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedSignsTerms += 1
                            
                            // Matched based on Signs
                            if matchedSignsTerms > (matchValue_signs.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_signs[(matchedSignsTerms-1)]
                            }
                            
                            // Append Signs if first match
                            if matchedSignsTerms == 1{
                                matchBasis.insert("Signs")
                            }
                        }
                    }
                }
                
                // Get Treatment
                if categoryRestriction == "all" || categoryRestriction == "treatment"{
                    let treatment = bug.related_treatments?.allObjects as! [Treatment]
                    if !treatment.isEmpty {
                        if treatment.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedTreatmentTerms += 1
                            
                            // Matched based on Treatment
                            if matchedTreatmentTerms > (matchValue_treatment.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_treatment[(matchedTreatmentTerms-1)]
                            }
                            
                            // Append Treatment if first match
                            if matchedTreatmentTerms == 1{
                                matchBasis.insert("Treatment")
                            }
                        }
                    }
                }
                
                // Get Type
                if categoryRestriction == "all" || categoryRestriction == "type"{
                    let type = bug.related_type?.allObjects as! [Type]
                    if !type.isEmpty {
                        if type.contains(where: { ($0.name?.lowercased().contains(searchTerm.lowercased()))! || ($0.name?.lowercased().contains(self.convertAcronyms(searchTerm: searchTerm)))! }){
                            matchedTypeTerms += 1
                            
                            // Matched based on Type
                            if matchedTypeTerms > (matchValue_type.count-1){
                                // Match beyond point assignment
                                returnValueRank += 1
                            } else {
                                // Matched within point assignment, add those points
                                returnValueRank += matchValue_type[(matchedTypeTerms-1)]
                            }
                            
                            // Append Type if first match
                            if matchedTypeTerms == 1{
                                matchBasis.insert("Type")
                            }
                        }
                    }
                }

                // END: By term
                
                if (matchedNameTerms + matchedDiseaseTerms + matchedGeneralTerms + matchedGramStainTerms + matchedKeyPointsTerms + matchedLaboratoryTerms + matchedMorphologyTerms + matchedPreventionTerms + matchedSignsTerms + matchedTreatmentTerms + matchedTypeTerms) > 0{
                    
                    // Create Element
                    let bugElement = BugElement(rank: returnValueRank, name: bug.name, match: matchBasis) // Initialize struct
                    bugElementShell.append(bugElement)

                    
                }
                
                returnValueRank = 0
                
            }
            
        } catch {
            if DataManager.debug{ print("Could not get Bugs!") }
        }
        
        
        // Handle stored search
        if numSearchTerms == 0{
            // No stored search
            //print("None")
            self.storedBugElements.append(bugElementShell)
        } else if numSearchTerms > self.storedBugElements.count{
            // New search term
            //print("New")
            self.storedBugElements.append(bugElementShell)
        } else if numSearchTerms < self.storedBugElements.count{
            // Deleted search term
            //print("Delete")
            self.storedBugElements.removeLast()
        } else if numSearchTerms == self.storedBugElements.count{
            // Still typing search term
            //print("Still...")
            self.storedBugElements.removeLast()
            self.storedBugElements.append(bugElementShell)
        }
        
        // Handle stored search
        if self.storedBugElements.count > 0 {
            let namedElements = self.storedBugElements.joined().map { ($0.name, $0) }
            // Now combine them as you describe. Add the ranks, and merge the items
            let uniqueElements =
                Dictionary<String, BugElement>(namedElements,
                                               uniquingKeysWith: { (lhs, rhs) -> BugElement in
                                                    let sum = lhs.rank + rhs.rank
                                                    return BugElement(rank: sum,
                                                               name: lhs.name,
                                                               match: lhs.match.union(rhs.match))
                })
            
            // The result is the values of the dictionary
            let result = uniqueElements.values
            bugElements = result.sorted { $0.rank > $1.rank }
        
        } else{
            bugElements = bugElementShell.sorted { $0.rank > $1.rank }
        }
        
        
        
        completion(bugElements)
        
    }
    
    static func convertAcronyms(searchTerm:String) -> (String){
        var convertedSearchTerm:String = searchTerm
        
        
        if self.bugFilter.acronyms.contains(where: {$0.key == searchTerm.lowercased()}){
            convertedSearchTerm = self.bugFilter.acronyms[searchTerm.lowercased()]!
        }
        
        return convertedSearchTerm
    }
    
    static func getSearchPhrases(searchTerms:[String]) -> (Int, String){
        var searchTerm:String
        var numTerms:Int = searchTerms.count
        
        if numTerms > 1{
            let lastTwo = searchTerms.suffix(2)
            if self.bugFilter.phrases.contains(where: {  lastTwo.joined(separator: " ").lowercased().hasPrefix($0) }) {
            //if self.bugFilter.phrases.contains(lastTwo.joined(separator: " ").lowercased()) {
                //print("Match!")
                searchTerm = lastTwo.joined(separator: " ")
                //numTerms = numTerms - 1
            } else if self.bugFilter.phrases.contains(where: { $0.components(separatedBy: " ").first == lastTwo.last?.lowercased() }){
                //print("Sorta...")
                numTerms = numTerms - 1
                searchTerm = searchTerms.dropLast().last!
            } else{
                //print("No match")
                searchTerm = searchTerms.last!
            }
        } else{
            if self.bugFilter.phrases.contains(where: { $0.components(separatedBy: " ").first == searchTerms[0].lowercased() }){
                searchTerm = "none"
            } else{
                searchTerm = searchTerms[0]
            }
        }
        
        return (numTerms, searchTerm)
    }
    
    // Checks bug characteristcs to determine the correct table image to display
    static func getTableImage(name:String) -> String{
        var imageName:String = "TableImage-BacteriaUnknown"
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Match disease
        let predicate = NSPredicate(format:"name = %@", name)
        fetchRequest.predicate = predicate
        
        // Limit number of results
        fetchRequest.fetchLimit = 1
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                
                // Get: Type --> Morphology --> Gram Stain
                let types = bug.related_type?.allObjects as! [Type]
                if !types.isEmpty {
                    if types.contains(where: {$0.name?.lowercased() == "bacteria"} ){
                        
                        // Get Morphology
                        let morphology = bug.related_morphology?.allObjects as! [Morphology]
                        if !morphology.isEmpty {
                            if morphology.contains(where: {($0.name?.lowercased().contains("cocci"))! && ($0.name?.lowercased().contains("clusters"))!} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaCocciClustersGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaCocciClustersGN"
                                    }
                                }
                                
                            } else if morphology.contains(where: {($0.name?.lowercased().contains("cocci"))! && (($0.name?.lowercased().contains("pairs"))! || ($0.name?.lowercased().contains("diplo"))! || ($0.name?.lowercased().contains("chain"))!)} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaCocciPairsGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaCocciPairsGN"
                                    }
                                }
                                
                            } else if morphology.contains(where: {($0.name?.lowercased().contains("cocci"))!} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaCocciGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaCocciGN"
                                    }
                                }
                                
                            } else if morphology.contains(where: {($0.name?.lowercased().contains("rod"))! || ($0.name?.lowercased().contains("bacillus"))! || ($0.name?.lowercased().contains("bacilli"))!} ){
                                
                                // Get GramStain
                                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                                if !gramstain.isEmpty {
                                    if gramstain.contains(where: {($0.name?.lowercased().contains("positive"))!} ){
                                        imageName = "TableImage-BacteriaRodGP"
                                    } else if gramstain.contains(where: {($0.name?.lowercased().contains("negative"))!} ){
                                        imageName = "TableImage-BacteriaRodGN"
                                    }
                                }
                                
                            }
                        }
                        
                    } else if types.contains(where: {$0.name?.lowercased() == "fungi" || $0.name?.lowercased() == "fungus"} ){
                        imageName = "TableImage-Fungi"
                    } else if types.contains(where: {$0.name?.lowercased() == "parasite"} ){
                        imageName = "TableImage-Parasite"
                    } else if types.contains(where: {$0.name?.lowercased() == "virus"} ){
                        imageName = "TableImage-Virus"
                    }
                }
                
            }
        } catch {
            if DataManager.debug{ print("Could not get data for bug: \(name)") }
        }
        
        return imageName
    }
    
    /*static func getData() { //NOTE MAYBE DELETE THIS FUNCTION
        var diseaseDataShell:[String] = []
        
        let fetchRequest: NSFetchRequest<Diseases> = Diseases.fetchRequest()
        
        do {
            let diseases = try DataManager.context.fetch(fetchRequest)
            for disease in diseases{
                diseaseDataShell.append(disease.name)
            }
        } catch {
            if DataManager.debug{ print("Could not get Diagnoses!") }
        }
        
        DataManager.diseases.append(diseaseDataShell)
        diseaseDataShell.removeAll()
        
        DataManager.updatesInProgress = false
        AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil)
        
    }*/
    
    // Determine accessories
    static func getAccessories(name:String, table:String, fact:String) -> (relatedAccessory:[Related], webViewAccessory:String) {
        
        var relatedAccessoryContainer = [Related]()
        var webViewAccessory:String = ""
        
        // WEB VIEW ACCESSORIES
        // Eliminate tables that don't have web accessories
        if table != "General" && table != "GramStain" && table != "KeyPoints" && table != "Morphology" && table == "Prevention" && table != "Type"{

            let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match entity
            let predicate = NSPredicate(format:"name = %@", name)
            fetchRequest.predicate = predicate
            
            // Limit number of results
            fetchRequest.fetchLimit = 1
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest)
                for bug in bugs{
                    
                    // WEBVIEW Get: Type --> Morphology --> Gram Stain
                    let diseases = bug.related_disease?.allObjects as! [Disease]
                    if !diseases.isEmpty {
                        if diseases.contains(where: { $0.name == fact && $0.link != nil } ){
                            webViewAccessory = (diseases.first?.link)!
                        }
                    }
                    
                    
                    
                    //NOTE: New table column of related bugs. During setup, create new relationship. Fetch relationship here to result bug names in Related struct.
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get data for bug: \(name)") }
            }
        }
        
        // RELATED ACCESSORIES
        if table == "Disease"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_disease.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Disease")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "General"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_general.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "General")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Gram Stain"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_gramstain.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Gram Stain")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Key Points"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_keypoints.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Key Points")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Laboratory"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_laboratory.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Laboratory")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Morphology"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_morphology.name contains %@ OR related_morphology.name contains %@", fact, self.convertAcronyms(searchTerm: fact))
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Morphology")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Prevention"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_prevention.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Prevention")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Signs"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_signs.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Signs")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Treatment"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_treatments.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Treatment")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        } else if table == "Type"{
            let fetchRequest2: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            
            // Match disease
            let predicate2 = NSPredicate(format:"related_type.name contains %@", fact)
            fetchRequest2.predicate = predicate2
            
            do {
                let bugs = try DataManager.context.fetch(fetchRequest2)
                for bug in bugs{
                    
                    if bug.name != name{ relatedAccessoryContainer.append(Related(name: bug.name, match: "Type")) }
                    //print("Related: \(bug.name)")
                    
                }
            } catch {
                if DataManager.debug{ print("Could not get related for table: \(table)") }
            }
        }
        
        return (relatedAccessoryContainer,webViewAccessory)
    }
    
    // Return all
    static func getAllBugs(completion: @escaping ((_ data:[String])->())) {

        var allBugs:[String] = []
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                
                allBugs.append(bug.name)
                
            }
            allBugs = allBugs.sorted {$0 < $1 } // A --> Z
        } catch {
            if DataManager.debug{ print("Could not get all data.") }
        }
        
        completion(allBugs)
        
    }
    
    static func getSingleBug(bugName:String, completion: @escaping ((_ headers:[String], _ data:[[String]])->())) {
        
        var headersShell:[String] = []
        var bugDataShell:[[String]] = []
        var entityShell:[String] = []
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Match disease
        let predicate = NSPredicate(format:"name = %@", bugName)
        fetchRequest.predicate = predicate
        
        // Limit number of results
        fetchRequest.fetchLimit = 1
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                
                // Get Type
                let types = bug.related_type?.allObjects as! [Type]
                if !types.isEmpty {
                    headersShell.append("Type")
                    innerLoop: for type in types{
                        entityShell.append(type.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get KeyPoints
                let keypoints = bug.related_keypoints?.allObjects as! [KeyPoints]
                if !keypoints.isEmpty {
                    headersShell.append("Key Points")
                    innerLoop: for kp in keypoints{
                        entityShell.append(kp.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get General
                let general = bug.related_general?.allObjects as! [General]
                if !general.isEmpty {
                    headersShell.append("General")
                    innerLoop: for gen in general{
                        entityShell.append(gen.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get GramStain
                let gramstain = bug.related_gramstain?.allObjects as! [GramStain]
                if !gramstain.isEmpty {
                    headersShell.append("Gram Stain")
                    innerLoop: for gs in gramstain{
                        entityShell.append(gs.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Morphology
                let morphology = bug.related_morphology?.allObjects as! [Morphology]
                if !morphology.isEmpty {
                    headersShell.append("Morphology")
                    innerLoop: for morph in morphology{
                        entityShell.append(morph.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Laboratory
                let laboratory = bug.related_laboratory?.allObjects as! [Laboratory]
                if !laboratory.isEmpty {
                    headersShell.append("Laboratory")
                    innerLoop: for lab in laboratory{
                        entityShell.append(lab.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Treatment
                let treatment = bug.related_treatments?.allObjects as! [Treatment]
                if !treatment.isEmpty {
                    headersShell.append("Treatment")
                    innerLoop: for tx in treatment{
                        entityShell.append(tx.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Prevention
                let prevention = bug.related_prevention?.allObjects as! [Prevention]
                if !prevention.isEmpty {
                    headersShell.append("Prevention")
                    innerLoop: for prevent in prevention{
                        entityShell.append(prevent.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Disease
                let disease = bug.related_disease?.allObjects as! [Disease]
                if !disease.isEmpty {
                    headersShell.append("Disease")
                    innerLoop: for dz in disease{
                        entityShell.append(dz.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Signs
                let signs = bug.related_signs?.allObjects as! [Signs]
                if !signs.isEmpty {
                    headersShell.append("Signs")
                    innerLoop: for sign in signs{
                        entityShell.append(sign.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
                // Get Sources
                let sources = bug.related_source?.allObjects as! [Sources]
                if !sources.isEmpty {
                    headersShell.append("Sources")
                    innerLoop: for source in sources{
                        entityShell.append(source.name!)
                    }
                    bugDataShell.append(entityShell)
                    entityShell.removeAll()
                }
                
            }
        } catch {
            if DataManager.debug{ print("Could not get data for bug: \(bugName)") }
        }
        
        completion(headersShell,bugDataShell)
        
    }
    
    static func getRecent(numberToGet:Int = 5, completion: @escaping ((_ returnResults:[RecentBugElement])->())){
        
        var bugElements:[RecentBugElement] = []
        
        
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Find all matching diagnostics with given name (expect just one)
        let predicate = NSPredicate(format:"last_accessed != %@", 0)
        fetchRequest.predicate = predicate
        
        // Limit number of results
        fetchRequest.fetchLimit = numberToGet
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            if bugs.count == 0{
                
            } else{
                for bug in bugs{
                    
                    // Format date basis
                    guard let lastAccessed = bug.last_accessed as Date? else {
                        // date is nil, ignore this entry:
                        continue
                    }
                    
                    let previousDate = lastAccessed
                    let now = Date()
                    
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .brief
                    formatter.allowedUnits = [.month, .day, .hour]
                    formatter.maximumUnitCount = 1   // Show just one unit (i.e. 1d vs. 1d 6hrs)
                    
                    let stringDate = formatter.string(from: previousDate, to: now)
                    guard var date = stringDate as String? else {
                        // date is nil, ignore this entry:
                        continue
                    }
                    
                    
                    if date == "0hr" {
                        // Search was recently made
                        date = "Now"
                    }
                    var matchBasisSet = Set<String>()
                    for matchTerm in bug.match_basis!.components(separatedBy: ", ") {
                        matchBasisSet.insert(matchTerm)
                    }
                    
                    bugElements.append(RecentBugElement(time: date, name: bug.name, match: matchBasisSet))

                }
            }
            
        } catch {
            if DataManager.debug{ print("Could not get get \(numberToGet) recents.") }
        }
        completion(bugElements)
    }
    
    static func addData(table:String, data:[[String:String]], completion: @escaping ()->()) {
        if table == "bugs"{
            if DataManager.debug{ print("Adding Bugs data to CoreData") }
            
            for bug in data{
                var bugName:String = "DefaultBug"
                var bugDisease:String = "DefaultDisease"
                var bugGeneral:String = "DefaultGeneral"
                var bugGramStain:String = "DefaultGramStain"
                var bugKeyPoints:String = "DefaultKeyPoints"
                var bugLaboratory:String = "DefaultLaboratory"
                var bugMorphology:String = "DefaultMorphology"
                var bugPrevention:String = "DefaultPrevention"
                var bugSigns:String = "DefaultSigns"
                var bugSources:String = "DefaultSources"
                var bugTreatment:String = "DefaultTreatment"
                var bugType:String = "DefaultType"
                for (attributes,value) in bug{
                    if attributes == "Name"{
                        bugName = value
                    } else if attributes == "Disease"{
                        bugDisease = value
                    } else if attributes == "General"{
                        bugGeneral = value
                    } else if attributes == "Gram Stain"{
                        bugGramStain = value
                    } else if attributes == "Key Points"{
                        bugKeyPoints = value
                    } else if attributes == "Laboratory"{
                        bugLaboratory = value
                    } else if attributes == "Morphology"{
                        bugMorphology = value
                    } else if attributes == "Prevention"{
                        bugPrevention = value
                    } else if attributes == "Signs"{
                        bugSigns = value
                    } else if attributes == "Sources"{
                        bugSources = value
                    } else if attributes == "Treatment"{
                        bugTreatment = value
                    } else if attributes == "Type"{
                        bugType = value
                    } else{
                        if DataManager.debug{ print("Found unexpected table header.") }
                    }
                    
                }
                
                let bugs = Bugs(context: DataManager.context)
                bugs.name = bugName
                if bugDisease != "DefaultDisease"{
                    let valueArray:[String] = bugDisease.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let disease = Disease(context: DataManager.context)
                        disease.name = singleValue
                        let related_bug = disease.mutableSetValue(forKey: "related_bug")
                        related_bug.add(bugs)
                    }
                }
                if bugGeneral != "DefaultGeneral"{
                    let valueArray:[String] = bugGeneral.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let general = General(context: DataManager.context)
                        general.name = singleValue
                        let related_bug = general.mutableSetValue(forKey: "related_bug")
                        related_bug.add(bugs)
                    }
                }
                if bugGramStain != "DefaultGramStain"{
                    let valueArray:[String] = bugGramStain.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let gramstain = GramStain(context: DataManager.context)
                        gramstain.name = singleValue
                        let related_gramstain = gramstain.mutableSetValue(forKey: "related_bug")
                        related_gramstain.add(bugs)
                    }
                }
                if bugKeyPoints != "DefaultKeyPoints"{
                    let valueArray:[String] = bugKeyPoints.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let keypoints = KeyPoints(context: DataManager.context)
                        keypoints.name = singleValue
                        let related_keypoints = keypoints.mutableSetValue(forKey: "related_bug")
                        related_keypoints.add(bugs)
                    }
                }
                if bugLaboratory != "DefaultLaboratory"{
                    let valueArray:[String] = bugLaboratory.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let laboratory = Laboratory(context: DataManager.context)
                        laboratory.name = singleValue
                        let related_laboratory = laboratory.mutableSetValue(forKey: "related_bug")
                        related_laboratory.add(bugs)
                    }
                }
                if bugMorphology != "DefaultMorphology"{
                    let valueArray:[String] = bugMorphology.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let morphology = Morphology(context: DataManager.context)
                        morphology.name = singleValue
                        let related_morphology = morphology.mutableSetValue(forKey: "related_bug")
                        related_morphology.add(bugs)
                    }
                }
                if bugPrevention != "DefaultPrevention"{
                    let valueArray:[String] = bugPrevention.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let prevention = Prevention(context: DataManager.context)
                        prevention.name = singleValue
                        let related_prevention = prevention.mutableSetValue(forKey: "related_bug")
                        related_prevention.add(bugs)
                    }
                }
                if bugSigns != "DefaultSigns"{
                    let valueArray:[String] = bugSigns.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let signs = Signs(context: DataManager.context)
                        signs.name = singleValue
                        let related_signs = signs.mutableSetValue(forKey: "related_bug")
                        related_signs.add(bugs)
                    }
                }
                if bugSources != "DefaultSources"{
                    let valueArray:[String] = bugSources.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let sources = Sources(context: DataManager.context)
                        sources.name = singleValue
                        let related_sources = sources.mutableSetValue(forKey: "related_bug")
                        related_sources.add(bugs)
                    }
                }
                if bugTreatment != "DefaultTreatment"{
                    let valueArray:[String] = bugTreatment.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let treatment = Treatment(context: DataManager.context)
                        treatment.name = singleValue
                        let related_treatment = treatment.mutableSetValue(forKey: "related_bug")
                        related_treatment.add(bugs)
                    }
                }
                if bugType != "DefaultType"{
                    let valueArray:[String] = bugType.components(separatedBy: "; ")
                    for singleValue in valueArray{
                        let type = Type(context: DataManager.context)
                        type.name = singleValue
                        let related_type = type.mutableSetValue(forKey: "related_bug")
                        related_type.add(bugs)
                    }
                }
                
            }

            completion()
            //DataManager.saveContext()
            
        } else if table == "disease"{
            if DataManager.debug{ print("Adding Disease data to CoreData") }
            
            for disease in data{
                var diseaseName:String = "DefaultDisease"
                var diseaseLinks:[String] = []
                for (attributes,value) in disease{
                    if attributes == "Name"{
                        diseaseName = value
                    } else if attributes == "Link"{
                        let valueArray:[String] = value.components(separatedBy: "; ")
                        for singleValue in valueArray{
                            diseaseLinks.append(singleValue)
                        }
                    }
                    
                }
                for diseaseLink in diseaseLinks{
                    let fetchRequest: NSFetchRequest<Disease> = Disease.fetchRequest()
                    
                    // Find all matching diagnostics with given name
                    let predicate = NSPredicate(format:"name beginswith[c] %@", diseaseName)
                    fetchRequest.predicate = predicate
                    
                    do {
                        let r_diseases = try DataManager.context.fetch(fetchRequest)
                        for r_disease in r_diseases{
                            //print("Matched: \(String(describing: diagnostic.name))")
                            // Add link data
                            r_disease.link = diseaseLink
                        }
                    } catch {
                        if DataManager.debug{ print("Could not get Diseases!") }
                    }
                }
                
                
            }
            completion()
            //DataManager.saveContext()
            
        } else if table == "laboratory"{
            if DataManager.debug{ print("Adding Laboratory data to CoreData") }
            
            for laboratory in data{
                var laboratoryName:String = "DefaultLaboratory"
                var laboratoryLinks:[String] = []
                for (attributes,value) in laboratory{
                    if attributes == "Name"{
                        laboratoryName = value
                    } else if attributes == "Link"{
                        let valueArray:[String] = value.components(separatedBy: "; ")
                        for singleValue in valueArray{
                            laboratoryLinks.append(singleValue)
                        }
                    }
                    
                }
                for laboratoryLink in laboratoryLinks{
                    let fetchRequest: NSFetchRequest<Laboratory> = Laboratory.fetchRequest()
                    
                    // Find all matching diagnostics with given name
                    let predicate = NSPredicate(format:"name beginswith[c] %@", laboratoryName)
                    fetchRequest.predicate = predicate
                    
                    do {
                        let r_laboratories = try DataManager.context.fetch(fetchRequest)
                        for r_laboratory in r_laboratories{
                            //print("Matched: \(String(describing: diagnostic.name))")
                            // Add link data
                            r_laboratory.link = laboratoryLink
                        }
                    } catch {
                        if DataManager.debug{ print("Could not get Laboratory!") }
                    }
                }
                
                
            }
            completion()
            //DataManager.saveContext()
            
        } else if table == "signs"{
            if DataManager.debug{ print("Adding Disease data to CoreData") }
            
            for signs in data{
                var signsName:String = "DefaultSigns"
                var signsLinks:[String] = []
                for (attributes,value) in signs{
                    if attributes == "Name"{
                        signsName = value
                    } else if attributes == "Link"{
                        let valueArray:[String] = value.components(separatedBy: "; ")
                        for singleValue in valueArray{
                            signsLinks.append(singleValue)
                        }
                    }
                    
                }
                for signsLink in signsLinks{
                    let fetchRequest: NSFetchRequest<Signs> = Signs.fetchRequest()
                    
                    // Find all matching diagnostics with given name
                    let predicate = NSPredicate(format:"name beginswith[c] %@", signsName)
                    fetchRequest.predicate = predicate
                    
                    do {
                        let r_signs = try DataManager.context.fetch(fetchRequest)
                        for r_sign in r_signs{
                            //print("Matched: \(String(describing: diagnostic.name))")
                            // Add link data
                            r_sign.link = signsLink
                        }
                    } catch {
                        if DataManager.debug{ print("Could not get Signs!") }
                    }
                }
                
                
            }
            completion()
            //DataManager.saveContext()
            
        } else if table == "sources"{
            if DataManager.debug{ print("Adding Sources data to CoreData") }
            
            for sources in data{
                var sourcesName:String = "DefaultSources"
                var sourcesLinks:[String] = []
                for (attributes,value) in sources{
                    if attributes == "Name"{
                        sourcesName = value
                    } else if attributes == "Link"{
                        let valueArray:[String] = value.components(separatedBy: "; ")
                        for singleValue in valueArray{
                            sourcesLinks.append(singleValue)
                        }
                    }
                    
                }
                for sourcesLink in sourcesLinks{
                    let fetchRequest: NSFetchRequest<Sources> = Sources.fetchRequest()
                    
                    // Find all matching diagnostics with given name
                    let predicate = NSPredicate(format:"name beginswith[c] %@", sourcesName)
                    fetchRequest.predicate = predicate
                    
                    do {
                        let r_sources = try DataManager.context.fetch(fetchRequest)
                        for r_source in r_sources{
                            //print("Matched: \(String(describing: diagnostic.name))")
                            // Add link data
                            r_source.link = sourcesLink
                        }
                    } catch {
                        if DataManager.debug{ print("Could not get Sources!") }
                    }
                }
                
                
            }
            completion()
            //DataManager.saveContext()
            
        } else if table == "treatment"{
            if DataManager.debug{ print("Adding Treatment data to CoreData") }
            
            for treatment in data{
                var treatmentName:String = "DefaultTreatment"
                var treatmentSideEffects:[String] = []
                for (attributes,value) in treatment{
                    if attributes == "Name"{
                        treatmentName = value
                    } else if attributes == "Side Effect"{
                        let valueArray:[String] = value.components(separatedBy: "; ")
                        for singleValue in valueArray{
                            treatmentSideEffects.append(singleValue)
                        }
                    }
                    
                }
                for treatmentSideEffect in treatmentSideEffects{
                    let fetchRequest: NSFetchRequest<Treatment> = Treatment.fetchRequest()
                    
                    // Find all matching diagnostics with given name
                    let predicate = NSPredicate(format:"name beginswith[c] %@", treatmentName)
                    fetchRequest.predicate = predicate
                    
                    do {
                        let treatments = try DataManager.context.fetch(fetchRequest)
                        for treatment in treatments{
                            //print("Matched: \(String(describing: diagnostic.name))")
                            // Add link data
                            treatment.sideeffect = treatmentSideEffect
                        }
                    } catch {
                        if DataManager.debug{ print("Could not get Treatment!") }
                    }
                }
                
                
            }
            completion()
        }
        
        //PersistentService.saveContext()

    }
    
    static func downloadBugs(completion: @escaping ()->()){
        DataManager.updatesInProgress = true
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_bugs, table: "bugs"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "bugs"){ (result) -> () in
                    DataManager.addData(table: "bugs", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadDisease(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_disease, table: "disease"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "disease"){ (result) -> () in
                    DataManager.addData(table: "disease", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadLaboratory(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_laboratory, table: "laboratory"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "laboratory"){ (result) -> () in
                    DataManager.addData(table: "laboratory", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadSigns(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_signs, table: "signs"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "signs"){ (result) -> () in
                    DataManager.addData(table: "signs", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    
    static func downloadSources(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_sources, table: "sources"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "sources"){ (result) -> () in
                    DataManager.addData(table: "sources", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func downloadTreatment(completion: @escaping ()->()){
        CSVImporterManager.sharedInstance.downloadNewData(webURL: url_treatment, table: "treatment"){ (success) -> () in
            
            if success {
                CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "treatment"){ (result) -> () in
                    DataManager.addData(table: "treatment", data: result){ () -> () in
                        completion()
                    }
                }
                
            } else{
                // HANDLE FAILED DOWNLOAD
            }
            
        }
    }
    
    static func orchestrateUpdates(table:String, dataSource:String = "external", completion: @escaping ()->()){
        DataManager.updatesInProgress = true
        switch (table, dataSource){
        case ("all", "external"):
            // First, delete current data
            DataManager.deleteAllObjects(table: "bugs")
            DataManager.deleteAllObjects(table: "disease")
            DataManager.deleteAllObjects(table: "general")
            DataManager.deleteAllObjects(table: "gramstain")
            DataManager.deleteAllObjects(table: "keypoints")
            DataManager.deleteAllObjects(table: "laboratory")
            DataManager.deleteAllObjects(table: "morphology")
            DataManager.deleteAllObjects(table: "prevention")
            DataManager.deleteAllObjects(table: "signs")
            DataManager.deleteAllObjects(table: "sources")
            DataManager.deleteAllObjects(table: "treatment")
            DataManager.deleteAllObjects(table: "type")
            
            downloadBugs(){ () -> () in
                orchestrateUpdates(table: "disease", dataSource: "external"){ () -> () in
                    // Complete
                    completion()
                }
            }
        case ("disease", "external"):
            downloadDisease(){ () -> () in
                orchestrateUpdates(table: "laboratory", dataSource: "external"){ () -> () in
                    // Complete
                    completion()
                }
            }
        case ("laboratory", "external"):
            downloadLaboratory(){ () -> () in
                orchestrateUpdates(table: "signs", dataSource: "external"){ () -> () in
                    // Complete
                    completion()
                }
            }
        case ("signs", "external"):
            downloadSigns(){ () -> () in
                orchestrateUpdates(table: "sources", dataSource: "external"){ () -> () in
                    // Complete
                    completion()
                }
            }
        case ("sources", "external"):
            downloadSources(){ () -> () in
                orchestrateUpdates(table: "treatment", dataSource: "external"){ () -> () in
                    // Complete
                    completion()
                }
            }
        case ("treatment", "external"):
            downloadTreatment(){ () -> () in
                if DataManager.debug{ print("Completed external orchestration") }
                AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil) // Dismiss popup notification of data update
                DataManager.updatesInProgress = false
                completion()
            }
        case ("all", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "bugs"){ (result) -> () in
                DataManager.addData(table: "bugs", data: result){ () -> () in
                    orchestrateUpdates(table: "disease", dataSource: "internal"){ () -> () in
                        // Complete
                        completion()
                    }
                }
            }
        case ("disease", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "disease"){ (result) -> () in
                DataManager.addData(table: "disease", data: result){ () -> () in
                    orchestrateUpdates(table: "laboratory", dataSource: "internal"){ () -> () in
                        // Complete
                        completion()
                    }
                }
            }
        case ("laboratory", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "laboratory"){ (result) -> () in
                DataManager.addData(table: "laboratory", data: result){ () -> () in
                    orchestrateUpdates(table: "signs", dataSource: "internal"){ () -> () in
                        // Complete
                        completion()
                    }
                }
            }
        case ("signs", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "signs"){ (result) -> () in
                DataManager.addData(table: "signs", data: result){ () -> () in
                    orchestrateUpdates(table: "sources", dataSource: "internal"){ () -> () in
                        // Complete
                        completion()
                    }
                }
            }
        case ("sources", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "sources"){ (result) -> () in
                DataManager.addData(table: "sources", data: result){ () -> () in
                    orchestrateUpdates(table: "treatment", dataSource: "internal"){ () -> () in
                        // Complete
                        completion()
                    }
                }
            }
        case ("treatment", "internal"):
            CSVImporterManager.sharedInstance.importCSV(dataSource: "internal", table: "treatment"){ (result) -> () in
                DataManager.addData(table: "treatment", data: result){ () -> () in
                    if DataManager.debug{ print("Completed internal orchestration") }
                    AppDelegate.sharedInstance().window!.rootViewController?.dismiss(animated: true, completion: nil) // Dismiss popup notification of data initiation
                    DataManager.updatesInProgress = false
                    completion()
                }
            }
        case (_, _):
            if DataManager.debug{ print("Missing case in orchestrateUpdates function.") }
            completion()
        }
        
    }
    
    static func deleteAllObjects(table:String){
        switch table{
        case "bugs":
            let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "disease":
            let fetchRequest: NSFetchRequest<Disease> = Disease.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "general":
            let fetchRequest: NSFetchRequest<General> = General.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "gramstain":
            let fetchRequest: NSFetchRequest<GramStain> = GramStain.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "keypoints":
            let fetchRequest: NSFetchRequest<KeyPoints> = KeyPoints.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "laboratory":
            let fetchRequest: NSFetchRequest<Laboratory> = Laboratory.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "morphology":
            let fetchRequest: NSFetchRequest<Morphology> = Morphology.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "prevention":
            let fetchRequest: NSFetchRequest<Prevention> = Prevention.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "signs":
            let fetchRequest: NSFetchRequest<Signs> = Signs.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "sources":
            let fetchRequest: NSFetchRequest<Sources> = Sources.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "treatment":
            let fetchRequest: NSFetchRequest<Treatment> = Treatment.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case "type":
            let fetchRequest: NSFetchRequest<Type> = Type.fetchRequest()
            do {
                let table = try DataManager.context.fetch(fetchRequest)
                for object in table{
                    DataManager.context.delete(object)
                }
            } catch {
                if DataManager.debug{ print("Could not get table: \(table).") }
            }
        case _:
            if DataManager.debug{ print("Invalid table (\(table)) to delete.") }
        }
        
    }
    
    static func setDataVersion(dataVersion:Int16){
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        do {
            let settings = try DataManager.context.fetch(fetchRequest)
            
            if settings.isEmpty{
                if DataManager.debug{ print("Settings empty") }
                let newSettings = Settings(context: DataManager.context)
                newSettings.dataversion = dataVersion
            } else {
                if DataManager.debug{ print("Setting new dataVersion to \(dataVersion)") }
                let newSettings = try DataManager.context.fetch(fetchRequest)
                for setting in newSettings{
                    setting.dataversion = dataVersion
                }
            }
            //DataManager.saveContext()
            
        } catch {
            if DataManager.debug{ print("Could not get Settings.") }
        }
    }
    
    
    static func checkDataVersion(fromWeb:Bool = false, completion: @escaping ((_ version:Int16)->())){
        var dataVersion:Int16 = 0
        
        if fromWeb {
            CSVImporterManager.sharedInstance.downloadNewData(webURL: url_settings, table: "settings"){ (success) -> () in
                
                if success {
                    CSVImporterManager.sharedInstance.importCSV(dataSource: "external", table: "settings"){ (result) -> () in
                        if DataManager.debug{ print(Int16(result[0]["Dataversion"]!)!) }
                        dataVersion = Int16(result[0]["Dataversion"]!)!
                        completion(dataVersion)
                    }
                    
                } else{
                    // HANDLE FAILED DOWNLOAD
                }
                
            }
        } else{
            // Get local version
            let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
            
            do {
                
                let newSettings = try DataManager.context.fetch(fetchRequest)
                for setting in newSettings{
                    dataVersion = setting.dataversion
                }
                
            } catch {
                if DataManager.debug{ print("Could not get local version.") }
            }
            completion(dataVersion)
        }
         
    }
    
    static func setLastAccessed(bugName:String, matchBasis:String){
        let fetchRequest: NSFetchRequest<Bugs> = Bugs.fetchRequest()
        
        // Find all matching diagnostics with given name (expect just one)
        let predicate = NSPredicate(format:"name = %@", bugName)
        fetchRequest.predicate = predicate
        
        do {
            let bugs = try DataManager.context.fetch(fetchRequest)
            for bug in bugs{
                bug.last_accessed = NSDate()
                bug.match_basis = matchBasis
            }
        } catch {
            if DataManager.debug{ print("Could not get set last accessed for \(bugName)") }
        }
    }
    
    // Begin: Core functions
    static var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Microbiology_Reference")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
