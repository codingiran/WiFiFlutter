import Cocoa
import CoreLocation
import CoreWLAN
import FlutterMacOS
import Network
import SystemConfiguration

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func applicationDidFinishLaunching(_ notification: Notification) {
        requestLocation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connectWifi()
        }
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func requestLocation() {
        let manager = CLLocationManager()
        guard CLLocationManager.locationServicesEnabled() else { return }
        guard CLLocationManager.authorizationStatus() != .authorized else { return }
        manager.delegate = self
        manager.requestLocation()
    }

    private func connectWifi() {
        let ssid = "ZenNet-Radius-Test"
//        let ssid = "Zenlayer-NT-PSK-Turbo"
        let username = "iran.qiu@zenlayer.com"
        let password = "1qaz@WSX"
        guard let wifiInterface = CWWiFiClient.shared().interface() else {
            return
        }
        do {
            guard let ssidData = ssid.data(using: .utf8) else { return }
            let networks = try wifiInterface.scanForNetworks(withSSID: ssidData)
            for network in networks {
                print("ssid is \(String(describing: network.ssid)), bssid is \(String(describing: network.bssid)), desc is \(String(describing: network.description))")
            }
            let network = networks.first {
                $0.ssid == ssid
            }

            guard let network else { return }
            let identity = addCertificate(certificate: base64.replacingOccurrences(of: "\n", with: ""), passphrase: "")
            try wifiInterface.associate(toEnterpriseNetwork: network, identity: nil, username: username, password: password)
        } catch {
            debugPrint(error)
        }
    }

    let base64 = """
    MIIENjCCAx6gAwIBAgIBATANBgkqhkiG9w0BAQsFADCBkzELMAkGA1UEBhMCRlIx
    DzANBgNVBAgMBlJhZGl1czESMBAGA1UEBwwJU29tZXdoZXJlMRUwEwYDVQQKDAxF
    eGFtcGxlIEluYy4xIDAeBgkqhkiG9w0BCQEWEWFkbWluQGV4YW1wbGUub3JnMSYw
    JAYDVQQDDB1FeGFtcGxlIENlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0yNDA4MzAw
    OTAwMDBaFw0yNDEwMjkwOTAwMDBaMHwxCzAJBgNVBAYTAkZSMQ8wDQYDVQQIDAZS
    YWRpdXMxFTATBgNVBAoMDEV4YW1wbGUgSW5jLjEjMCEGA1UEAwwaRXhhbXBsZSBT
    ZXJ2ZXIgQ2VydGlmaWNhdGUxIDAeBgkqhkiG9w0BCQEWEWFkbWluQGV4YW1wbGUu
    b3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsqjXj9DCnrnwAOzl
    1Gf1nu9U/EXMcneTN8HgPx/4p1VHuM4r7CX4smNNSDxk7651w9xpdBuyzzUorpes
    kVblfIwGlUlKgy+/euu6v7BwavtzeeTkLPIoPXcNCe7/VIBj7ZwRm+xLD9XgSUdC
    DIFrlKoLDU6ZVIokbG0hx0TdYQxy9NmSYRfa535NgYVPLq8vdB+icQ+v93Xb5Qo3
    HpSyBAQPuNZ30YHyIvL0Mr5d8kgXyomdl0R+rLzsaB+MnvpPG7g1uo15UKzO8a0w
    K9kFCsotzxRIHMvbiAQpLnd5qnyso+v7u5pJmy30a1/pBeg8qun471NQ+UUfVDSi
    GixuUwIDAQABo4GqMIGnMBMGA1UdJQQMMAoGCCsGAQUFBwMBMDYGA1UdHwQvMC0w
    K6ApoCeGJWh0dHA6Ly93d3cuZXhhbXBsZS5jb20vZXhhbXBsZV9jYS5jcmwwGAYD
    VR0gBBEwDzANBgsrBgEEAYK+aAEDAjAdBgNVHQ4EFgQUwQaZJXt3+QYORntJCq4r
    41LxF1cwHwYDVR0jBBgwFoAU50llGN/uR7WVZFkpM5EJFe3CH2QwDQYJKoZIhvcN
    AQELBQADggEBAI4y9l2XYm4ckJAut/6vs2jEmDHcqZSaooG2PAQsXyDk0LlR+5uI
    7keK9KPvAGhsebyamp3Hy1hrxv/sUtp/EVtXN88+tFL/GqdiB5VLH9+yBqjfHJj2
    sdUeGju8sjjzI9+DRMUUjdcDy3IIcMHRptrOhnJoOHV4vfargK6VbYT70EzzAuAj
    /Fm3SG7ouNhKvRveonU2/yMSoL/L7pMY4eV8fNSzVujuBGugoz9G8uBs6+tgmKjv
    blbrfHrYdBXnM7x4brlL+4M/dlv1h3r0k/mNjZz31Uu3tV6XV2cxANyoBbTn9Wfi
    Miw8bIJrWpww9oZ4VR9A0orad/YGvccHJJk=
    """

    private func addCertificate(certificate: String) throws -> SecCertificate {
        let teamID = "2ZZ5PPLHRY"

        guard let data = Data(base64Encoded: certificate) else {
            throw EAPConfiguratorError.failedToBase64DecodeCertificate
        }
        guard let certificateRef = SecCertificateCreateWithData(kCFAllocatorDefault, data as CFData) else {
            throw EAPConfiguratorError.failedToCreateCertificateFromData
        }

        let label = try label(for: certificateRef)

        let addquery: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecValueRef as String: certificateRef,
            kSecAttrLabel as String: label,
            kSecReturnRef as String: kCFBooleanTrue!,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
            // kSecReturnPersistentRef as String: kCFBooleanTrue!, // Persistent refs cause an error (invalid EAP config) when installing the profile
            kSecAttrAccessGroup as String: "\(teamID).com.apple.networkextensionsharing"
        ]
        var item: CFTypeRef?
        var status = SecItemAdd(addquery as CFDictionary, &item)

        // TODO: remove this, and always use the "failsafe"?
        if status == errSecSuccess && item != nil {
            return (item as! SecCertificate)
        }

        guard status == errSecSuccess || status == errSecDuplicateItem else {
            throw EAPConfiguratorError.failedSecItemAdd(status)
        }

        // FAILSAFE:
        // Instead of returning here, you can also run the code below
        // to make sure that the certificate was added to the KeyChain.
        // This is needed if errSecDuplicateItem was returned earlier.
        // TODO: should we use this flow always?

        let getquery: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecAttrLabel as String: label,
            kSecReturnRef as String: kCFBooleanTrue!,
            // kSecReturnPersistentRef as String: kCFBooleanTrue!, // Persistent refs cause an error (invalid EAP config) when installing the profile
            kSecAttrAccessGroup as String: "\(teamID).com.apple.networkextensionsharing"
        ]
        status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess && item != nil else {
            throw EAPConfiguratorError.failedSecItemCopyMatching(status)
        }

        return (item as! SecCertificate)
    }

    private func label(for certificateRef: SecCertificate) throws -> String {
        var commonNameRef: CFString?
        let status: OSStatus = SecCertificateCopyCommonName(certificateRef, &commonNameRef)
        if status == errSecSuccess {
            return commonNameRef! as String
        }

        guard let rawSubject = SecCertificateCopyNormalizedSubjectSequence(certificateRef) as? Data else {
            throw EAPConfiguratorError.failedToCopyCommonNameOrSubjectSequence
        }

        return rawSubject.base64EncodedString(options: [])
    }

    func addCertificate(certificate: String, passphrase: String) -> SecIdentity? {
        let options = [kSecImportExportPassphrase as String: passphrase]
        var rawItems: CFArray?
        let certBase64 = certificate
        let data = Data(base64Encoded: certBase64)!
        let statusImport = SecPKCS12Import(data as CFData, options as CFDictionary, &rawItems)
        guard statusImport == errSecSuccess else {
            NSLog("☠️ addClientCertificate: SecPKCS12Import: " + String(statusImport))
            return nil
        }
        let items = rawItems! as! [[String: Any]]
        let firstItem = items[0]
        if items.count > 1 {
            NSLog("😱 addClientCertificate: SecPKCS12Import: more than one result - using only first one")
        }

        // Get the chain from the imported certificate
        let chain = firstItem[kSecImportItemCertChain as String] as! [SecCertificate]
        for (index, cert) in chain.enumerated() {
            let certData = SecCertificateCopyData(cert) as Data

            if let certificateData = SecCertificateCreateWithData(nil, certData as CFData) {
                let addquery: [String: Any] = [
                    kSecClass as String: kSecClassCertificate,
                    kSecValueRef as String: certificateData,
                    kSecAttrLabel as String: "getEduroamCertificate" + "\(index)"
                ]

                let statusUpload = SecItemAdd(addquery as CFDictionary, nil)

                guard statusUpload == errSecSuccess || statusUpload == errSecDuplicateItem else {
                    NSLog("☠️ addServerCertificate: SecItemAdd: " + String(statusUpload))
                    return nil
                }
            }
        }

        // Get the identity from the imported certificate
        let identity = firstItem[kSecImportItemIdentity as String] as! SecIdentity
        let addquery: [String: Any] = [
            kSecValueRef as String: identity,
            kSecAttrLabel as String: "app.eduroam.geteduroam"
        ]
        let status = SecItemAdd(addquery as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            NSLog("☠️ addClientCertificate: SecPKCS12Import: " + String(status))
            return nil
        }
        return identity
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        debugPrint(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        debugPrint(error)
    }
}

public enum EAPConfiguratorError: Error {
    /// No OID or SSID in configuration
    case noOIDOrSSID

    /// Unable to set server certificate as trusted
    case failedToSetTrustedServerCertificates

    /// Unable to verify network because no server name or certificate set
    case unableToVerifyNetwork

    /// Unable to set identity for client certificate
    case cannotSetIdentity

    /// No credentials in configuration
    case emptyUsernameOrPassword

    /// No valid outer EAP type in configuration
    case noOuterEAPType

    /// Unable to import certificate into keychain
    case failedSecPKCS12Import(OSStatus)

    /// Unable to add certificate to keychain
    case failedSecItemAdd(OSStatus, label: String? = nil)

    /// Unable to copy from keychain
    case failedSecItemCopyMatching(OSStatus)

    /// Unable to decode certificate dat
    case failedToBase64DecodeCertificate

    /// Unable to create certificate from data
    case failedToCreateCertificateFromData

    /// Unable to get common name or subject sequence f from certificate
    case failedToCopyCommonNameOrSubjectSequence

    /// No valid configuration found
    case noConfigurations

    /// Unable to read supported interfaces
    case cannotCopySupportedInterfaces

    /// Username must end with
    case invalidUsername(suffix: String)
}
