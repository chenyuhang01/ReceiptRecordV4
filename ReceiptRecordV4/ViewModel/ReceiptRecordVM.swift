//
//  ReceiptRecordArrayVM.swift
//  ReceiptRecordV4
//
//  Created by Chen Yu Hang on 28/3/22.
//

import Foundation
import UIKit

class ReceiptRecordArrayVM {
    let receiptRecords: ReceiptRecords
    var receiptRecordVMList: [ReceiptRecordVM] = []
    var receiptRecordDoneVMList: [ReceiptRecordVM] = []
    var receiptRecordNotDoneVMList: [ReceiptRecordVM] = []
    var receiptRecordDoneDateDict: [String: [ReceiptRecordVM]] = [:]
    var receiptRecordNotDoneDateDict: [String: [ReceiptRecordVM]] = [:]
    var mode: Mode = .All
    var currentList: [ReceiptRecordVM]?
    var orderedDateList: [String]
    
    init(with receiptRecords: ReceiptRecords) {
        self.receiptRecords = receiptRecords
        var dateSet: Set = Set<String>()
        var notDoneDateSet: Set = Set<String>()
        
        for receiptRecord in self.receiptRecords {
            self.receiptRecordVMList.append(ReceiptRecordVM(with: receiptRecord))
            
            let vcModel: ReceiptRecordVM = self.receiptRecordVMList.last!
            if vcModel.getPropertiesNumericValue(type: .Price) != -1 {
                self.receiptRecordDoneVMList.append(vcModel)
                dateSet.insert(vcModel.getPropertiesValue(type: .PurchasedDate))
            } else {
                self.receiptRecordNotDoneVMList.append(vcModel)
                notDoneDateSet.insert(vcModel.getPropertiesValue(type: .PurchasedDate))
            }
        }
        
        // Distinguish the date
        for date in dateSet {
            receiptRecordDoneDateDict[date] = self.receiptRecordDoneVMList.filter{
                $0.getPropertiesValue(type: .PurchasedDate) == date
            }
        }
        
        for date in notDoneDateSet {
            receiptRecordNotDoneDateDict[date] = self.receiptRecordNotDoneVMList.filter{
                $0.getPropertiesValue(type: .PurchasedDate) == date
            }
        }
        
        orderedDateList = Array(self.receiptRecordDoneDateDict.keys).sorted(by: >)
        
        currentList = self.receiptRecordVMList
    }
}

extension ReceiptRecordArrayVM {
    func switchMode(mode: Mode) {
        self.mode = mode
        switch(mode) {
        case .All:
            self.currentList = self.receiptRecordVMList
            break
        case .Done:
            self.currentList = self.receiptRecordDoneVMList
            break
        case .NotDone:
            self.currentList = self.receiptRecordNotDoneVMList
            break
        }
    }
}

extension ReceiptRecordArrayVM  {
    func getCount() -> Int {
        return currentList!.count
    }
    
    func getAllCount() -> Int {
        return receiptRecordVMList.count
    }
    
    func getDoneCount() -> Int {
        return self.receiptRecordDoneVMList.count
    }
    
    func getNotDoneCount() -> Int {
        self.receiptRecordNotDoneVMList.count
    }
    
    func getDoneDateCount() -> Int {
        return self.receiptRecordDoneDateDict.count
    }
    
    func getNotDoneDateCount() -> Int {
        return self.receiptRecordNotDoneDateDict.count
    }
    
    func getOrderedDateListCount() -> Int {
        return self.orderedDateList.count
    }
    
    func getOrderedDateList() -> [String] {
        return self.orderedDateList
    }
}

extension ReceiptRecordArrayVM: Sequence {
    typealias Iterator = IndexingIterator<[ReceiptRecordVM]>

    func makeIterator() -> Iterator {
        return currentList!.makeIterator()
    }
    
    subscript(index: Int) -> ReceiptRecordVM {
        return currentList![index]
    }
}

extension ReceiptRecordArrayVM {
    enum Mode {
        case All
        case Done
        case NotDone
    }
}

class ReceiptRecordVM {
    let receiptRecord: ReceiptRecord
    let dateFormatter = DateFormatter()
    
    init(with receiptRecord: ReceiptRecord) {
        self.receiptRecord = receiptRecord
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
    }
    
    func getCreatedTime() -> String {
        return dateFormatter.string(from: self.receiptRecord.createdTime)
    }
    
    func getLastEditedTime() -> String {
        return dateFormatter.string(from: self.receiptRecord.lastEditedTime)
    }
    
    func getReportedBy() -> String {
        return self.receiptRecord.properties.reporter.plainText
    }

    func setUIImage(Image: UIImage) {
        self.receiptRecord.uiImage = Image
    }
    
    func clearUIImage() {
        self.receiptRecord.uiImage = nil
    }
    
    func getUIImage() -> UIImage? {
        return self.receiptRecord.uiImage
    }
    
    func setArchived() {
        self.receiptRecord.archived = true
    }
    
    func clearArchived() {
        self.receiptRecord.archived = false
    }
    
    func isArchived() -> Bool {
        return self.receiptRecord.archived
    }

    func setPropertiesValue(type: PropertiesType, value: String) {
        switch(type) {
            case .ImageUrl:
                self.receiptRecord.properties.imageUrl.url = value
                break
            case .Title:
                self.receiptRecord.properties.title.plainText = value
                break
            case .PurchasedDate:
                self.receiptRecord.properties.purchasedDate.dateInfo.startDate = dateFormatter.date(from: value)!
                break
            default:
                return
        }
    }
    
    func setPropertiesArrayStringValue(type: PropertiesType, valueList: [String]) {
        switch(type) {
            case .Category:
            self.receiptRecord.properties.category.valuesList = self.convertStringArrToMultiSelectOptionList(valueList: valueList)
                break
            case .Store:
                self.receiptRecord.properties.store.valuesList = self.convertStringArrToMultiSelectOptionList(valueList: valueList)
                break
            default:
                return
        }
    }
    
    func setPropertiesNumericValue(type: PropertiesType, value: Double) {
        switch(type) {
            case .Price:
                self.receiptRecord.properties.price.value = value
            default:
                return
        }
    }
    
    func getPropertiesValue(type: PropertiesType) -> String {
        switch(type) {
            case .ImageUrl:
                return self.receiptRecord.properties.imageUrl.url!
            case .Title:
                return self.receiptRecord.properties.title.plainText
            case .PurchasedDate:
                return dateFormatter.string(from: self.receiptRecord.properties.purchasedDate.dateInfo.startDate)
            default:
                return ""
        }
    }
    
    func getPropertiesArrayStringValue(type: PropertiesType) -> [String] {
        switch(type) {
            case .Category:
                return self.getStringArrayFromValueList(valueList: self.receiptRecord.properties.category.valuesList)
            case .Store:
                return self.getStringArrayFromValueList(valueList: self.receiptRecord.properties.store.valuesList)
            default:
                return []
        }
    }
    
    func getPropertiesNumericValue(type: PropertiesType) -> Double {
        switch(type) {
            case .Price:
                return self.receiptRecord.properties.price.value
            default:
                return 0
        }
    }
    
    func convertStringArrToMultiSelectOptionList(valueList: [String]) -> [MultiSelectOption] {
        var multiSelectOptionList: [MultiSelectOption] = []
        for valueStr in valueList {
            multiSelectOptionList.append(MultiSelectOption(name: valueStr))
        }
        
        return multiSelectOptionList
    }
    
    func getStringArrayFromValueList(valueList: [MultiSelectOption]) -> [String]{
        var stringArr: [String] = []
        
        for value in valueList {
            stringArr.append(value.name)
        }
        
        return stringArr
    }
}

extension ReceiptRecordVM {
    enum PropertiesType {
        case Price
        case ImageUrl
        case Title
        case PurchasedDate
        case Category
        case Store
    }
}
