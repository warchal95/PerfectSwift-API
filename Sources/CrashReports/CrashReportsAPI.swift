//
//  CrashReport.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import Foundation

// MARK: - Class definition
final class CrashReportsAPI {
    
    private static func reportsToDictionary(_ reports: [CrashReport]) -> [[String: Any]] {
        var reportsJson: [[String: Any]] = []
        
        for row in reports {
            reportsJson.append(row.asDictionary())
        }
        return reportsJson
    }
    
    private static func allAsDictionary() throws -> [[String: Any]] {
        return reportsToDictionary(CrashReport.all())
    }
    
    private static func all() throws -> String {
        return try allAsDictionary().jsonEncodedString()
    }
    
    // Handlers for requests
    static func getReports() throws -> String {
        return try all()
    }
    
    static func saveReport(_ dictionary: [String: Any]) throws -> [String: Any] {
        return  CrashReport.addNewObject(dictionary: dictionary)
    }
}
