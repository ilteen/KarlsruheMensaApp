import Foundation
import CryptoKit

let apiURL = URL(string: "https://api.mensa-ka.de/")!

private let apiClientIdentifierDefaultsKey = "mensa_api_client_identifier"

private var apiClientIdentifier: String {
    let defaults = UserDefaults.standard

    if let existingValue = defaults.string(forKey: apiClientIdentifierDefaultsKey),
       UUID(uuidString: existingValue) != nil {
        return existingValue
    }

    let newValue = UUID().uuidString.lowercased()
    defaults.set(newValue, forKey: apiClientIdentifierDefaultsKey)
    return newValue
}

func apiAuthorizationHeader(for body: Data) -> String {
    let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !key.isEmpty else {
        return makeAuthorizationValue(
            clientIdentifier: apiClientIdentifier,
            apiKeyIdentifier: "",
            hash: ""
        )
    }

    let keyIdentifier = String(key.prefix(10))
    let hmac = HMAC<SHA512>.authenticationCode(
        for: body,
        using: SymmetricKey(data: Data(key.utf8))
    )
    let hash = Data(hmac).base64EncodedString()

    return makeAuthorizationValue(
        clientIdentifier: apiClientIdentifier,
        apiKeyIdentifier: keyIdentifier,
        hash: hash
    )
}

private func makeAuthorizationValue(
    clientIdentifier: String,
    apiKeyIdentifier: String,
    hash: String
) -> String {
    let authInfo = "\(clientIdentifier):\(apiKeyIdentifier):\(hash)"
    let encodedAuthInfo = Data(authInfo.utf8).base64EncodedString()
    return "Mensa \(encodedAuthInfo)"
}
