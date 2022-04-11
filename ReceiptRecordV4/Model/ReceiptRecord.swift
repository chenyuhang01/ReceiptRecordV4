//
//  ReceiptRecord.swift
//  ReceiptRecordV3
//
//  Created by Chen Yu Hang on 4/3/22.
//

import Foundation
import UIKit

typealias ReceiptRecord = ReceiptRecords.ReceiptRecord
typealias MultiSelectOption = ReceiptRecords.ReceiptRecord.Properties.MultiSelectProperty.MultiSelectInnerProperty

class ReceiptRecords: Codable {
    var records: [ReceiptRecord]

    class ReceiptRecord: NSObject, Codable {
        var id: String
        var createdTime: Date
        var lastEditedTime: Date
        var properties: Properties
        var archived: Bool
        
        // Other attirbutes that help encode with databaseId
        var databaseId: String?
        var uiImage: UIImage?
        
        static func generateReceiptRecord() -> ReceiptRecord? {
            let data = "{\"archived\": false,\"properties\":{\"Price\":{\"number\":0},\"Purchase Date\":{\"date\":{\"start\":\"2022-03-05\"}},\"Category\":{\"multi_select\":[]},\"Store\":{\"multi_select\":[]},\"Title\":{\"title\":[{\"text\":{\"content\":\"\"}}]},\"Image\":{\"url\":null},\"Reporter\":{\"rich_text\":[{\"text\":{\"content\":\"\"}}]}}}".data(using: .utf8)!
            do {
                let record = try JSONDecoder().decode(ReceiptRecord.self, from: data)
                return record
            } catch {
                return nil
            }
        }

        class Properties: Codable {
            var title: TitleProperty
            var purchasedDate: DateProperty
            var imageUrl: UrlProperty
            var store: MultiSelectProperty
            var category: MultiSelectProperty
            var price: NumberProperty
            var reporter: TextProperty
            
            class Property: Codable {
                var id: String = ""
                var type: String = ""
                
                enum CodingKeys: String, CodingKey {
                    case id
                    case type
                }
                
                required init(from decoder: Decoder) throws {
                    do {
                        let values = try decoder.container(keyedBy: CodingKeys.self)
                        id = try values.decode(String.self, forKey: .id)
                        type = try values.decode(String.self, forKey: .type)
                        
                    } catch {
                        id = ""
                        type = ""
                    }
                    
                }
            }
            
            class MultiSelectProperty: Property {
                var valuesList: [MultiSelectInnerProperty]
                
                enum MultiSelectCodingKeys: String, CodingKey {
                    case valuesList = "multi_select"
                }
                
                class MultiSelectInnerProperty: Codable {
                    var name: String
                    
                    enum MultiSelectInnerCodingKeys: String, CodingKey {
                        case name
                    }
                    
                    required convenience init(from decoder: Decoder) throws {
                        let values = try decoder.container(keyedBy: MultiSelectInnerCodingKeys.self)
                        self.init(name: try values.decode(String.self, forKey: .name))
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var values = encoder.container(keyedBy: MultiSelectInnerCodingKeys.self)
                        try values.encode(name, forKey: .name)
                    }
                    
                    init(name: String) {
                        self.name = name
                    }
                }
                
                required init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: MultiSelectCodingKeys.self)
                    valuesList = try values.decode([MultiSelectInnerProperty].self, forKey: .valuesList)
                    
                    try! super.init(from: decoder)
                }
                
                override func encode(to encoder: Encoder) throws {
                    var values = encoder.container(keyedBy: MultiSelectCodingKeys.self)
                    try values.encode(valuesList, forKey: .valuesList)
                }
                
                func addNewMultiSelectInnerProperty(newItem: MultiSelectInnerProperty) {
                    self.valuesList.append(newItem)
                }
            }
            
            class DateProperty: Property {
                var dateInfo: DateInfo
                class DateInfo: Codable {
                    var startDate: Date
                    var endDate: Date?
                    var timeZone: String?
                    
                    enum DateInfoCodingKeys: String, CodingKey {
                        case startDate = "start"
                        case endDate = "end"
                        case timeZone = "time_zone"
                    }
                    
                    required init(from decoder: Decoder) throws {
                        let values = try decoder.container(keyedBy: DateInfoCodingKeys.self)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone.current
                        dateFormatter.locale = Locale.current
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        let startDateStr = try values.decode(String.self, forKey: .startDate)
                        startDate = dateFormatter.date(from:startDateStr)!
                        
                        do {
                            let endDateStr: String? = try values.decode(String?.self, forKey: .endDate)
                            if let endDateStr = endDateStr {
                                endDate = dateFormatter.date(from:endDateStr)!
                            }
                        } catch {
                            endDate = Date()
                        }

                        do {
                            timeZone = try values.decode(String?.self, forKey: .timeZone)
                        } catch {
                            timeZone = ""
                        }
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var values = encoder.container(keyedBy: DateInfoCodingKeys.self)
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = TimeZone.current
                        dateFormatter.locale = Locale.current
                        
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        try values.encode(dateFormatter.string(from: self.startDate), forKey: .startDate)
                    }
                }
                
                enum DateCodingKeys: String, CodingKey {
                    case dateInfo = "date"
                }
                
                required init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: DateCodingKeys.self)
                    dateInfo = try values.decode(DateInfo.self, forKey: .dateInfo)
                    
                    try! super.init(from: decoder)
                }
                
                override func encode(to encoder: Encoder) throws {
                    var values = encoder.container(keyedBy: DateCodingKeys.self)
                    try values.encode(self.dateInfo, forKey: .dateInfo)
                }
            }
            
            class NumberProperty: Property {
                var value: Double

                enum NumberCodingKeys: String, CodingKey {
                    case value = "number"
                }

                required init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: NumberCodingKeys.self)
                    value = try values.decode(Double.self, forKey: .value)
                    try! super.init(from: decoder)
                }
                
                override func encode(to encoder: Encoder) throws {
                    var values = encoder.container(keyedBy: NumberCodingKeys.self)
                    try values.encode(value, forKey: .value)
                }
            }
            
            class UrlProperty: Property {
                var url: String?

                enum UrlCodingKeys: String, CodingKey {
                    case url
                }

                required init(from decoder: Decoder) throws {
                    let values = try decoder.container(keyedBy: UrlCodingKeys.self)
                    url = try values.decode(String?.self, forKey: .url)
                    try! super.init(from: decoder)
                }
                
                override func encode(to encoder: Encoder) throws {
                    var values = encoder.container(keyedBy: UrlCodingKeys.self)
                    try values.encode(url, forKey: .url)
                }
            }
            
            class TextProperty: Property {
                var plainText: String
                
                
                class TitleInternal: NSObject, Codable  {
                    var plainText: String
                    
                    enum TitleInternalCodingKeys: String, CodingKey {
                        case plainText = "plain_text"
                    }
                    
                    enum EncodingTitleInternalCodingKeys: String, CodingKey {
                        case plainText = "text"
                    }
                    
                    enum EncodingTitleInternalTextCodingKeys: String, CodingKey {
                        case plainText = "content"
                    }
                    
                    required convenience init(from decoder: Decoder) throws {
                        let values = try decoder.container(keyedBy: EncodingTitleInternalCodingKeys.self)
                        let nestedContainer = try values.nestedContainer(keyedBy: EncodingTitleInternalTextCodingKeys.self, forKey: .plainText)
                        self.init(plainText: try nestedContainer.decode(String.self, forKey: .plainText))
                    }
                    
                    init(plainText: String) {
                        self.plainText = plainText
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var values = encoder.container(keyedBy: EncodingTitleInternalCodingKeys.self)
                        var nestedContainer = values.nestedContainer(keyedBy: EncodingTitleInternalTextCodingKeys.self, forKey: .plainText)
                        try nestedContainer.encode(plainText, forKey: .plainText)
                    }
                }
                
                enum TitleCodingKeys: String, CodingKey {
                    case rich_text
                }
                
                required init(from decoder: Decoder) throws {
                    
                    let values = try decoder.container(keyedBy: TitleCodingKeys.self)
                    
                    let titleGroup = try values.decode([TitleInternal].self, forKey: .rich_text)
                    
                    // we are only interested in first object
                    if titleGroup.count > 0 {
                        let firstTitleGroup = titleGroup[0]
                        self.plainText = firstTitleGroup.plainText
                    } else {
                        self.plainText = ""
                    }
                    
                    try super.init(from: decoder)
                }
                
                override func encode(to encoder: Encoder) throws {
                    var values = encoder.container(keyedBy: TitleCodingKeys.self)
                    let titleInternal = TitleInternal(plainText: self.plainText)
                    let titleArray: [TitleInternal] = [titleInternal]
                    try values.encode(titleArray, forKey: .rich_text)
                }
            }
            
            class TitleProperty: Property {
                var plainText: String
                
                
                class TitleInternal: NSObject, Codable  {
                    var plainText: String
                    
                    enum TitleInternalCodingKeys: String, CodingKey {
                        case plainText = "plain_text"
                    }
                    
                    enum EncodingTitleInternalCodingKeys: String, CodingKey {
                        case plainText = "text"
                    }
                    
                    enum EncodingTitleInternalTextCodingKeys: String, CodingKey {
                        case plainText = "content"
                    }
                    
                    required convenience init(from decoder: Decoder) throws {
                        let values = try decoder.container(keyedBy: EncodingTitleInternalCodingKeys.self)
                        let nestedContainer = try values.nestedContainer(keyedBy: EncodingTitleInternalTextCodingKeys.self, forKey: .plainText)
                        self.init(plainText: try nestedContainer.decode(String.self, forKey: .plainText))
                    }
                    
                    init(plainText: String) {
                        self.plainText = plainText
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var values = encoder.container(keyedBy: EncodingTitleInternalCodingKeys.self)
                        var nestedContainer = values.nestedContainer(keyedBy: EncodingTitleInternalTextCodingKeys.self, forKey: .plainText)
                        try nestedContainer.encode(plainText, forKey: .plainText)
                    }
                }
                
                enum TitleCodingKeys: String, CodingKey {
                    case title
                }
                
                required init(from decoder: Decoder) throws {
                    
                    let values = try decoder.container(keyedBy: TitleCodingKeys.self)
                    
                    let titleGroup = try values.decode([TitleInternal].self, forKey: .title)
                    
                    // we are only interested in first object
                    if titleGroup.count > 0 {
                        let firstTitleGroup = titleGroup[0]
                        self.plainText = firstTitleGroup.plainText
                    } else {
                        self.plainText = ""
                    }
                    
                    try super.init(from: decoder)
                }
                
                override func encode(to encoder: Encoder) throws {
                    var values = encoder.container(keyedBy: TitleCodingKeys.self)
                    let titleInternal = TitleInternal(plainText: self.plainText)
                    let titleArray: [TitleInternal] = [titleInternal]
                    try values.encode(titleArray, forKey: .title)
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case title = "Title"
                case purchasedDate = "Purchase Date"
                case imageUrl = "Image"
                case category = "Category"
                case store = "Store"
                case price = "Price"
                case reporter = "Reporter"
            }
            
            required init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                title = try values.decode(TitleProperty.self, forKey: .title)
                purchasedDate = try values.decode(DateProperty.self, forKey: .purchasedDate)
                imageUrl = try values.decode(UrlProperty.self, forKey: .imageUrl)
                category = try values.decode(MultiSelectProperty.self, forKey: .category)
                store = try values.decode(MultiSelectProperty.self, forKey: .store)
                price = try values.decode(NumberProperty.self, forKey: .price)
                reporter = try values.decode(TextProperty.self, forKey: .reporter)
            }
            
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(title, forKey: .title)
                try container.encode(imageUrl, forKey: .imageUrl)
                try container.encode(price, forKey: .price)
                try container.encode(purchasedDate, forKey: .purchasedDate)
                try container.encode(store, forKey: .store)
                try container.encode(category, forKey: .category)
                // try container.encode(reporter, forKey: .reporter)
            }
        }
        
        enum DatabaseCodingKeys: String, CodingKey {
            case databaseId = "database_id"
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case createdTime = "created_time"
            case lastEditedTime = "last_edited_time"
            case properties = "properties"
            case databaseId = "parent"
            case archived = "archived"
        }
        
        func setEncodeWithDatabaseId(databaseId: String) {
            self.databaseId = databaseId
        }
        
        func unsetEncodeWithDatabaseId() {
            self.databaseId = nil
        }
        
        func setUIImage(uiImage: UIImage) {
            self.uiImage = uiImage
        }
        
        required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.properties = try values.decode(Properties.self, forKey: .properties)
            
            do {
                self.id = try values.decode(String.self, forKey: .id)
                
                let createdTimeStr = try values.decode(String.self, forKey: .createdTime)
                self.createdTime = createdTimeStr.toDate()!
                
                let lastEditedTimeStr = try values.decode(String.self, forKey: .lastEditedTime)
                self.lastEditedTime = lastEditedTimeStr.toDate()!
            } catch {
                self.id = ""
                self.createdTime = Date()
                self.lastEditedTime = Date()
            }
            
            self.archived = try values.decode(Bool.self, forKey: .archived)
        }
        
        func encode(to encoder: Encoder) throws {
            
            // Encode the properties object
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(properties, forKey: .properties)
            try container.encode(archived, forKey: .archived)
            
            // Encode the database ID if needed
            if let databaseId = databaseId {
                var nestedContainer = container.nestedContainer(keyedBy: DatabaseCodingKeys.self, forKey: .databaseId)
                try nestedContainer.encode(databaseId, forKey: .databaseId)
            }
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case records = "results"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        records = try values.decode([ReceiptRecord].self, forKey: .records)
        records = records.sorted(by: { $0.createdTime > $1.createdTime })
    }
}

extension ReceiptRecords {
    func insertNewReceiptRecord(receiptRecord: ReceiptRecord?) {
        guard receiptRecord != nil else { return }
        records.append(receiptRecord!)
        records = records.sorted(by: { $0.createdTime > $1.createdTime })
    }
    
    func removeExistingRecord(receiptRecord: ReceiptRecord?) {
        guard receiptRecord != nil else { return }
        var indexRemoved: Int = -1
        for ( index, record ) in self.records.enumerated(){
            if record.id == receiptRecord!.id {
                indexRemoved = index
                break
            }
        }
        
        if indexRemoved != -1 {
            self.records.remove(at: indexRemoved)
            records = records.sorted(by: { $0.createdTime > $1.createdTime })
        }
    }
    
    func getCount() -> Int {
        return records.count
    }
}

extension ReceiptRecords.ReceiptRecord.Properties.MultiSelectProperty: Sequence {
    typealias Iterator = IndexingIterator<[MultiSelectInnerProperty]>

    func makeIterator() -> Iterator {
        return valuesList.makeIterator()
    }
    
    subscript(index: Int) -> MultiSelectInnerProperty {
        return valuesList[index]
    }
}

extension ReceiptRecords: Sequence {
    typealias Iterator = IndexingIterator<[ReceiptRecord]>

    func makeIterator() -> Iterator {
        return records.makeIterator()
    }
    
    subscript(index: Int) -> ReceiptRecord {
        return records[index]
    }
}
