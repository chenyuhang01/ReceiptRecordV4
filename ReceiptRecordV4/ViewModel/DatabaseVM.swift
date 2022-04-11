//
//  DatabaseVM.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 28/3/22.
//

import Foundation

class DatabaseVM {
    let database: Database
    let dateFormatter = DateFormatter()
    init(with database: Database) {
        self.database = database
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
    }
    
    func getFormattedEditedTime() -> String {
        let editedTime = self.database.lastEditedTime
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        let date = dateFormatter.date(from: editedTime)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date!)
    }
    
    func getProperties(type: PropertiesType) -> Database.Properties.Property? {
        switch(type) {
            case .Price:
                return self.database.properties.price
            case .Image:
                return self.database.properties.image
            case .Title:
                return self.database.properties.title
            case .PurchasedDate:
                return self.database.properties.purchaseDate
            case .Category:
                return self.database.properties.category
            case .Store:
                return self.database.properties.store
        }
    }
}

extension DatabaseVM {
    enum PropertiesType {
        case Price
        case Image
        case Title
        case PurchasedDate
        case Category
        case Store
    }
}
