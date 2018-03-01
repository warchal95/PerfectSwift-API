# PerfectSwift-API

Welcome to the **PerfectSwift-API**. It's an API made with **PerfectSwift** framework and it's basic responsibility is to handle operations from mobile application and heater's micro controller.


### Tools & requirements

- Xcode 9.2
- Swift 3 or higher
- Postgres 9.6.5

### Configuration

Assuming the above tools are already installed, run the following commands after going to Package.swift directory:

- `swift package generate-xcodeproj`

It will generate the .xcodeproj and install required dependencies. Then simply open the project with Xcode, select **Runnable** as Your target, update **Credentials** class for Your database and ports inormations and run the project.
