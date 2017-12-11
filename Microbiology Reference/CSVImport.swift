//
//  CSVImport.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/13/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import Foundation
import CoreData
import CSVImporter

class CSVImporterManager {
    // Singleton (only instance of this class)
    
    static let sharedInstance = CSVImporterManager()
    
    // BEGIN: Asyncronous CSV functions
    var storedbugs = [String]()
    func importCSV(dataSource:String = "external", table:String = "diseases", completion: @escaping ((_ result:[[String:String]])->())) {
        
        var CSVData:[[String:String]] = []
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(table).csv")
        
        var fileURLImporter = CSVImporter<[String: String]>(url: destinationFileUrl)
        
        // On first app launch, the system will see an empty core data and want to fill it with the CSV (InitialData.csv) that shipped with the app rather than getting data from the web
        if dataSource == "internal"{
            let bundle = Bundle.main
            let path = bundle.path(forResource: table, ofType: "csv")
            fileURLImporter = CSVImporter<[String: String]>(path: path!)
        }
        
        fileURLImporter?.startImportingRecords(structure: { (headerValues) -> Void in
            //print("Headers: \(headerValues)") // => ["Name", "Type" ... ]
        }) { $0 }.onFail {
            
            if DataManager.debug{ print("The CSV file couldn't be read.") }
            
            }.onProgress { importedDataLinesCount in
                
                //print("\(importedDataLinesCount) lines were already imported.")
                
            }.onFinish { importedRecords in
                
                if DataManager.debug{ print("Did finish import with \(importedRecords.count) records.") }
                
                var recNum = 0
                // Fill bugDetails
                for record in importedRecords {
     
                    var cleanRecord = record
                    for nullObject in record {
                        if nullObject.value == ""{
                            cleanRecord.removeValue(forKey: nullObject.key)
                        }
                    }
                    
                    // Fill bugDetails
                    CSVData.append(cleanRecord)
                    
                    recNum += 1
                }
                
                //print(CSVData)
                completion(CSVData)

        }
        
    }
    
    func downloadNewData(webURL:String, table:String = "bugs", completion: @escaping ((_ success:Bool)->())){
        
        //var returnedData:[[String:String]] = []
        
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(table).csv")
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        let filePath = url.appendingPathComponent("\(table).csv")?.path
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath!) {
            if DataManager.debug{ print("\(table).csv already exists - removing it now in order to download a new version") }
            do {
                try fileManager.removeItem(atPath: filePath!)
            }
            catch let error as NSError {
                if DataManager.debug{ print("File could not be removed: \(error)") }
            }
        } else {
            if DataManager.debug{ print("\(table).csv does not exists - downloading it now") }
        }
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: webURL)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if DataManager.debug{ print("Successfully downloaded \(table).csv. Status code: \(statusCode)") }
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    if DataManager.debug{ print("Error creating a file \(destinationFileUrl) : \(writeError)") }
                }
                
                // Get data.csv data
                completion(true)
                
            } else {
                if DataManager.debug{ print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "unclear") }
                completion(false)
            }
        }
        task.resume()

    }
    // END: Asyncronous CSV functions
}
