# Boscloner Project

# 1. Overview

The Boscloner App provides an easy to use interface to control and manage the boscloner hardware.

The hardware connects to the app via CoreBluetooth and badge data is stored using CoreData

## 1.1 App Architecture

### 1.1.1 Dependency Injection

The app uses SwiftUI and Combine. Dependency Injection is done by injecting objects into the SwiftUI environment. The struct `DependencyInjector` contains services used globally throughout the app. use the environment keypath `\.depInjector` to access this struct in a view.

To initialize the DI system, call `View.dependencyInjector(_:)` at the root level view. No argument defaults to the default injector. Specify `.preview` when using SwiftUI previews.

The services are wrapped in the dependency injector to help optimize SwiftUI runtime. If we directly injected the services as environment objects, views would be unable to access these services and pass them around without refreshing each time a change happens on the publishers. This would be terrible for performance.

With this design, we can easily access all environment objects via keypath (like `@Environment(\.depInjector.database) var database`). This import will NOT cause view updates when the database changes. If we want the view to receive updates, then we can use the overflow extension on `View.environmentObject(_:)` to do this by providing a keypath as the argument. This would look like `MyView().environmentObject(\.database)`. After this, we can access the dependency in `MyView` like this: `@EnvironmentObject var database: DatabaseService`.

For more information on this, take a look at the examples towards the bottom of `app-ios/Utilities/DependencyInjector.swift`

### 1.1.2 View Models

View models are used throughout the app's UI to manage state. Any view with mildly complex logic, a view model is used.

> In order to save time, we have created a PropertyWrapper `Dependency` which bypasses the SwiftUI DI system and directly accesses the default DependencyInjector. If passing the dependency to the view model through the view is too complicated, use this pattern instead.

### 1.1.3 App UI Layout

There are three tabs, Scan, Library, and Settings

#### Scanning
This tab handles starting and managing scanning session.

The first screen the user will see allows them to start a scanning session. In order to start a session, we need to know which facility the user is currently located at, and which badge type the user is scanning for. On this page, the user is able to "Search Nearby", which tells Thor to enable Discovery Mode and notify the app of which badges are seen nearby. These badge types will be marked with a radio icon. Once the user selects a facility and badge type, they will be able to start the session. If Thor is not connected, then a banner will be shown explaining that they must connect thor in order to scan badges. Tapping on this banner will take them to the device connection screen in the settings.

Once the session has started, They will be shown some stats at the top, and a feed of badges below. As badges are detected, they will be added to the feed. Newest badges are placed towards the top. If a badge that is already on the list has been found again, it will be moved back to the top, and the timestamp will reset. Tapping on the badge will modally present the Badge Detail Page (see below)

#### Library

The library organizes all of the user's clients, contacts, facilities and badges using a navigation view. The root view is the Client List.

##### Client List
Shows a list of all clients. From here they can select a client to navigate to the Client Detail Page, or tap on the + button to create a new client.

##### Client Detail Page
Shows all information about a client. This includes primary contact, list of facilities, and other contacts. Tapping on a contact takes the user to the Contact Detail Page. Tapping on a facility takes the user to the Facility Detail Page

##### Facility Detail Page
Shows all information about a facility. Users may select badges found here, add new access points, notes, and other things from here. Selecting a Badge modally presents the Badge Detail Page.

##### Badge Detail View
Shows info about the badge, it's type, allows the user to provide a custom name, or execute commands on Passport with this card.

The commands the user can execute include
- Brute Force
- Simulate
- Write

If passport is not connected, these actions are disabled with a message explaining that they need to connect thor.


## 1.2 Project Structure

The project is composed of a Swift Package, and an Xcode Project, all managed in an Xcode Workspace The Swift Package includes the following targets:

- Bluetooth Support
  A lightweight wrapper around CoreBluetooth to expose a combine interface for
  easy integration with the rest of the app

- Device Support
  Provides generic device support, **agnostic** to Thor and Passport. This package is responsible for communicating with the Devices using the Device DSL. This includes coding, reading and writing to Device properties, receiving notifications, and sending commands. This package builds on top of Bluetooth Support. Connecting to devices is managed by the `DeviceConnectionManager` class in this package.

- Device Services
  Provides a high level service API for managing Thor and Passport. This package builds upon Device Support, making getting data, observing, and controlling the devices simple directly from SwiftUI. The app should only need to interact with this package in most cases. Add new device specific functionality into this package

- Database
  Contains core models used throughout the app, along with a `DatabaseService` for accessing and managing the models. This package uses CoreData. This *should* be the only place where CoreData imports exist. CoreData should be an implementation detail that is irrelevant to the client of this package.

> *Note: The Passport Service and Thor Service targets are not used, in favor of the Device Services target. This includes both Thor and Passport Services.*

# 3. Domains

## 3.1 Core Data

The `Database` package includes all of the models and core data logic for the app. The use of CoreData should be encapsulated by the `Database` package. The `DatabaseService` exposes a CoreData agnostic API to be used throughout the app.

Each Model has a Core Data Managed Object representation, and a struct representation. Managed Objects are suffixed with `Entity`.

Be aware that queries return results, and they will NOT be updated when the user changes the underlying model (on edit page). In order to get updates, use a publisher (like `DatabaseService.clientPublisher(with:)`). This feature has not been implemented for all models. Follow this example to implement elsewhere.

### 3.1.1 Facility

A location where a user will be scanning for badges

### 3.1.2 Contact

Information for a person who is assoicated with a facility or client. This could include the store manager, the primary contact for the job, or anyone else.

### 3.1.3 Client

An organization who has one or more facilities and contacts.

### 3.1.4 Badge

A badge that has been collected by Thor. Each badge is associated with the Facility that the user is at when the badge was scanned.

### 3.1.5 Device

Represents a physical device, either Thor or Passport.

### 3.1.6 Access Point

A user entered point in the building where a badge can be used. Badges can be associated with access points to determine whether the badge can open the access point or not.

### 3.1.7 Scan Event

A record of when a badge was scanned by Thor. It is associated with the badge and device that recorded it.

### 3.1.8 Project

A project represents a collection of work done by the user. They will be able to select the active project, and all scan events and asoociated badges will be grouped in with the project.

## 3.2 Devices

There are two devices that the app connects to, Thor and Passport. Connection to these devices is managed by the `DeviceConnectionManager` class. This class stores the active thor and passport, and an updated list of available devices. More implementation needs to be done on this class to fully manage setting up new devices.

### 3.2.1 Bluetooth Stack Overview

The Bluetooth Stack:
  - CoreBluetooth (Apple)
  - BluetoothSupport
    - `BluetoothConnectionManager`
    - `BluetoothConnection` (wraps `CBPeripheral`)
  - DeviceSupport
    - `DeviceConnectionManager`
    - `DeviceConnection`
    - `DeviceManager`


### 3.2.2 Bluetooth Stack Breakdown

The devices use an HM19 bluetooth chip for connectivity. This chip comes pre programmed with a service UUID of `0xFFE0` and characteristic UUID of `0xFFE1`. This information is needed by the `BluetoothConnectionManager` to scan for the devices.

1. Initialize a `BluetoothConnectionManager`
2. Set `isEnabled` to `true` to start scanning for devices
3. Create a `DeviceConnectionManager` using the `BluetoothConnectionManager`
4. find available devices with `DeviceConnectionManager.availableDevices`
5. Once a device is found, create a manager with `DeviceConnection.getManager()`
6. At this point, the manager will be initialized but the device's connection will not yet be established. in order to establish this connection, call connect on the device manager's channel like so: `deviceManager.channel.connect()`
7. Wait for the device to connect. (check the manager's state, or bind to the state publisher. )
