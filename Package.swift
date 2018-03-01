//
//  Package.swift
//  API
//
//  Copyright © 2017 Michał Warchał All rights reserved.
//

import PackageDescription

let package = Package(name: "api", targets: [], dependencies: [
    .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2),
    .Package(url: "https://github.com/SwiftORM/Postgres-StORM.git", majorVersion: 1),
    .Package(url: "https://github.com/PerfectlySoft/Perfect-Turnstile-PostgreSQL.git", majorVersion: 1),
    .Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 1, minor: 0),
    ])
