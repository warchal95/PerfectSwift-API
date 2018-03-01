//
//  CrashReport.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import StORM
import PostgresStORM

// MARK: - Class definition
class CrashReport: PostgresStORM {

    // MARK: - Variables
    var id: Int = 0
    var userId: String = ""
    var heaterId: Int = 0
    var crash_description: String = ""
    
    // Database table name
    override func table() -> String {
        return "crashReports"
    }
    
    // StORM Mapping
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        userId = this.data["user_id"] as? String ?? "0"
        heaterId = this.data["heater_id"] as? Int ?? 0
        crash_description = this.data["reason"] as? String ?? ""
    }
    
    open func rows() -> [CrashReport] {
        var rows = [CrashReport]()
        
        for i in 0..<self.results.rows.count {
            let row = CrashReport()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    // Methods which returns database Table parameters as Dictaionary
    open func asDictionary() -> [String: Any] {
        return [
            "id": id,
            "user_id": userId,
            "heater_id": heaterId,
            "crash_description": crash_description
        ]
    }
    
    static func all() -> [CrashReport] {
        do {
            let getObj = CrashReport()
            try getObj.findAll()
            return getObj.rows()
        } catch {
            return CrashReport().rows()
        }
    }
    
    // MARK: - Method to add new report object
    static func addNewObject(dictionary: [String: Any]) -> [String: Any] {
        guard let userId = dictionary["User_id"] as? String,
              let crashDescription = dictionary["Crash_description"] as? String,
              let heaterId = dictionary["Heater_id"] as? Int
        else {
            return ["Error": "Dictionary Mapping error"]
        }
        let newObj = CrashReport()
        newObj.heaterId = heaterId
        newObj.crash_description = crashDescription
        newObj.userId = userId
        do {
            try newObj.save() { id in
                newObj.id = id as! Int
            }
            return newObj.asDictionary()
        }
        catch {
            return ["Error": "Crash Report Object Saving Error"]
        }
    }    
}
