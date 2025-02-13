//
//  INDIWebManagerClient.swift
//  INDIClient
//
//  Created by Yoshio Kimura, Studio Parsec LLC on 2024/10/04.
//

import Foundation

/// Access INDI Web Manager class.
public actor INDIWebManagerClient {
    internal struct INDIWebManagerDriverLabel: Codable, Hashable {
        public var label: String
    }
    
    // MARK: - Private Property
    private var _host: String
    private var _port: UInt16
    private var _timeout: TimeInterval
    private var _profiles: [INDIWebManagerProfile]
    private var _driverGroups: [String]
    private var _drivers: [INDIWebManagerDriverInfo]
    private var _connected: Bool
    
    /// Initializer for the class that accesses the INDI Web Manager.
    /// - Parameters:
    ///  - host: The host name or IP address of the computer runnning INDI Web Manager.
    ///  - port: Port number that INDI Web Manager is listening on.
    ///  - timeout: Time to wait for host response.
    public init(host: String, port: UInt16, timeout: TimeInterval = 3.0) {
        self._host = host
        self._port = port
        self._timeout = timeout
        self._profiles = []
        self._driverGroups = []
        self._drivers = []
        self._connected = false
    }
    
    // MARK: - Computed Property.
    public var timeout: TimeInterval {
        get { self._timeout }
        set { self._timeout = newValue }
    }
    
    public var isConnected: Bool {
        self._connected
    }
    
    public var driverGroups: [String] {
        self._driverGroups
    }
    
    public var drivers: [INDIWebManagerDriverInfo] {
        self._drivers
    }
    
    public var profiles: [INDIWebManagerProfile] {
        self._profiles
    }
    
    // MARK: - Method
    /// Set hostname, port number and timeout for connection server.
    /// - Parameters:
    ///  - host: server host name.
    ///  - port: server port number.
    ///  - timeout: connection timeout. Default 3sec.
    public func setServer(host: String, port: UInt16, timeout: TimeInterval = 3.0) {
        self._host = host
        self._port = port
        self._timeout = timeout
    }
    
    /// Get all profiles registered in INDI Web Manager.
    /// - Returns: Array of registered profiles.
    public func getAllProfiles() async throws -> [INDIWebManagerProfileInfo] {
        var profileList: [INDIWebManagerProfileInfo] = []
        
        // accessing the INDI Web Manager.
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/profiles")

        // If access is normal and data exists, convert JSON format data to INDIWebManagerProfileInfo array.
        if result, let data = data {
            profileList = try JSONDecoder().decode([INDIWebManagerProfileInfo].self, from: data)
        }
        
        return profileList
    }
    
    /// Get all driver group name.
    /// - Returns: Array of driver group names.
    public func getAllDriverFamilies() async throws -> [String] {
        var driverGroups: [String] = []
        
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/drivers/groups")
        
        if result, let data = data {
            driverGroups = try JSONDecoder().decode([String].self, from: data)
        }
        
        return driverGroups
    }
    
    /// Get all driver information.
    /// - Returns: Array of driver information.
    public func getAllDrivers() async throws -> [INDIWebManagerDriverInfo] {
        var drivers: [INDIWebManagerDriverInfo] = []
        
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/drivers")
        
        if result, let data = data {
            drivers = try JSONDecoder().decode([INDIWebManagerDriverInfo].self, from: data)
        }
        
        return drivers
    }
    
    /// Get one profile registered in INDI Web Manager.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfileInfo
    /// - Returns: One registered profile.
    public func getOneProfile(profile: INDIWebManagerProfileInfo) async throws -> INDIWebManagerProfileInfo? {
        var profileInfo: INDIWebManagerProfileInfo? = nil
        
        // Accessing the INDI Web Manager.
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/profiles/<item>".replacingOccurrences(of: "<item>", with: profile.name))
        
        // If access is normal and data exists, convert JSON format data to INDIWebManagerProfileInfo
        if result, let data = data {
            profileInfo = try JSONDecoder().decode(INDIWebManagerProfileInfo.self, from: data)
        }
        
        return profileInfo
    }
    
    /// Add new profile in INDI Web Manager.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfileInfo.
    /// - Returns: result.
    public func addProfile(profile: INDIWebManagerProfileInfo) async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/profiles/<name>".replacingOccurrences(of: "<name>", with: profile.name))
        
        return result
    }
    
    /// Delete profile in INDI Web Manager.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfileInfo
    /// - Returns: result.
    public func deleteProfile(profile: INDIWebManagerProfileInfo) async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "DELETE", api: "/api/profiles/<name>".replacingOccurrences(of: "<name>", with: profile.name))
        
        return result
    }
    
    /// Update profile in INDI Web Manager.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfileInfo
    /// - Returns: result
    public func updateProfile(profile: INDIWebManagerProfileInfo) async throws -> Bool {
        let jsonProfile = try JSONEncoder().encode(profile)
        let (result, _) = try await getINDIWebManagerResponse(method: "PUT", api: "/api/profiles/<name>".replacingOccurrences(of: "<name>", with: profile.name), sendData: jsonProfile)
        
        return result
    }
    
    /// Add drivers to existing profile.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfileInfo
    ///  - useDriverLabels: Array of INDI Web Manager driver labels.
    /// - Returns: result.
    public func saveDriversToProfile(profile: INDIWebManagerProfileInfo, useDriverLabels: [String]) async throws -> Bool {
        let driverLabelList = useDriverLabels.map({ INDIWebManagerDriverLabel(label: $0) })
        let jsonDrivers = try JSONEncoder().encode(driverLabelList)
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/profiles/<name>/drivers".replacingOccurrences(of: "<name>", with: profile.name), sendData: jsonDrivers)
        
        return result
    }
    
    /// Get driver labels of specific profile.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfile
    /// - Returns: Array of driver label.
    public func getDriverLabels(profile: INDIWebManagerProfileInfo) async throws -> [String] {
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/profiles/<item>/labels".replacingOccurrences(of: "<item>", with: profile.name))
        
        if result, let data = data {
            let driverLabelList = try JSONDecoder().decode([INDIWebManagerDriverLabel].self, from: data)
            return driverLabelList.map({ $0.label })
        }
        return []
    }
    
    /// Get remote drivers of specific profile.
    /// - Parameters:
    ///  - profile: INDIWebManagerProfileInfo.
    /// - Returns: Array of remote driver labels.
    public func getRemoteDrivers(profile: INDIWebManagerProfileInfo) async throws -> [String] {
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/profiles/<item>/remote".replacingOccurrences(of: "<item>", with: profile.name))
        
        if result, let data = data {
            let remoteLabelList = try JSONDecoder().decode([String : String].self, from: data)
            return Array(remoteLabelList.values)
        }
        return []
    }
    
    /// Get server status.
    /// - Returns: server status.
    public func getServerStatus() async throws -> INDIWebManagerServerStatus? {
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/server/status")

        if result, let data = data {
            let status = try JSONDecoder().decode([INDIWebManagerServerStatus].self, from: data)
            return status.first
        }
        return nil
    }
    
    /// Get running driver list.
    /// - Returns: running driver list.
    public func getRunningDriversList() async throws -> [INDIWebManagerDriverInfo] {
        let (result, data) = try await getINDIWebManagerResponse(method: "GET", api: "/api/server/drivers")
        
        if result, let data = data {
            return try JSONDecoder().decode([INDIWebManagerDriverInfo].self, from: data)
        }
        return []
    }
    
    /// Start server.
    /// - Parameters:
    ///  - profileName: INDIWebManager profile name when starting the server.
    /// - Returns: result.
    public func startServer(profileName: String) async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/server/start/<name>".replacingOccurrences(of: "<name>", with: profileName))
        return result
    }
    
    /// Stop server.
    /// - Returns: result.
    public func stopServer() async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/server/stop")
        return result
    }
    
    /// Start the specific driver.
    /// - Parameters:
    ///  - driver: INDIWebManagerDriverInfo to start.
    /// - Returns: result.
    public func startDriver(driver: INDIWebManagerDriverInfo) async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/drivers/start/<label>".replacingOccurrences(of: "<label>", with: driver.label))
        return result
    }
    
    /// Restart the specific driver.
    /// - Parameters:
    ///  - driver: INDIWebManagerDriverInfo to restart.
    /// - Returns: result.
    public func restartDriver(driver: INDIWebManagerDriverInfo) async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/drivers/restart/<label>".replacingOccurrences(of: "<label>", with: driver.label))
        return result
    }
    
    /// System reboot.
    /// - Returns: result.
    public func systemReboot() async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/system/reboot")
        return result
    }
    
    /// System power off.
    /// - Returns: result.
    public func systemPowerOff() async throws -> Bool {
        let (result, _) = try await getINDIWebManagerResponse(method: "POST", api: "/api/system/poweroff")
        return result
    }
    
    /// Get all profile details.
    /// - Returns: Array of INDIWebManagerProfiles
    public func getAllProfileDetails() async throws -> [INDIWebManagerProfile] {
        var profileDetails: [INDIWebManagerProfile] = []
        
        let profiles = try await getAllProfiles()
        for profile in profiles {
            _ = try await startServer(profileName: profile.name)
            let useDriverLabels = try await getDriverLabels(profile: profile)
            _ = try await stopServer()
            profileDetails.append(INDIWebManagerProfile(profileInfo: profile, useDriverLabels: useDriverLabels))
        }
        
        return profileDetails
    }
}

// MARK: - High Level API
extension INDIWebManagerClient {
    public func checkConnect() async -> Bool {
        do {
            // Communication confirmation wieth INDI Web Manager.
            _ = try await getServerStatus()
            
            // Get the driver group and drivers, profiles.
            _driverGroups = try await getAllDriverFamilies()
            _drivers = try await getAllDrivers()
            _profiles = try await getAllProfileDetails()
            _connected = true
            
            return true
        } catch {
            print("INDIWebManagerClient.checkConnect: \(error).")
        }
        
        return false
    }
    
    public func refreshAllProfileDetails() async -> Bool {
        do {
            _profiles = try await getAllProfileDetails()
            return true
        } catch {
            print("INDIWebManagerClient.refreahAllProfileDetails: \(error).")
            return false
        }
    }
    
    public func saveProfileInformation(profile: INDIWebManagerProfile) async -> Bool {
        do {
            // Check if the profile is already registered.
            if _profiles.firstIndex(where: { $0.profileInfo.name == profile.profileInfo.name }) == nil {
                // If not registered, add your profile.
                _ = try await addProfile(profile: profile.profileInfo)
            }
            
            // Update your profile.
            _ = try await updateProfile(profile: profile.profileInfo)
            
            // Save the driver to be registered in the profile.
            _ = try await saveDriversToProfile(profile: profile.profileInfo, useDriverLabels: profile.useDriverLabels)
            
            return true
        } catch {
            print("INDIWebManagerClient.saveProfiileInformation: \(error).")
            return false
        }
    }
    
    public func startObservationSystem(profileName: String) async -> Bool {
        do {
            // Check if the server is running.
            let serverStatus = try await getServerStatus()
            if serverStatus?.status.lowercased() == "true" {
                _ = try await stopServer()
            }
            
            // Start the server with the specified profile.
            _ = try await startServer(profileName: profileName)
            
            return true
        } catch {
            print("INDIWebManagerClient.startObservationSystem: \(error).")
            return false
        }
    }
    
    public func stopObservationSystem() async -> Bool {
        do {
            _ = try await stopServer()
            return true
        } catch {
            print("INDIWebManagerClient.stopObservationSystem: \(error).")
            return false
        }
    }
}

// MARK: - Helper method
extension INDIWebManagerClient {
    /// Handles APi access and response to the INDI Web Manager.
    /// - Parameters:
    ///  - method: HTTP method.
    ///  - api: INDI Web Manager API.
    ///  - sendData: Send data required for INDI Web Manager API.
    /// - Throws: HTTP access error.
    /// - Returns: Communication result and response data.
    private func getINDIWebManagerResponse(method: String, api: String, sendData: Data? = nil) async throws -> (Bool, Data?) {
        var result: Bool = false
        var replyData: Data? = nil
        var response: URLResponse
        let request = createURLRequest(httpProtocol: "http", method: method, api: api, sendData: sendData)
        
        // Accessing the INDI Web Manager.
        (replyData, response) = try await URLSession.shared.data(for: request)
        
        // Check if access is normal.
        if let response = response as? HTTPURLResponse, response.statusCode == 200 {
            result = true
        }
        
        return (result, replyData)
    }
    
    private func createURLRequest(httpProtocol: String, method: String, api: String, sendData: Data? = nil) -> URLRequest {
        var request = URLRequest(url: URL(string: "\(httpProtocol)://\(_host):\(_port)\(api)")!)
        
        // common settings for URLRequest.
        request.timeoutInterval = _timeout
        request.httpMethod = method
        
        // Settings headers and body when there is data to send,
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let data = sendData {
            request.addValue("\(data.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = data
        }
        
        return request
    }
}
