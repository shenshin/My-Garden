//
//  WikiAPI.swift
//  MyGarden
//
//  Created by Алесь Шеншин on 29/01/2019.
//  Copyright © 2019 Shenshin. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WikiAPI {
    
    private let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    private var parameters : [String:String] {
        get{
            return [
                "format" : "json",
                "action" : "query",
                "prop" : "extracts",
                "exintro" : "",
                "explaintext" : "",
                "titles" : self.flowerName,
                "indexpageids" : "",
                "redirects" : "1",
                ]
        }
    }
    var flowerName: String = ""
    
    public func getFlowerInfo(_ completion: @escaping (String)->Void){
        
        AF.request(self.wikipediaURl, method: .get, parameters: self.parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Got the Wikipedia Info")

                if let data = response.result.value {
                    print("Got JSON data")
                    let dataJSON = JSON(data)
                    let pageID = dataJSON["query"]["pageids"][0].stringValue
                    
                    let plantInfo = dataJSON["query"]["pages"][pageID]["extract"].stringValue
                    
                    completion(plantInfo)
                    
                } else {
                    print("Received an empty response from the Wikipedia server")
                }

            } else {
                print("Error: \(response.result.error.debugDescription)")
            }
        }
    }
    
    
}
