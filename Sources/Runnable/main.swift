//
//  main.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import PostgresStORM
import PerfectRequestLogger
import PerfectTurnstilePostgreSQL
import TurnstilePerfect

RequestLogFile.location = "./requests.log"

// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfectRealm()

// POSTGRE setup
PostgresConnector.host = Credentials.PostgresHost
PostgresConnector.username = Credentials.PostgresUsername
PostgresConnector.password = Credentials.PostgresPassword
PostgresConnector.database = Credentials.PostgresDatabaseName
PostgresConnector.port = Credentials.PostgresPort

// Set up the Authentication table
let auth = AuthAccount()
try? auth.setup()

// Connect the AccessTokenStore
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

// Server setup
let server = HTTPServer()

// Register routes and handlers
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
server.addRoutes(authJSONRoutes)

// Basic Controller setup
let basicController = BasicController()
server.addRoutes(Routes(basicController.routes))

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()

var includedPaths: [String] = ["/heaters","/heater/create","/heater/update","/heater/changePowerState","/crash_reports","/crash_reports/add"]
authenticationConfig.include(includedPaths)
var excludedPaths: [String] = ["/api/v1/login","/api/v1/register","/api/v1/logout", "/heater/test"]
authenticationConfig.exclude(excludedPaths)

let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])
server.serverPort = 8080
server.documentRoot = "./webroot"

// Heater Database setup
let heaterSetupObj = Heater()
try? heaterSetupObj.setup()

let reportsSetupObj = CrashReport()
try? reportsSetupObj.setup()

// Server START
do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("Network error: ", err, msg)
}
