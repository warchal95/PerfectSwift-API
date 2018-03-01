//
//  BasicController.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

// MARK: - Class definition
final class BasicController {
    var routes: [Route] {
        return [
            Route(method: .post, uri: "/heaters", handler: getHeatersById),
            Route(method: .post, uri: "/heater/create", handler: postNewHeater),
            Route(method: .put, uri: "/heater/update", handler: updateHeaterParams),
            Route(method: .post, uri: "/crash_reports", handler: getAllCrashReports),
            Route(method: .post, uri: "/crash_reports/add", handler: postNewCrashReport),
            Route(method: .post, uri: "/heater/changePowerState", handler: handlePowerStates),
            Route(method: .post, uri: "/heater/ESP8266/logs", handler: handleESP8266Logs),
            Route(method: .post, uri: "/heater/ESP8266/RoomTemperature", handler: handleESP8266RoomTemperature),
            Route(method: .post, uri: "/heater/ESP8266/CoreTemperature", handler: handleESP8266CoreTemperature),
            Route(method: .post, uri: "/heater/ESP8266/PowerState", handler: handleESP8266PowerState)
        ]
    }
}

// Crash Reports Handlers
extension BasicController {
    func getAllCrashReports(request: HTTPRequest, response: HTTPResponse) {
        do {
            let jsonEncodedString = try CrashReportsAPI.getReports()
            response.setBody(string: jsonEncodedString)
                    .setHeader(.contentType, value: "application/json")
                    .completed()
        } catch {
            setInvalidRequestForResponse(response, with: error)
        }
    }
    
    func postNewCrashReport(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try CrashReportsAPI.saveReport(dictionary))
        } catch {
            return
        }
    }
}

// Heater Handlers
extension BasicController {
    func getAllHeaters(request: HTTPRequest, response: HTTPResponse) {
        do {
            let jsonEncodedString = try HeaterAPI.getHeaters()
            response.setBody(string: jsonEncodedString)
                    .setHeader(.contentType, value: "application/json")
                    .completed()
        } catch {
            setInvalidRequestForResponse(response, with: error)
        }
    }
    
    func getHeatersById(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request),
              let userId = dictionary["User_id"] as? String
        else {
            response.completed(status: .badRequest)
            return
        }
        do {
            let heaterObject = Heater()
            var objectToFind = [String: Any]()
            
            objectToFind["userid"] = userId
            try heaterObject.find(objectToFind)
            
            var heatersDictionaryArray: [[String:Any]] = []
            for row in heaterObject.rows() {
                heatersDictionaryArray.append(row.asDictionary())
            }
            
            try response.setBody(json: heatersDictionaryArray)
                .setHeader(.contentType, value: "application/json")
                .completed()
        } catch {
            setInvalidRequestForResponse(response, with: error)
        }
    }
    
    func postNewHeater(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try HeaterAPI.saveHeater(dictionary))
        } catch {
            return
        }
    }
    
    func updateHeaterParams(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try HeaterAPI.updateHeater(dictionary))
        } catch {
            return
        }
    }
    
    func handlePowerStates(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try HeaterAPI.updateHeaterPower(dictionary))
        } catch {
            return
        }
    }
}

// MARK: - ESP8266 methods
fileprivate extension BasicController {
    func handleESP8266Logs(request: HTTPRequest, response: HTTPResponse) {
        let wireNotFound = request.params().contains { (key, value) -> Bool in
            return key.range(of:"wire not find") != nil
        }
        
        let didPowerOn = request.params().contains { (key, value) -> Bool in
            return key.range(of: "Power On") != nil
        }
        
        let didPowerOff = request.params().contains { (key, value) -> Bool in
            return key.range(of:"Power Off") != nil
        }
        
        if didPowerOn {
            print("Turned ON")
        }
        if didPowerOff {
            print("Turned OFF")
        }
        if wireNotFound {
            print("Wire not found")
        }
        
        setValidResponse(response: response, json: ["Success": "Data successfully received"])
    }

    func handleESP8266RoomTemperature(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try HeaterAPI.updateHeaterESP8266RoomTepmerature(dictionary))
        } catch {
            return
        }
    }
    
    func handleESP8266CoreTemperature(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try HeaterAPI.updateHeateESP8266CoreTemperature(dictionary))
        } catch {
            return
        }
    }
    
    func handleESP8266PowerState(request: HTTPRequest, response: HTTPResponse) {
        guard let dictionary = dictionaryFromRequest(request) else {
            response.completed(status: .badRequest)
            return
        }
        do {
            setValidResponse(response: response, json: try HeaterAPI.updateHeaterESP8266Power(dictionary))
        } catch {
            return
        }
    }
}

// Helper methods
extension BasicController {
    func dictionaryFromRequest(_ request: HTTPRequest) -> [String: Any]? {
        guard let json = request.postBodyString else { return nil }
        do {
            return try json.jsonDecode() as? [String: Any]
        } catch {
            return nil
        }
    }
    
    func setInvalidRequestForResponse(_ response: HTTPResponse, with error: Error) {
        response.setBody(string: "Error handling request \(error)")
                .completed(status: .internalServerError)
    }
    
    func setValidResponse(response: HTTPResponse, json: [String: Any]) {
        do {
            try response.setBody(json: json)
                        .setHeader(.contentType, value: "application/json")
                        .completed()
        } catch {
            setInvalidRequestForResponse(response,with: error)
        }
    }
}
