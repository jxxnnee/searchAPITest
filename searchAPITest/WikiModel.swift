//
//  WikiModel.swift
//  serachAPITest
//
//  Created by 민경준 on 10/09/2019.
//  Copyright © 2019 민경준. All rights reserved.
//

import Foundation

class WikiDataSource {
    
    static let instance = WikiDataSource()
    
    var wikiURL = "https://en.wikipedia.org/w/api.php?"
 
    struct wikiData : Decodable {
        let searchWord : String
        let responseResult : [String]
        let resultRecommend : [String]
        let resultLinks : [String]
        
        init (from decoder : Decoder) throws {
            var container = try decoder.unkeyedContainer()
            searchWord = try container.decode(String.self)
            responseResult = try container.decode([String].self)
            resultRecommend = try container.decode([String].self)
            resultLinks = try container.decode([String].self)
        }
    }
    
}


