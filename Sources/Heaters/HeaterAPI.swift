//
//  HeaterAPI.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import Foundation

// MARK: - Class definition Convert to/from JSON and interact with Heater class
final class HeaterAPI {
    
    // MARK: - Methods
    private static func heatersToDictionary(_ heaters: [Heater]) -> [[String: Any]] {
        var heatersJson: [[String: Any]] = []
        for row in heaters {
            heatersJson.append(row.asDictionary())
        }
        return heatersJson
    }
    
    private static func allAsDictionary() throws -> [[String: Any]] {
        let heaters = Heater.all()
        return heatersToDictionary(heaters)
    }
    
    private static func all() throws -> String {
        return try allAsDictionary().jsonEncodedString()
    }
    
    // Handlers for requests
    static func getHeaters() throws -> String {
        return try all()
    }
    
    // Adds new heater
    static func saveHeater(_ dictionary: [String: Any]) throws -> [String: Any] {
        return  Heater.addNewObject(dictionary: dictionary)
    }
    
    // Updates parameters
    static func updateHeater(_ dictionary: [String: Any]) throws -> [String: Any] {
        return Heater.updateObject(dictionary: dictionary)
    }
    
    // Updates power state
    static func updateHeaterPower(_ dictionary: [String: Any]) throws -> [String: Any] {
        return Heater.handlePower(dictionary: dictionary)
    }
    
    // ESP8266 methods
    static func updateHeaterESP8266Power(_ dictionary: [String: Any]) throws -> [String: Any] {
        return Heater.handleESP8266Power(dictionary: dictionary)
    }
    
    static func updateHeaterESP8266RoomTepmerature(_ dictionary: [String: Any]) throws -> [String: Any] {
        return Heater.handleESP8266TemperatureUpdate(dictionary: dictionary)
    }
    
    static func updateHeateESP8266CoreTemperature(_ dictionary: [String: Any]) throws -> [String: Any] {
        return Heater.handleESP8266CoreTemperature(dictionary: dictionary)
    }
}