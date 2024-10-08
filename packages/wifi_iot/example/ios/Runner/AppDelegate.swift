import Flutter
import NetworkExtension
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await self.connectWifi()
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func connectWifi() async {
        do {
//            let ssid = "Zenlayer-NT-PSK-Turbo"
            let ssid = "ZenNet-Radius-Test"
            let username = "iran.qiu@zenlayer.com"
            let password = "1qaz@WSX"
//            let commonnames = ["Example Certificate Authority", "Example Server Certificate"]
            //
            //        let ssid = "ZenNet-EAS"
            //        let username = "YBBK6D8VZ6"
            //        let password = "27KBGk9veJ"
            //        let commonnames = ["EagleCloud Root CA"]

            let eap = NEHotspotEAPSettings()
            eap.username = username
            eap.password = password
            //        eap.outerIdentity = "anonymous"
            eap.isTLSClientCertificateRequired = false
            eap.supportedEAPTypes = [NSNumber(value: NEHotspotEAPSettings.EAPType.EAPPEAP.rawValue)]
            eap.ttlsInnerAuthenticationType = .eapttlsInnerAuthenticationMSCHAPv2
//            eap.trustedServerNames = commonnames
            let cert = try addCertificate(certificate: base64.replacingOccurrences(of: "\n", with: ""))
            let add = eap.setTrustedServerCertificates([cert])
            let config = NEHotspotConfiguration(ssid: ssid, eapSettings: eap)

            try await NEHotspotConfigurationManager.shared.apply(config)
            debugPrint("success")
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

    // https://github.com/geteduroam/ionic-app/blob/09c247f2e16b77be64c7ca2eea1b71d5da6f2e39/geteduroam/plugins/wifi-eap-configurator/ios/Plugin/Plugin.swift#L10
    // https://github.com/pnf/airport-bssid/blob/3bf8a8222b85024a4970e785b0be9fdda189b9a8/airport-bssid/main.m#L147
    // https://github.com/quicksilver/Networking-qsplugin/blob/main/Networking/QSAirPortProvider.m
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
}

extension String {
    func utf8EncodedString() -> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
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
