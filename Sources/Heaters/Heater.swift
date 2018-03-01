//
//  Heater.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import StORM
import PostgresStORM

// MARK: - Class definition
class Heater: PostgresStORM {
    
    // MARK: - Variables
    var id: Int = 0
    var userId: String = ""
    var name: String = ""
    var tempOutside: Int = 0
    var chargePercentage: Int = 0
    var producer: String = ""
    var isOn: Bool = true
    var serialNumber: String = ""
    var desiredTemperature: Int = 21
    var coreTemperature: Int = 300
    var actualRoomTemperature: Int = 22
    
    // Database table name
    override func table() -> String {
        return "heaters"
    }
    
    // StORM Mapping
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        userId = this.data["userid"] as? String ?? "0"
        name = this.data["name"] as? String ?? ""
        tempOutside = this.data["tempoutside"] as? Int ?? 0
        chargePercentage = this.data["chargepercentage"] as? Int ?? 0
        producer = this.data["producer"] as? String ?? ""
        isOn = this.data["ison"] as? Bool ?? true
        serialNumber = this.data["serialnumber"] as? String ?? "serial123"
        desiredTemperature = this.data["desiredtemperature"] as? Int ?? 21
        coreTemperature = this.data["coretemperature"] as? Int ?? 300
        actualRoomTemperature = this.data["actualroomtemperature"] as? Int ?? 22
    }
    
    // Helper method
    open func rows() -> [Heater] {
        var rows = [Heater]()
        for i in 0..<results.rows.count {
            let row = Heater()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    // Method which returns database parameters as Dictaionary
    open func asDictionary() -> [String: Any] {
        return [
            "Id": id,
            "User_id": userId,
            "Name": name,
            "Temp_outside": tempOutside,
            "Charge_Percentage": chargePercentage,
            "Producer": producer,
            "PowerState": isOn,
            "Serial_Number": serialNumber,
            "Desired_Temperature": desiredTemperature,
            "Core_Temperature": coreTemperature,
            "Actual_Room_Temperature": actualRoomTemperature
        ]
    }
    
    static func all() -> [Heater] {
        do {
            let heaterTableObject = Heater()
            try heaterTableObject.findAll()
            return heaterTableObject.rows()
        } catch {
            return Heater().rows()
        }
    }
    
    // Method to add new heater
    static func addNewObject(dictionary: [String: Any]) -> [String: Any] {
        guard
            let name = dictionary["Name"] as? String,
            let userId = dictionary["User_id"] as? String,
            let producer = dictionary["Producer"] as? String,
            let serialNumber = dictionary["Serial_Number"] as? String,
            let desiredTemperature = dictionary["Desired_Temperature"] as? Int
        else {
            return ["Error": "Dictionary Mapping error"]
        }
        let newObj = Heater()
        newObj.name = name
        newObj.tempOutside = 24
        newObj.chargePercentage = 80
        newObj.producer = producer
        newObj.userId = userId
        newObj.isOn = true
        newObj.desiredTemperature = desiredTemperature
        newObj.serialNumber = serialNumber
        newObj.coreTemperature = 300
        newObj.actualRoomTemperature = 22
        do {
            try newObj.save() { id in
                newObj.id = id as! Int
            }
            return newObj.asDictionary()
        }
        catch {
            return ["Error": "Object Saving Error"]
        }
    }
    
    // Method to update heater parameters from mobile apps
    static func updateObject(dictionary: [String: Any]) -> [String: Any] {
        guard let id = dictionary["Id"] as? Int,
              let userId = dictionary["User_id"] as? String
        else {
            return ["Erorr": "Id parameter is empty"]
        }
        do {
            let getObject = Heater()
            try getObject.get(id)
            guard let object = getObject.rows().first else  {
                return ["Error": "There is no object"]
            }
            if let name = dictionary["Name"] as? String { object.name = name }
            if let desiredTemperature = dictionary["Desired_Temperature"] as? Int { object.desiredTemperature = desiredTemperature }
            if let tempOutside = dictionary["Temp_Outside"] as? Int { object.tempOutside = tempOutside }
            if let chargePercentage = dictionary["Charge_Percentage"] as? Int { object.chargePercentage = chargePercentage }
            
            object.userId = userId
            try object.save()
            
            return object.asDictionary()
            
        } catch {
            return ["Erorr": "Handling object error"]
        }
    }
    
    // Method to handle power states
    static func handlePower(dictionary: [String: Any]) -> [String: Any] {
        guard let id = dictionary["Id"] as? Int,
              let userId = dictionary["User_id"] as? String,
              let isOn = dictionary["IsOn"] as? Bool
        else {
            return ["Erorr": "Id parameter is empty"]
        }
        do {
            let getObject = Heater()
            try getObject.get(id)
            guard let object = getObject.rows().first else {
                return ["Error": "There is no object"]
            }
            object.isOn = isOn
            object.userId = userId
            try object.save()
            print(object.asDictionary())
            return object.asDictionary()
        } catch {
            return ["Erorr": "Handling object error"]
        }
    }
    // MARK: - ESP8266 methods
    static func handleESP8266Power(dictionary: [String: Any]) -> [String: Any] {
        guard let serial = dictionary["SerialNumber"] as? String,
              let powerState = dictionary["PowerState"] as? Bool
        else {
            return ["Erorr": "Parameters Missing"]
        }
        do {
            let getObject = Heater()
            try getObject.get(serial)
            guard let object = getObject.rows().first else {
                return ["Error": "There is no object"]
            }
            object.isOn = powerState
            let id = object.userId
            object.userId = id
            
            try object.save()
            return object.asDictionary()
        } catch {
            return ["Erorr": "Handling object error"]
        }
    }
    
    static func handleESP8266TemperatureUpdate(dictionary: [String: Any]) -> [String: Any] {
        guard let serial = dictionary["SerialNumber"] as? String,
              let temperature = dictionary["RoomTemperature"] as? String,
              let roomTemperature = Int(temperature.numbers)
        else {
            return ["Erorr": "Parameters Missing"]
        }
        do {
            let getObject = Heater()
            try getObject.get(serial)
            guard let object = getObject.rows().first else {
                return ["Error": "There is no object"]
            }
            object.actualRoomTemperature = roomTemperature
            let id = object.userId
            object.userId = id
            try object.save()
            return object.asDictionary()
        } catch {
            return ["Erorr": "Handling object error"]
        }
    }
    
    static func handleESP8266CoreTemperature(dictionary: [String: Any]) -> [String: Any] {
        guard let serial = dictionary["SerialNumber"] as? String,
              let coreStringtemperature = dictionary["CoreTemperature"] as? String,
              let coreTemperature = Int(coreStringtemperature.numbers)
        else {
            return ["Erorr": "Parameters Missing"]
        }
        do {
            let getObject = Heater()
            try getObject.get(serial)
            guard let object = getObject.rows().first else {
                return ["Error": "There is no object"]
            }
            object.coreTemperature = coreTemperature
            let id = object.userId
            
            object.userId = id
            try object.save()
            
            return object.asDictionary()
            
        } catch {
            return ["Erorr": "Handling object error"]
        }
    }
}

fileprivate extension String {
    var numbers: String {
        return String(characters.filter { "0"..."9" ~= $0 })
    }
}
