//
//  Database.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 3/3/22.
//

import Foundation


typealias DatabaseMultiOptions = Database.Properties.MultiSelectProperty

class Database: Codable {
    var object: String
    var id: String
    var createdTime: String
    var lastEditedTime: String
    var lastEditedById: String
    var title: String?
    var properties: Properties
    
    // Nested structure for parsing title json array
    class Title: Codable {
        var type: String
        var plainText: String
        var content: String
        
        enum CodingKeys: String, CodingKey {
            case type
            case plainText = "plain_text"
            case content = "text"
        }
        
        enum ContentKeys: String, CodingKey {
            case content
            case link
        }
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            // parsing type json field
            type = try values.decode(String.self, forKey: .type)
            
            // parsing plain text json field
            plainText = try values.decode(String.self, forKey: .plainText)
            
            // parsing text nested json data structure
            let textContainer = try values.nestedContainer(keyedBy: ContentKeys.self, forKey: .content)
            
            // parse for content value from text Container
            content = try textContainer.decode(String.self, forKey: .content)
        }
    }
    
    class Properties: Codable {
        var price: PriceProperty
        var image: Property
        var title: Property
        var purchaseDate: Property
        var category: MultiSelectProperty
        var store: MultiSelectProperty
        
        class Property: Codable {
            var id: String
            var name: String
            var type: String
            
            enum CodingKeys: String, CodingKey {
                case id
                case name
                case type
            }
        }

        class PriceProperty: Property {
            var format: String
            
            enum PriceCodingKeys: String, CodingKey {
                case id
                case name
                case type
                case format = "number"
            }
            
            enum NumberCodingKeys: String, CodingKey {
                case format
            }
            
            required init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: PriceCodingKeys.self)
                let nestedNumberJson = try values.nestedContainer(keyedBy: NumberCodingKeys.self, forKey: .format)
                format = try nestedNumberJson.decode(String.self, forKey: .format)
                try! super.init(from: decoder)
            }
        }
        
        class MultiSelectProperty: Property {
            var options: [Options]?
            
            class Options: Codable {
                var id: String
                var name: String
                var color: String
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case name
                    case color
                }
            }
            
            enum MultiSelectCodingKeys: String, CodingKey {
                case id
                case name
                case type
                case options = "multi_select"
            }
            
            enum OptionsCodingKeys: String, CodingKey {
                case options = "options"
            }
            
            required init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: MultiSelectCodingKeys.self)
                
                let subsetOptions = try values.nestedContainer(keyedBy: OptionsCodingKeys.self, forKey: .options)
                
                options = try subsetOptions.decode([Options].self, forKey: .options)
                try! super.init(from: decoder)
            }
        }
        
        enum PropertiesByKey: String, CodingKey {
            case price = "Price"
            case image = "Image"
            case title = "Title"
            case purchaseDate = "Purchase Date"
            case category = "Category"
            case store = "Store"
        }
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: PropertiesByKey.self)
            price = try values.decode(PriceProperty.self, forKey: .price)
            image = try values.decode(Property.self, forKey: .image)
            title = try values.decode(Property.self, forKey: .title)
            purchaseDate = try values.decode(Property.self, forKey: .purchaseDate)
            category = try values.decode(MultiSelectProperty.self, forKey: .category)
            store = try values.decode(MultiSelectProperty.self, forKey: .store)
        }
    }

    
    // Top enumeration Keys
    enum CodingKeys: String, CodingKey {
        case object
        case id
        case createdTime = "created_time"
        case lastEditedTime = "last_edited_time"
        case lastEditedById = "last_edited_by"
        case title
        case properties = "properties"
    }
    
    // Last edited Id enumeration Keys
    enum LastEditedByKeys: String, CodingKey {
        case id
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        object = try values.decode(String.self, forKey: .object)
        id = try values.decode(String.self, forKey: .id)
        createdTime = try values.decode(String.self, forKey: .createdTime)
        lastEditedTime = try values.decode(String.self, forKey: .lastEditedTime)
        
        
        // Last Edited By Key-Pair
        // Get the nested container of the top CodingKeys
        // results is the last_edited_by json nested Json pair
        // For example, nested container is refering to the child element of the last_edited_by field
        // KeyedBy will refers to the LastEditedByKeys enumeration to for it's respecctive child element key value
        // For Key will refers to the last_edited_by key value in the top container
        // After getting the nested container, all the respective key-value pair has established
        // we now can using decode to decode each child value
        // decode String value and forKey ( refers to which key it is parsing now, here we are parsing
        // the id element of the last_edited_by nested json string
        ///
        ///  "last_edited_by": {
        ///     "object": "user",
        ///     "id": "cf63e1cc-6387-49ff-97af-aa28a896c9ac"
        ///  }
        let lastEditedBy = try values.nestedContainer(keyedBy: LastEditedByKeys.self, forKey: .lastEditedById)
        lastEditedById = try lastEditedBy.decode(String.self, forKey: .id)
        
        
        // Use Title Codable to decode title json array
        let titleGroup: [Title] = try values.decode([Title].self, forKey: .title)
        
        // We only interested in the first one
        if titleGroup.count > 0 {
            title = titleGroup[0].content
        }
        
        // parsing property json group
        properties = try values.decode(Properties.self, forKey: .properties)
    }
}
