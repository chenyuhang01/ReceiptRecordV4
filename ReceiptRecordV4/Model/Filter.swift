//
//  Filter.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 7/3/22.
//

import Foundation

struct NumberFilter: Codable {
    
    var propertyName: String
    var number: Double
    
    enum ParentCodingKeys: String, CodingKey {
        case filter
    }
    
    enum CodingKeys: String, CodingKey {
        case property
        case number
    }
    
    enum NumberCodingKeys: String, CodingKey {
        case number = "equals"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        propertyName = try values.decode(String.self, forKey: .property)
        number =  try values.decode(Double.self, forKey: .number)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ParentCodingKeys.self)
        var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .filter)
        
        try nestedContainer.encode(propertyName, forKey: .property)
        
        var nestedNumberContainer = nestedContainer.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: .number)
        try nestedNumberContainer.encode(self.number, forKey: .number)
    }
    
}


