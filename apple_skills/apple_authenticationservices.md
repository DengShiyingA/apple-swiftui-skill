# Apple AUTHENTICATIONSERVICES Skill


## Authenticating a User Through a Web Service
> https://developer.apple.com/documentation/authenticationservices/authenticating-a-user-through-a-web-service

### 
#### 
You can make use of a web authentication service in your app by initializing an  instance with a URL that points to the authentication webpage. The page can be one that you maintain, or one operated by a third party. During initialization, indicate the callback scheme that the page uses to return the authentication outcome:
```swift
// Use the URL and callback scheme specified by the authorization provider.
guard let authURL = URL(string: "https://example.com/auth") else { return }
let scheme = "exampleauth"

// Initialize the session.
let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: scheme)
{ callbackURL, error in
    // Handle the callback.
}
```

#### 
Your app indicates the window that should act as a presentation anchor for the session by adopting the  protocol. From the  method, which is the protocol’s one required method, return the window that should act as the anchor:
```swift
extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}
```

```
After creating the session, set an appropriate context provider instance as the session’s  delegate:
```swift
session.presentationContextProvider = viewController
```

#### 
You can configure the session to request ephemeral browsing by setting the session’s  property to `true`:
You can configure the session to request ephemeral browsing by setting the session’s  property to `true`:
```swift
session.prefersEphemeralWebBrowserSession = true
```

#### 
After configuring the session, call its  method:
```swift
session.start()
```

In iOS, the session loads the authentication web page that you indicated during initialization in an embedded browser view. In macOS, the session sends the page load request to the user’s default browser if it handles authentication sessions, or to Safari otherwise. In any case, the browser presents the user with the authentication page, which is typically a form for entering a username and password.
You can cancel the authentication attempt from your app before the user finishes by calling the session’s  method:
```swift
session.cancel()
```

#### 
After the user authenticates, the authentication provider redirects the browser to a URL that uses the callback scheme. The browser detects the redirect, dismisses itself, and passes the complete URL to your app by calling the closure you specified during initialization.
When you receive this callback, first check for errors. For example, you receive the  error if the user aborts the flow by dismissing the browser window. If the error is `nil`, inspect the callback URL to determine the outcome of the authentication:
```swift
guard error == nil, let callbackURL = callbackURL else { return }

// The callback URL format depends on the provider. For this example:
//   exampleauth://auth?token=1234
let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems
let token = queryItems?.filter({ $0.name == "token" }).first?.value
```


## Authenticating people by using passkeys in browser apps
> https://developer.apple.com/documentation/authenticationservices/authenticating-people-by-using-passkeys-in-browser-apps

### 
#### 
- If the state is , call , passing a completion handler that the operating system calls when someone grants or denies the request.
- If the state is , the person doesn’t allow your app to use their passkeys.
```swift
class BrowserAuthorizationController {
  func authenticatePerson(for relyingParty: String) throws {
    // Check the authorization state.
    let credentialManager = ASAuthorizationWebBrowserPublicKeyCredentialManager()
    switch(credentialManager.authorizationStateForPlatformCredentials) {
    case .authorized:
      // Use the credentials.
      let credentials = credentialManager.platformCredentials(forRelyingParty: relyingParty)
      self.respondToChallenge(for: relyingParty, using: credentials)
    case .denied:
      // Your app doesn't have access to the credentials.
      throw BrowserError("Unable to access passkeys to authenticate with \(relyingParty)")
    case .notDetermined:
      // Request access to the credentials.
      credentialManager.requestAuthorizationForPublicKeyCredentials() { authorizationState in
        // Check the updated authorizationState, and use the credentials if possible.
      }
    }
  }
}
```

#### 
The credentials you get from the credential manager don’t contain the key data; instead, they contain metadata that identifies the credentials to the operating system and to the authenticating person. If the array of credentials contains more than one credential, present them to the person so they can select which credential to use.
Create a credential assertion request, using the challenge data sent by the requesting website. If the person chose a credential to use, restrict the request to allow only that credential. Pass the request to an  instance to complete the challenge.
```swift
extension BrowserAuthorizationController {
  func startAuthenticationChallenge(for relyingParty: String,
    selectedCredential: ASAuthorizationWebBrowserPlatformPublicKeyCredential?,
    challengeData: Data) async {
    let clientData = ASPublicKeyCredentialClientData(challenge: challengeData,
      origin: self.requestOrigin)
    let request = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingParty)
      .createCredentialAssertionRequest(clientData: clientData)
    if let selectedCredential {
      request.allowedCredentials = [ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: selectedCredential.credentialID)]
    }
    let controller = ASAuthorizationController(authorizationRequests: [request])
    controller.delegate = self
    controller.presentationContextProvider = self
    controller.performRequests()
  }
}
```

#### 
 might need to present UI to complete the authentication challenge. Conform to  to provide a window in which the controller can display its UI.
```swift
extension BrowserAuthorizationController : ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let window = self.view.window else {
      fatalError("Started a credential request when the browser view isn't presented in a window.")
    }
    return window
  }
}
```

#### 
Conform to  to react to authorization completion. Implement methods to respond to successful authorization, and to get notified when errors occur.
```swift
extension BrowserAuthorizationController : ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization) {
    // The authorization was successful.
    // Use the authorization parameter to retrieve the credential, and send that to the relying party website.
  }

  func authorizationController(controller: ASAuthorizationController,
    didCompleteWithError error: Error) {
    // The authorization failed.
    // Use the error to find out what happened, and retry or notify someone.
  }
}
```


## Configuring Device Management
> https://developer.apple.com/documentation/authenticationservices/configuring-device-management

### 
#### 
#### 
#### 
IdPs need to ensure that  is correctly set, to ensure the unique identifier is accurate and avoid duplicates.
The system can create new SmartCard users in macOS when the SmartCard contains a valid attribute mapping. The mapping needs to use the `PlatformSSO` prefix followed by the user’s login username for the `AltSecurityIdentifier`. In the following mapping example, the RFC 822 Name is mapped to it:
```xml
<key>AttributeMapping</key>
    <dict>
        <key>dsAttributeString</key>
        <string>dsAttrTypeStandard:AltSecurityIdentities</string>
        <key>fields</key>
        <array>
            <string>RFC 822 Name</string>
        </array>
        <key>formatString</key>
        <string>PlatformSSO:$1</string>
    </dict>
```

#### 
#### 

## Creating a JSON Web Encryption (JWE) login response
> https://developer.apple.com/documentation/authenticationservices/creating-a-json-web-encryption-jwe-login-response

### 
#### 
| `PartyUInfo` | ` |  |
| `PartyVInfo` | This needs to use the `jwe_crypto.apv` value from the login request.  ` |  |
| `SuppPubInfo` | Set to the number of bits in the desired output key. | Per RFC 7518 Section 4.6.2 |
| `SuppPrivInfo` | `NULL` | Per RFC 7518 Section 4.6.2 |
`3491708C92422BB807EDF2B8183A42737C5DAA6C39BA9535321D51C836D7ADA1`
Length || data = `00000007||4132353647434D`
Length || data = `00000005||4150504C45`
`“epk” : {`
Ephemeral Public Key (EPK):
`“epk” : {`
```None
`“y” : “jbOoWZbgDFTEfLa1O_7ZuJy3R8d2XAw0CHWUKmJLsbU”,`

`“x” : “BkFHRYQoleq39LplGqlcmsEdnw64w0wbcbHAEjrM4pw”,`

`“kty” : “EC”,`

`“crv” : “P-256”`
```

`}`
`00000041||0406414745842895EAB7F4BA651AA95C9AC11D9F0EB8C34C1B71B1C0123ACCE29C8DB3A85996E00C54C47CB6B53BFED9B89CB747C7765C0C340875942A624BB1B5`
Final `partyUInfo` length || data:
Response JWE `apu` header is the base-64 URL encoded `partyUInfo`:
`AAAABUFQUExFAAAAQQSf34Uch3TYF27T8SpbtNWCjpKUSjHGDwoiUz8Yoh1nrQidjfO6iMRZIqrsNERt8JnlI2aUwAlZktJ8DZFGWKaB`````
`{`
Device Encryption Public Key:
`{`
```None
`“crv” : “P-256”,`

`“kty” : “EC”,`

`“x” : “mcJyr2BqUQHlscaGoWTw_4QNxDUqI1lR11kCRAzLJkk”,`

`“y” : “P_mLtZKoMMC3G8PtRleKzm1c5D0afPZX_61s70Cx75I”`
```

`}`
`00000041||0499C272AF606A5101E5B1C686A164F0FF840DC4352A235951D75902440CCB26493FF98BB592A830C0B71BC3ED46578ACE6D5CE43D1A7CF657FFAD6CEF40B1EF92`
Nonce: `B7F1FC32-9121-4E2A-9E32-8417E03675DD`
`00000024||42374631464333322D393132312D344532412D394533322D383431374530333637354444`
Final `partyVInfo` length || data:
The login request `jwe_crypto.apv` header is the base 64 URL encoded `partyVInfo`:
`A146E4A23BDA2E53826C04D2F442BCFBD87BC2719D74B8A7DA00AF976267712E`
#### 
| `typ` | `JWT` | Required if the extension SDK is macOS 13.x. |
|  | `platformsso-login-response+jwt` | Optional if the extension SDK is macOS 14.x or later. |
| `enc` | `A256GCM` | Required. The supported encryption algorithm per RFC 7518 Section 4.6. |
| `alg` | `ECDH-ES` | Required. The supported key agreement algorithm per RFC 7518 Section 5.3. |
| `epk` | The ephemeral public key for the key exchange | Required. Per RFC 7518 Section 4.6.1.1, formatted per RFC 7517. |
| `kid` | The `kid` of the ephemeral public key. | Optional. |
| `apu` | The base-64 URL encoded `PartyUInfo` for Concat KDF. | Required. Per RFC 7518 Section 4.6.1.2. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Optional. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Optional. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
The following code provides an example of a login response JWE header:
```javascript
{
    "enc" : "A256GCM",
    "kid" : "d20/VkvmbjLfmi1ufWQqSzzPx+CFHH4N/57Smjk34FE=",
    "epk" : {
        "y" : "doNOTncIN5cjSujnX2qiuHOFL-fag2iypIpDXx1eLdo",
        "x" : "43ZFsDGBnttfDSiNBbsdmXnj3N9ieZaT0nEsEZHk7eo",
        "kty" : "EC",
        "crv" : "P-256"
    }, 
    "apu" : "AAAABUFQUExFAAAAQQTjdkWwMYGe218NKI0Fux2ZeePc32J5lpPScSwRkeTt6naDTk53CDeXI0ro519qorhzhS_n2oNosqSKQ18dXi3a",
    "typ" : "platformsso-login-response+jwt",
    "alg" : "ECDH-ES"
}
```

#### 
| `id_token` | Base-64 URL encoded `id_token` JOSE signed by the IdP. | Required. |
| `refresh_token` | `refresh_token`, which is treated as an opaque value. | Required. |
| `refresh_token_expires_in` | The time (in seconds) until the refresh token expires. If not present, the system uses `expires_in`. | Recommended. |
| `expires_in` | The time in seconds until the tokens expire. | Required, if `refresh_token_expires_in` isn’t present |
| `token_type` | `Bearer` | Expected, but not verified |
| Kerberos TGT | Kerberos TGT, if  is defined. | Optional. |
The following code provides an example of a login response JWE body:
```javascript
{
    "refresh_token" : "AwABA...0t4B4",
    "id_token" : "ewogI...lEvVQ",
    "expires_on" : 1685766415,
    "token_type" : "Bearer",
    "expires_in" : 28800,
    "refresh_token_expires_in" : 28800
}
```

#### 
By default, a HTTP response code of `401` is a credential error. The IdP can optionally specify a predicate to parse a JSON formatted response to determine if the result is a credential error or not, when the response code is `400` or `401`. The  specifies the predicate.
For example, the system can use the predicate `errorCode = ‘C0000006’ AND suberror = ‘invalid_password’` with the following failed response to match to a credential error:
```javascript
HTTP/1.1 400 Bad Request
Cache-Control: no-store, no-cache
Pragma: no-cache
Content-Type: application/json; charset=utf-8

{
    "errorCode": "C0000006",
    "suberror": "invalid_password"
}
```

#### 
The Kerberos mapping is an instance of  in the . It indicates the SSO response entries to use for each of the elements, with each ticket being a sub-dictionary of the login response. The mapping entry maps the response JSON entry names for each ticket.
The following code sample provides an example of a login response body:
```javascript
{

    "expires_in" : 3600,
    "expires_on" : "1646867283.216107",
    "id_token" : "ewogIC...hyI9w",
    "refresh_token" : "abcd1234",
    "token_type" : "Bearer",
    "login_tgt" : {
        "clientName" "foo",
        "encryptionKeyType" : 18,
        "messageBuffer" : "a4IGhDCCBoC...h3YEY6IQ==",
        "realm" : "EXAMPLE.COM",
        "serviceName" : "krbtgt/EXAMPLE.COM",
        "sessionKey" : "EjzbGACRvT1WnSeBkQDnvevt7A7/MuGw0oEVAQRZutU="
    }
}
```

| `ticketKeyPath` | `login_tgt` | The keypath in the response JSON that uses this set of mappings. |
| `messageBufferKeyName` | `messageBuffer` | The key name that contains the base-64 encoded kerberos AS-REP string. |
| `realmKeyName` | `realm` | The key name that contains the Kerberos Realm string. |
| `serviceNameKeyName` | `serviceName` | The key name that contains the Kerberos service name string. |
| `clientNameKeyName` | `clientName` | The key name that contains the Kerberos client name string. |
| `sessionKeyKeyName` | `sessionKey` | The key name that contains the Kerberos session key. |
| `sessionKeyKeyName` | `sessionKey` | The key name that contains the Kerberos session key. |
The  is:
```swift
var mapping = ASAuthorizationProviderExtensionKerberosMapping()
mapping.ticketKeyPath = "login_tgt"
mapping.clientNameKeyName = "clientName"
mapping.encryptionKeyTypeKeyName = "encryptionKeyType"
mapping.messageBufferKeyName = "messageBuffer"
mapping.realmKeyName = "realm"
mapping.serviceNameKeyName = "serviceName"
mapping.sessionKeyKeyName = "sessionKey"
```


## Creating a refresh request
> https://developer.apple.com/documentation/authenticationservices/creating-a-refresh-request

### 
| `typ` | `platformsso-refresh-request+jwt` | Required. |
| `alg` | `ES256` | Required. The signing algorithm. Only ES256 is supported. |
| `kid` | The base-64 encoded SHA256 hash of the ANSI X9.63 formatted public key for the signing identity | Required. |
| `loginConfiguration.customRefreshRequestHeaderClaims` |  | Optional. If present, adds key value pairs to the JWT. |
| `client_id` |  | Required. The open id `client_id` for login. |
| `iss` |  | Required. Per RFC 7523 Section 3. |
| `exp` | 5 minutes from now | Required. Per RFC 7523 Section 3. |
| `nonce` | A nonce value | Required. A unique nonce for this request. |
| `aud` |  | Required. The refresh endpoint URL host and path. |
| `iat` | The current time | Required. The IdP needs to verify this value. |
| or `request_nonce` | The value that the nonce request returns. | Required. The key name is either the  or the default value `request_nonce`. |
| `grant_type` | `refresh_token` | Required. |
| `refresh_token` | The previous refresh token | Required. |
| `jwe_crypto` | A dictionary with the following three values: | Required. The system uses the values in the dictionary to encrypt the response. |
| `enc` | `A256GCM` | Required. The supported encryption algorithm for the response per RFC 7518 Section 4.6. |
| `alg` | `ECDH-ES` | Required. The supported key agreement algorithm for the response per RFC 7518 Section 5.3. |
| `loginConfiguration.customRefreshRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the JWT. |
| `loginConfiguration.customRefreshRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the JWT. |
The following code provides an example of a refresh request:
```javascript
{
    "kid" : "10gy5SeDGL4KRZb0gKyFmPuV9LBAcm/Istdk4lgn24M=",
    "x5c" : "MIIBg...nFg==",
    "typ" : "platformsso-refresh-request+jwt",
    "alg" : "ES256"
}.{
    "iat" : 1685750697,
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...zZEMA"
    },
    "nonce" : "A978348D-DEDF-4AF2-94D4-FCC60B6736D0",
    "request_nonce" : "AwABA...YQgAA",
    "scope" : "openid offline_access urn:apple:platformsso",
    "refresh_token" : "abcd1234",
    "grant_type" : "refresh_token",
    "exp" : 1685750997,
    "aud" : "https://localhost.apple.com:8888/auth/token",
    "client_id" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965"
}.[Signature]
```


## Creating an embedded assertion
> https://developer.apple.com/documentation/authenticationservices/creating-an-embedded-assertion

### 
| `typ` | `JWT` | Required if the extension SDK is macOS 13.x. |
|  | `platformsso-login-assertion+jwt` | Required if the extension SDK is macOS 14.x or later. |
| `alg` | `ES256` | Required. The signing algorithm. If secure enclave key, the system only supports `ES256`. |
|  | `ES256`, `RS256`, `RS384`, or `RS512` | Required. If SmartCard, it depends on the key type and key length on the SmartCard. |
| `kid` | The base-64 encoded SHA256 hash of the ANSI X9.63-formatted public key for the signing key | Required. |
| `x5c` | The base-64 encoded signing certificate from the SmartCard | Optional. The value is base-64 encoded per RFC 7517. |
| `aud` |  | Required. The identity provider (IdP) needs to verify this value to ensure that the assertion was created for them. |
| `iat` | The current time | Required. The IdP needs to verify this value. |
| `exp` | 5 minutes from now | Required. The IdP needs to verify this value. |
| `iss` |  | Required. If not set, the system uses the local account name. |
| `sub` |  | Required. If not set, the system uses the local account name. |
| `nonce` | A nonce value | Required. The IdP needs to verify that this value matches the nonce in the login request. |
| or `request_nonce` | The value returned from the nonce request | Required. The key name is either the  or the default value `request_nonce`. |
| or `request_nonce` | The value returned from the nonce request | Required. The key name is either the  or the default value `request_nonce`. |
| or `request_nonce` | The value returned from the nonce request | Required. The key name is either the  or the default value `request_nonce`. |
The following code provides an example of an embedded assertion request:
```javascript
{
    "typ" : "JWT",
    "alg" : "ES256",
    "kid" : "pmQkkBPmTgijIX00/SpKUjzvm3k2MZAZRiVR3iEv8l0="
}.{
    "nonce" : "7DE40CF9-C885-4397-B48E-E95EDD22038A",
    "request_nonce" : "AwABAAAAAAADAOz_BADv_xtgu_SM1Mvoq02PYz_YfXxx5FAgcLHLNikH6gjrBWwcqnRW_haxqO9JCiPat5KfkTily04S8EH3AQwVsWCxHYQgAA",
    "iat" : "1655416300",
    "sub" : "foo",
    "scope" : "openid offline_access urn:apple:platformsso",
    "exp" : "1655416600",
    "aud" : "060798FF-814E-4C38-97F8-28C954B7E058",
    "iss" : "foo"
}.[Signature]

```


## Creating an encrypted embedded assertion
> https://developer.apple.com/documentation/authenticationservices/creating-an-encrypted-embedded-assertion

### 
| `typ` | `platformsso-encrypted-login-assertion+jwt` | Required. |
| `enc` | `A256GCM` | Required. The supported encryption algorithm per RFC 7518 Section 4.6. |
| `alg` | `ECDH-ES` | Required. The supported key agreement algorithm per RFC 7518 Section 5.3. |
| `epk` | The ephemeral public key for the key exchange | Required. Per RFC 7518 Section 4.6.1.1, formatted per RFC 7517. |
| `kid` | The `kid` of the ephemeral public key | Optional. |
| `apu` | The base-64 URL encoded `PartyUInfo` for Concat KDF | Required. Per RFC 7518 Section 4.6.1.2. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Required. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
| `aud` |  | Required. The identity provider (IdP) needs to verify the value to ensure that the system created the assertion for them. |
| `iat` | The current time | Required. The IdP needs to verify the value. |
| `exp` | 5 minutes from now | Required. The IdP needs to verify the value. |
| `iss` |  | Required. If not set, the system uses the local account name. |
| `sub` |  | Required. If not set, the system uses the local account name. |
| `nonce` | A nonce value | Required: If included, the IdP needs to verify that this value matches the nonce in the login request. |
| `password` | The password for authentication | Required. |
| or `request_nonce` | The value returned from the nonce request | Required: The key name is either the  or the default value `request_nonce`. |
#### 
| `PartyUInfo` | ` |  |
| `PartyVInfo` | This needs to use the `jwe_crypto.apv` value from the login request.   ` |  |
| `SuppPubInfo` | Set to the number of bits in the desired output key. | Per RFC 7518 Section 4.6.2 |
| `SuppPrivInfo` | `NULL` | Per RFC 7518 Section 4.6.2 |
| `SuppPrivInfo` | `NULL` | Per RFC 7518 Section 4.6.2 |
The following code sample provides an example of an encrypted embedded assertion request:
```javascript
{
  "enc" : "A256GCM",
  "apv" : "AAAADUFQUExFRU1CRURERUQAAABBBCX87eqonWyNUNz2JeH2wG68_WiPfQlJw6AiDvHSD08n5Hdn1oDUBxhL_TRarvhUUGDYsnBRk2HRH_ZoXGtpUncAAABuQXdBQkFBQUFBQUFEQU96X0JBRHZfeHRndV9TTTFNdm9xMDJQWXpfWWZYeHg1RkFnY0xITE5pa0g2Z2pyQld3Y3FuUldfaGF4cU85SkNpUGF0NUtma1RpbHkwNFM4RUgzQVF3VnNXQ3hIWVFnQUE",
  "alg" : "ECDH-ES",
  "epk" : {
    "y" : "1wfUpcnhOq7SPl77UBfkanXdQObiBXDIDLx0n1_zlJI",
    "x" : "NUnMKzz81Fl0SilEVYgWWjL_4lTAaXHeJ4uJGQ19AAk",
    "kty" : "EC",
    "crv" : "P-256"
  },
  "kid" : "7y1xXc4I6iAyldmVkIeGtQxo8NRq2FgKFb++Or13jxU=",
  "apu" : "AAAABUFQUExFAAAAQQQ1ScwrPPzUWXRKKURViBZaMv_iVMBpcd4ni4kZDX0ACdcH1KXJ4Tqu0j5e-1AX5Gp13UDm4gVwyAy8dJ9f85SS",
  "typ" : "platformsso-encrypted-login-assertion+jwt"
}.{
  "iat" : 1685732130,
  "password" : "bar",
  "iss" : "foo",
  "request_nonce" : "AwABAAAAAAADAOz_BADv_xtgu_SM1Mvoq02PYz_YfXxx5FAgcLHLNikH6gjrBWwcqnRW_haxqO9JCiPat5KfkTily04S8EH3AQwVsWCxHYQgAA",
  "sub" : "foo",
  "scope" : "openid offline_access urn:apple:platformsso",
  "exp" : 1685732430,
  "aud" : "060798FF-814E-4C38-97F8-28C954B7E058",
  "nonce" : "D1DEE607-0F44-43F5-8B3E-042E91F425A7"
}.[Signature]

```


## Creating and validating a login request
> https://developer.apple.com/documentation/authenticationservices/creating-and-validating-a-login-request

### 
#### 
| `typ` | `JWT` | Required if the extension SDK is macOS 13.x. |
|  | `platformsso-login-request+jwt` | Required if the extension SDK is macOS 14.x or later. |
| `alg` | `ES256` | Required: The signing algorithm. The system only supports `ES256`. |
| `kid` | The base-64 encoded SHA256 hash of the ANSI X9.63 formatted public key for the signing identity | Required. |
| `loginConfiguration.customLoginRequestHeaderClaims` |  | Optional. If present, adds key value pairs to the JSON Web Token (JWT). |
| `client_id` |  | Required. The open id `client_id` for login. |
| `iss` |  | Required. Per RFC 7523 Section 3. |
| `exp` | 5 minutes from now | Required. Per RFC 7523 Section 3. |
| `aud` |  | The token endpoint URL host and path. |
| `iat` | The current time | Required. The IdP needs to verify this value. |
| `request_nonce` or | The value that the nonce request returns | Required. The key name is either the  or the default value `request_nonce`. |
| `sub` |  | Required. Per RFC 7523 Section 3. |
| `grant_type` | `password` | Required. The `grant_type` contains the requested authentication type. |
|  | `urn:ietf:params:oauth:grant-type:saml2-bearer` | When using federation and the WS-Trust response token is a SAML 2.0 token. |
| `password` | The password for authentication | Required when `grant_type` is `password` and the  isn’t set. |
| `jwe_crypto` | A dictionary with the following three values: | Required. The system uses the values in the dictionary to encrypt the response. |
| `enc` | `A256GCM` | Required. The supported encryption algorithm for the response per RFC 7518 Section 4.6. |
| `alg` | `ECDH-ES` | Required. The supported key agreement algorithm for the response per RFC 7518 Section 5.3. |
| `loginConfiguration.customLoginRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the JWT. |
| `platform_sso_version` | `1` | Required. The version of the login protocol. |
| `grant_type` | `urn:ietf:params:oauth:grant-type:jwt-bearer` | Required. The login assertion type. |
| `request` | The base-64 URL encoded signed login request | Required if the extension SDK is macOS 13.x. |
| or `assertion` | The base 64 URL Encoded signed login request | Required if the extension SDK is macOS 14.x or newer. |
|  |  | Optional. If present, adds the key value pairs to the login request. |
The following code provides an example of a login network request:
```javascript
POST /oauth2/token HTTP/1.1
Host: auth.example.com
Accept: application/platformsso-login-response+jwt
Content-Type: application/x-www-form-urlencoded
client-request-id: DCAB01D3-B1FE-4E1C-802F-B3EBDCDF9E67
platform_sso_version=1.0&grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=ewogI...A063Eg
```

#### 
- `client_id` is correct.
- `server_nonce` is valid and not replayed.
- `aud` is the IdP.
If the `grant_type` is password, the IdP needs to verify that the `password` is correct for the supplied .
- `iat` claim isn’t in the future.
- `exp` claim isn’t in the past.
- `scope` matches the login request.
- `audience` is the IdP.
- `nonce` matches the login request, if included.
#### 
The following code provides an example of a login request with a password:
```javascript
{
    "kid" : "WMPGy7o9k+Wh7DB3V7oXBPh3QCP4xuTXtMANwfzn6+k=",
    "x5c" : "MIIBh...8r1E=",
    "typ" : "platformsso-login-request+jwt",
    "alg" : "ES256"
}.{
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...zVGRQ"
    },
    "exp" : 1685737193,
    "nonce" : "A79070DA-4058-4060-B09D-91CECFA635FE",
    "request_nonce" : "AwABA...YQgAA",
    "scope" : "openid offline_access urn:apple:platformsso",
    "grant_type" : "password",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "password" : "password redacted",
    "sub" : "foo",
    "claims" : {
        "id_token" : {
            "groups" : {
                "values" : [
                    "com.example.foogroup",
                    "com.example.bargroup"
                ]
            }
        }
    },
    "aud" : "https://localhost.apple.com:8888/auth/token",
    "iat" : 1685736893,
    "username" : "foo",
    "client_id" : "aaff1524-fa35-40c5-94e3-2b233c5f2965"
}.[Signature]
```

#### 
The following code provides an example of a login request with an encrypted password:
```javascript
{
    "kid" : "o0sPO3BU5DwCIibsHvfVN4D9tOwVcy1Yv0kKKmRG8qk=",
    "x5c" : "MIIBg...xhg==",
  "typ" : "platformsso-login-request+jwt",
  "alg" : "ES256"
}.{
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...zBCRA"
    },
    "exp" : 1685737279,
    "nonce" : "0D7578A1-DE84-4237-A77D-62DDEB2670BD",
    "request_nonce" : "AwABA...YQgAA",
    "scope" : "openid offline_access urn:apple:platformsso",
    "grant_type" : "urn:ietf:params:oauth:grant-type:jwt-bearer",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "sub" : "foo",
    "claims" : {
        "id_token" : {
            "groups" : {
                "values" : [
                    "com.example.foogroup",
                    "com.example.bargroup"
                ]
            }
        }
    }, 
    "aud" : "https://localhost.apple.com:8888/auth/token",
    "username" : "foo",
    "assertion" : "ewogICJlbmMiIDogIkEyNTZHQ00iLAogICJhcHYiIDogIkFBQUFEVUZRVUV4RlJVMUNSVVJFUlVRQUFBQkJCQ1g4N2Vxb25XeU5VTnoySmVIMndHNjhfV2lQZlFsSnc2QWlEdkhTRDA4bjVIZG4xb0RVQnhoTF9UUmFydmhVVUdEWXNuQlJrMkhSSF9ab1hHdHBVbmNBQUFCdVFYZEJRa0ZCUVVGQlFVRkVRVTk2WDBKQlJIWmZlSFJuZFY5VFRURk5kbTl4TURKUVdYcGZXV1pZZUhnMVJrRm5ZMHhJVEU1cGEwZzJaMnB5UWxkM1kzRnVVbGRmYUdGNGNVODVTa05wVUdGME5VdG1hMVJwYkhrd05GTTRSVWd6UVZGM1ZuTlhRM2hJV1ZGblFVRSIsCiAgImFsZyIgOiAiRUNESC1FUyIsCiAgImVwayIgOiB7CiAgICAieSIgOiAiOUVfN0ZyeTlUbDhZdlBncHgzdGc0QTlaQ1FOZkZlZ1BuUWQ0MzNLN0xOTSIsCiAgICAieCIgOiAiU2owYlpzZkhmM3kyMUJRajZ0ejBkUkFwUnhmRGdxdTFwbi1nUGpBcmFCTSIsCiAgICAia3R5IiA6ICJFQyIsCiAgICAiY3J2IiA6ICJQLTI1NiIKICB9LAogICJraWQiIDogIjd5MXhYYzRJNmlBeWxkbVZrSWVHdFF4bzhOUnEyRmdLRmIrK09yMTNqeFU9IiwKICAiYXB1IiA6ICJBQUFBQlVGUVVFeEZBQUFBUVFSS1BSdG14OGRfZkxiVUZDUHEzUFIxRUNsSEY4T0NxN1dtZjZBLU1DdG9FX1JQLXhhOHZVNWZHTHo0S2NkN1lPQVBXUWtEWHhYb0Q1MEhlTjl5dXl6VCIsCiAgInR5cCIgOiAicGxhdGZvcm1zc28tZW5jcnlwdGVkLWxvZ2luLWFzc2VydGlvbitqd3QiCn0..PCPBwllPzLJzaTiw.4InQHbgPs51ExvjLCutmLHzSVLJkxfD5B9lNC1w6H9-7D_FzuinchO6O5Qf0if6IWG0G_bnROLgOvdBEle9Q_0LtF8odeXThBkDszEMqTNpkYhCHmtU6cZgT-lUeHwrA-9mONF5WO4KMIavZOJ_n-6DZWvdMOCgzokx4-OiiPqh5fo0B6MAEQu4AITtXZe7oD6HZAI33zdUD-dQxKNAO2I0aP9RIUP8eLyXkrPY8nIWBRx88aPEtGMs_3uT29BBqGMcMV83zuYFA6TNXTVJy8bCAbeCNZceQbT7lyaFPxZ0s6hg7TSpvIRz7fJX3EXo6a2u4CkkUVgcQrHnfF1aX7v3WOLnYnV1nSO8YPDQYi_m2-bkFSbScmC-ERgmod3m0eV10jA4ag6-TSyB_zlhsVclJQ4suOVyw2YO2Z7AgjRK-BO6GiEMBgbR-P5ad3Zk7v1DVl2MWFMalLfbdcHQNP5drpi4BiY1j0SkFxmdcjTWHea6YAYhmQVjyj29Rd2SOYjRXSXelMftxXO5cZQ.bp-jwZlbdDoL7qjeBbGClw",
    "client_id" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "iat" : 1685736979
}.[Signature]
```

#### 
The following code provides an example of a login request with a secure enclave key:
```javascript
{
    "kid" : "R7hXA3CADcaDzreUMbIJWkTw5IjreuwANl9Rj2tAHbk=",
    "x5c" : "MIIBg...XuQ==",
    "typ" : "platformsso-login-assertion+jwt",
    "alg" : "ES256"
}.{
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...jM5RQ"
    },
    "exp" : 1685737367,
    "nonce" : "E0DA0950-3EC4-486E-9C70-A9B4D28CB39E",
    "request_nonce" : "AwABAAAAAAADAOz_BADv_xtgu_SM1Mvoq02PYz_YfXxx5FAgcLHLNikH6gjrBWwcqnRW_haxqO9JCiPat5KfkTily04S8EH3AQwVsWCxHYQgAA",
    "scope" : "openid offline_access urn:apple:platformsso",
    "grant_type" : "urn:ietf:params:oauth:grant-type:jwt-bearer",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "sub" : "foo",
    "claims" : {
        "id_token" : {
            "groups" : {
                "values" : [
                    "com.example.foogroup",
                    "com.example.bargroup"
                ]
            } 
        }
    }, 
    "aud" : "https://localhost.apple.com:8888/auth/token",
    "username" : "foo",
    "assertion" : "ewogICJ0eXAiIDogInBsYXRmb3Jtc3NvLWxvZ2luLWFzc2VydGlvbitqd3QiLAogICJhbGciIDogIkVTMjU2IiwKICAia2lkIiA6ICJ3dzJyVFhrSWNOeG5ma3BBZi8zRFN3ZldBL2pKOUpuNVh0dlhKMVh5NzhNPSIKfQ.ewogICJub25jZSIgOiAiRTBEQTA5NTAtM0VDNC00ODZFLTlDNzAtQTlCNEQyOENCMzlFIiwKICAiaWF0IiA6IDE2ODU3MzcwNjcsCiAgInJlcXVlc3Rfbm9uY2UiIDogIkF3QUJBQUFBQUFBREFPel9CQUR2X3h0Z3VfU00xTXZvcTAyUFl6X1lmWHh4NUZBZ2NMSExOaWtINmdqckJXd2NxblJXX2hheHFPOUpDaVBhdDVLZmtUaWx5MDRTOEVIM0FRd1ZzV0N4SFlRZ0FBIiwKICAic3ViIiA6ICJmb28iLAogICJzY29wZSIgOiAib3BlbmlkIG9mZmxpbmVfYWNjZXNzIHVybjphcHBsZTpwbGF0Zm9ybXNzbyIsCiAgImV4cCIgOiAxNjg1NzM3MzY3LAogICJhdWQiIDogIjA2MDc5OEZGLTgxNEUtNEMzOC05N0Y4LTI4Qzk1NEI3RTA1OCIsCiAgImlzcyIgOiAiZm9vIgp9.jmAh1SQJVaqhQhYc5QFGq7R_CsSeMxGF9KFn7PERV9TP37qe5q1MIhdspbFLShK-_7YcjqpX-thzBVINaXNbnQ",
    "client_id" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "iat" : 1685737067
}.[Signature]
```

#### 
The following code provides an example of a login request with a SmartCard:
```javascript
{
    "kid" : "MvmFTLE0N7t+SPx8QRYjPB2JzeCYPyL7rZTjsFAlOzs=",
    "x5c" : "MIIBg...RtQ==",
    "typ" : "platformsso-login-request+jwt",
    "alg" : "ES256"
}.{
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...Tg1MQ"
    },
    "exp" : 1685737424,
    "nonce" : "CBA6437A-ED3F-438C-B859-078E058F1851",
    "request_nonce" :"AwABA...YQgAA",
    "scope" : "openid offline_access urn:apple:platformsso",
    "grant_type" : "urn:ietf:params:oauth:grant-type:jwt-bearer",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "sub" : "foo",
    "claims" : {
        "id_token" : {
            "groups" : {
                "values" : [
                    "com.example.foogroup",
                    "com.example.bargroup"
                ]
            }
        }
    }, 
    "aud" : "https://localhost.apple.com:8888/auth/token",
    "username" : "foo",
    "assertion" : "ewogICJraWQiIDogIlV3M3ZzRGI4dW1IVVgwNWE2TUNibEVieXBiSE5HVU0xTUNFK1gxaE5hOFk9IiwKICAieDVjIiA6ICJNSUlCakRDQ0FUR2dBd0lCQWdJQkFUQUtCZ2dxaGtqT1BRUURBakE3TVJnd0ZnWURWUVFEREE5bWIyOUFaWGhoYlhCc1pTNWpiMjB4Q3pBSkJnTlZCQVlUQWxWVE1SSXdFQVlEVlFRS0V3bEJjSEJzWlNCSmJtTXdIaGNOTWpNd05qQXlNakF4T0RRMFdoY05NalF3TmpBeE1qQXhPRFEwV2pBN01SZ3dGZ1lEVlFRRERBOW1iMjlBWlhoaGJYQnNaUzVqYjIweEN6QUpCZ05WQkFZVEFsVlRNUkl3RUFZRFZRUUtFd2xCY0hCc1pTQkpibU13V1RBVEJnY3Foa2pPUFFJQkJnZ3Foa2pPUFFNQkJ3TkNBQVFqWWovNzFPMmhrYWJwOTA5RTlmcmxmc2hSTysxNExzd0NZanlaY3dRSC9aeEpnM1BidjZkL3NIelNTd0ZXS2kydFJaS1VTS3BxQXhrdXpZaXZiRnVCb3lZd0pEQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQTRHQTFVZER3RUIvd1FFQXdJQUFEQUtCZ2dxaGtqT1BRUURBZ05KQURCR0FpRUF3SWU4L2FXOXd1MjFUMWh1cEFNZkt4OUhvQkxsRkpvaE5QQlRrcFh4NGNJQ0lRQ0hVRGdySGZ1RTNRZjRmZi8wV1BueU9mc1g4aCsvVXZvUDgxUU1XcGtPanc9PSIsCiAgInR5cCIgOiAicGxhdGZvcm1zc28tbG9naW4tYXNzZXJ0aW9uK2p3dCIsCiAgImFsZyIgOiAiRVMyNTYiCn0.ewogICJub25jZSIgOiAiQ0JBNjQzN0EtRUQzRi00MzhDLUI4NTktMDc4RTA1OEYxODUxIiwKICAiaWF0IiA6IDE2ODU3MzcxMjQsCiAgInJlcXVlc3Rfbm9uY2UiIDogIkF3QUJBQUFBQUFBREFPel9CQUR2X3h0Z3VfU00xTXZvcTAyUFl6X1lmWHh4NUZBZ2NMSExOaWtINmdqckJXd2NxblJXX2hheHFPOUpDaVBhdDVLZmtUaWx5MDRTOEVIM0FRd1ZzV0N4SFlRZ0FBIiwKICAic3ViIiA6ICJmb28iLAogICJzY29wZSIgOiAib3BlbmlkIG9mZmxpbmVfYWNjZXNzIHVybjphcHBsZTpwbGF0Zm9ybXNzbyIsCiAgImV4cCIgOiAxNjg1NzM3NDI0LAogICJhdWQiIDogIjA2MDc5OEZGLTgxNEUtNEMzOC05N0Y4LTI4Qzk1NEI3RTA1OCIsCiAgImlzcyIgOiAiZm9vIgp9.Ybc1XQeKUO5y5eMvKMVnHj5j-bqh8UnhUfDc76RJFG1viuc3M9OI0D7lKylLcw0V9Y5H-ZAmbxLKg47yh8qxaw",
    "client_id" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "iat" : 1685737124
}.[Signature]
```


## Implementing User Authentication with Sign in with Apple
> https://developer.apple.com/documentation/authenticationservices/implementing-user-authentication-with-sign-in-with-apple

### 
#### 
#### 
In the sample app, `LoginViewController` displays a login form and a Sign in with Apple button () in its view hierarchy. The view controller also adds itself as the button’s target, and passes an action to be invoked when the button receives a touch-up event.
```swift
func setupProviderLoginView() {
    let authorizationButton = ASAuthorizationAppleIDButton()
    authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
    self.loginProviderStackView.addArrangedSubview(authorizationButton)
}
```

#### 
When the user taps the Sign in with Apple button, the view controller invokes the `handleAuthorizationAppleIDButtonPress()` function, which starts the authentication flow by performing an authorization request for the users’s full name and email address. The system then checks whether the user is signed in with their Apple ID on the device. If the user is not signed in at the system-level, the app presents an alert directing the user to sign in with their Apple ID in Settings.
```swift
@objc
func handleAuthorizationAppleIDButtonPress() {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```

The authorization controller calls the  function to get the window from the app where it presents the Sign in with Apple content to the user in a modal sheet.
```swift
func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
}
```

#### 
If the authentication succeeds, the authorization controller invokes the  delegate function, which the app uses to store the user’s data in the keychain.
```swift
func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    switch authorization.credential {
    case let appleIDCredential as ASAuthorizationAppleIDCredential:
        
        // Create an account in your system.
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email
        
        // For the purpose of this demo app, store the `userIdentifier` in the keychain.
        self.saveUserInKeychain(userIdentifier)
        
        // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
        self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
    
    case let passwordCredential as ASPasswordCredential:
    
        // Sign in using an existing iCloud Keychain credential.
        let username = passwordCredential.user
        let password = passwordCredential.password
        
        // For the purpose of this demo app, show the password credential as an alert.
        DispatchQueue.main.async {
            self.showPasswordCredentialAlert(username: username, password: password)
        }
        
    default:
        break
    }
}
```

If the authentication fails, the authorization controller invokes the  delegate function to handle the error.
```swift
func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
}
```

#### 
The `LoginViewController.performExistingAccountSetupFlows()` function checks if the user has an existing account by requesting both an Apple ID and an iCloud keychain password. Similar to `handleAuthorizationAppleIDButtonPress()`, the authorization controller sets its presentation content provider and delegate to the `LoginViewController` object.
```swift
func performExistingAccountSetupFlows() {
    // Prepare requests for both Apple ID and password providers.
    let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                    ASAuthorizationPasswordProvider().createRequest()]
    
    // Create an authorization controller with the given requests.
    let authorizationController = ASAuthorizationController(authorizationRequests: requests)
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
}
```

#### 
The sample app only shows the Sign in with Apple user interface when necessary. The app delegate checks the status of the saved user credentials immediately after launch in the `AppDelegate.application(_:didFinishLaunchingWithOptions:)` function.
The  function retrieves the state of the user identifier saved in the keychain. If the user granted authorization for the app (for example, the user is signed into the app with their Apple ID on the device), then the app continues executing. If the user revoked authorization for the app, or the user’s credential state not found, the app displays the log in form by invoking the `showLoginViewController()` function.
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    appleIDProvider.getCredentialState(forUserID: KeychainItem.currentUserIdentifier) { (credentialState, error) in
        switch credentialState {
        case .authorized:
            break // The Apple ID credential is valid.
        case .revoked, .notFound:
            // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
            DispatchQueue.main.async {
                self.window?.rootViewController?.showLoginViewController()
            }
        default:
            break
        }
    }
    return true
}
```


## Obtaining a server nonce
> https://developer.apple.com/documentation/authenticationservices/obtaining-a-server-nonce

### 
#### 
| `grant_type` | `srv_challenge` | Required. |
| `client-request-id` | `UUID` | Required. A unique identifier for the request. |
| `client-request-id` | `UUID` | Required. A unique identifier for the request. |
The server nonce request is an HTTP POST to the login configuration , as shown in the following example:
```http
POST /oauth2/token HTTP/1.1
Host: auth.example.com
Accept: application/json
Content-Type: application/x-www-form-urlencoded
client-request-id: DCAB01D3-B1FE-4E1C-802F-B3EBDCDF9E67
grant_type=srv_challenge
```

#### 

## Performing a WS-Trust metadata exchange data (MEX) request
> https://developer.apple.com/documentation/authenticationservices/performing-a-ws-trust-metadata-exchange-data-mex-request

### 
#### 
The request is an HTTP GET to the URL in  or to the URL received from the pre-authentication request, as shown here:
```http
GET /wstrust/mex HTTP/1.1
Host: auth.example.com
```

#### 

## Performing a preauthentication request
> https://developer.apple.com/documentation/authenticationservices/performing-a-preauthentication-request

### 
#### 
| `user` |  | The login user name. If not set, the system uses the local account name. |
|  |  | Optional. If present, adds the key value pairs to the request. |
The request is an HTTP GET to the login configuration , as shown here:
```http
GET /oauth2/discovery?user=foo@example.com HTTP/1.1
Host: auth.example.com
Accept: application/json
client-request-id: DCAB01D3-B1FE-4E1C-802F-B3EBDCDF9E67
```

#### 

## Performing encryption verification
> https://developer.apple.com/documentation/authenticationservices/performing-encryption-verification

### 
- Verify the login response and decrypt the JWE
Use this device signing key:
```javascript
{
    "y" : "PAIz7YrH4Rxz1rlfn6JcnwSmFDVGY1ISlGnmK1NX5vs",
    "d" : "vXZoCHYVxEJVcCcQN50ZKEBwhlQYO6g3KaUIufh3vXw",
    "kid" : "Ws9mKynZxyUSNXYtMGAjjLO+Jg16HCa\/5pJO0udNWJ4=",
    "x" : "gK60EgxT-EipyAgSlrHG0LgFVrgnd8UXAvLOgykJtms",
    "kty" : "EC",
    "crv" : "P-256"
}
```

```
Use this device encryption key:
```javascript
{
    "y" : "4MlSuUf_7J6Ljv0FBT1jK0_sKGB4WYwdKCOtnTEAwz4",
    "d" : "1bqqmpoFEtzSnQMqp9N9ZRybnP8vjFUiZyGaSgKVGMw",
    "kid" : "pScnuzx3x85Eyp6CtK9UQADxOsAGTP72y02Tg3m1sk8=",
    "x" : "TvkPOH4yscrSC1rFYvnBVPYMqzR1vKck9ht4D7K_gAQ",
    "kty" : "EC",
    "crv" : "P-256"
}
```

#### 
Note how the system signs the following login JSON Web Token (JWT) using the device-signing key:
```javascript
{
    "kid" : "Ws9mKynZxyUSNXYtMGAjjLO+Jg16HCa/5pJO0udNWJ4=",
    "x5c" : "MIIBhDCCASmgAwIBAgIBATAKBggqhkjOPQQDAjA3MRQwEgYDVQQDEwtkZXZpY2UgdGVzdDELMAkGA1UEBhMCVVMxEjAQBgNVBAoTCUFwcGxlIEluYzAeFw0yMjA2MjMxNzI1MzFaFw0yMzA2MjMxNzI1MzFaMDcxFDASBgNVBAMTC2RldmljZSB0ZXN0MQswCQYDVQQGEwJVUzESMBAGA1UEChMJQXBwbGUgSW5jMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEgK60EgxT+EipyAgSlrHG0LgFVrgnd8UXAvLOgykJtms8AjPtisfhHHPWuV+folyfBKYUNUZjUhKUaeYrU1fm+6MmMCQwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCB4AwCgYIKoZIzj0EAwIDSQAwRgIhAMwGOYwgf5xGxNcZLL/Y4phA66w/PSVLeQYhec2JTQF1AiEAlNSUDycvv0DwDQYU4wUpco/GBuhc4mPmli3+DT+p1Is=",
    "typ" : "JWT",
    "alg" : "ES256"
}.{
    "iat" : "1656005132",
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAABUFwcGxlAAAAQQRO-Q84fjKxytILWsVi-cFU9gyrNHW8pyT2G3gPsr-ABODJUrlH_-yei479BQU9YytP7ChgeFmMHSgjrZ0xAMM-AAAAJERERjY4MTcxLTQwOUQtNEUyQy05MUYwLTlFNDJENzc0NTM2NQ"
    },
    "password" : "bar",
    "request_nonce" : "AwABAAAAAAADAOz_BADv_xtgu_SM1Mvoq02PYz_YfXxx5FAgcLHLNikH6gjrBWwcqnRW_haxqO9JCiPat5KfkTily04S8EH3AQwVsWCxHYQgAA",
    "scope" : "openid offline_access urn:apple:platformsso",
    "grant_type" : "password",
    "username" : "foo",
    "aud" : "https://localhost.apple.com:8888/auth/token",
    "client_id" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "nonce" : "DDF68171-409D-4E2C-91F0-9E42D7745365"
}
```

```
The signed and encoded login JWT output is:
```shell
ewogICJraWQiIDogIldzOW1LeW5aeHlVU05YWXRNR0FqakxPK0pnMTZIQ2EvNXBKTzB1ZE5XSjQ9IiwKICAieDVjIiA6ICJNSUlCaERDQ0FTbWdBd0lCQWdJQkFUQUtCZ2dxaGtqT1BRUURBakEzTVJRd0VnWURWUVFERXd0a1pYWnBZMlVnZEdWemRERUxNQWtHQTFVRUJoTUNWVk14RWpBUUJnTlZCQW9UQ1VGd2NHeGxJRWx1WXpBZUZ3MHlNakEyTWpNeE56STFNekZhRncweU16QTJNak14TnpJMU16RmFNRGN4RkRBU0JnTlZCQU1UQzJSbGRtbGpaU0IwWlhOME1Rc3dDUVlEVlFRR0V3SlZVekVTTUJBR0ExVUVDaE1KUVhCd2JHVWdTVzVqTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFZ0s2MEVneFQrRWlweUFnU2xySEcwTGdGVnJnbmQ4VVhBdkxPZ3lrSnRtczhBalB0aXNmaEhIUFd1Vitmb2x5ZkJLWVVOVVpqVWhLVWFlWXJVMWZtKzZNbU1DUXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBREFPQmdOVkhROEJBZjhFQkFNQ0I0QXdDZ1lJS29aSXpqMEVBd0lEU1FBd1JnSWhBTXdHT1l3Z2Y1eEd4TmNaTEwvWTRwaEE2NncvUFNWTGVRWWhlYzJKVFFGMUFpRUFsTlNVRHljdnYwRHdEUVlVNHdVcGNvL0dCdWhjNG1QbWxpMytEVCtwMUlzPSIsCiAgInR5cCIgOiAiSldUIiwKICAiYWxnIiA6ICJFUzI1NiIKfQ.ewogICJpYXQiIDogIjE2NTYwMDUxMzIiLAogICJqd2VfY3J5cHRvIiA6IHsKICAgICJhbGciIDogIkVDREgtRVMiLAogICAgImVuYyIgOiAiQTI1NkdDTSIsCiAgICAiYXB2IiA6ICJBQUFBQlVGd2NHeGxBQUFBUVFSTy1RODRmakt4eXRJTFdzVmktY0ZVOWd5ck5IVzhweVQyRzNnUHNyLUFCT0RKVXJsSF8teWVpNDc5QlFVOVl5dFA3Q2hnZUZtTUhTZ2pyWjB4QU1NLUFBQUFKRVJFUmpZNE1UY3hMVFF3T1VRdE5FVXlReTA1TVVZd0xUbEZOREpFTnpjME5UTTJOUSIKICB9LAogICJwYXNzd29yZCIgOiAiYmFyIiwKICAicmVxdWVzdF9ub25jZSIgOiAiQXdBQkFBQUFBQUFEQU96X0JBRHZfeHRndV9TTTFNdm9xMDJQWXpfWWZYeHg1RkFnY0xITE5pa0g2Z2pyQld3Y3FuUldfaGF4cU85SkNpUGF0NUtma1RpbHkwNFM4RUgzQVF3VnNXQ3hIWVFnQUEiLAogICJzY29wZSIgOiAib3BlbmlkIG9mZmxpbmVfYWNjZXNzIHVybjphcHBsZTpwbGF0Zm9ybXNzbyIsCiAgImdyYW50X3R5cGUiIDogInBhc3N3b3JkIiwKICAidXNlcm5hbWUiIDogImZvbyIsCiAgImF1ZCIgOiAiaHR0cHM6Ly9sb2NhbGhvc3QuYXBwbGUuY29tOjg4ODgvYXV0aC90b2tlbiIsCiAgImNsaWVudF9pZCIgOiAiYWFmZjE1MjQtZmEzNS00MGM1LTk0ZTMtMmIyMzNjNWYyOTY1IiwKICAibm9uY2UiIDogIkRERjY4MTcxLTQwOUQtNEUyQy05MUYwLTlFNDJENzc0NTM2NSIKfQ.JMD4NkC0bwrQ0GZI66EMo50Rwgfj3fewTc_6836zWbyvNwcCSNmL9hKIgJx-oFoiwZ0dtYYN5KPI3MHLg3-GBw
```

#### 
`}`
#### 
#### 
#### 
#### 
Check the response to confirm that it matches the following output when formatted as a JWE with compact serialization. The system formats the response per RFC 7516 Section 5.1, Step 19. The JWE encrypted key is empty because the system uses direct key agreement:
```shell
ewogICJlbmMiIDogIkEyNTZHQ00iLAogICJraWQiIDogInBTY251engzeDg1RXlwNkN0SzlVUUFEeE9zQUdUUDcyeTAyVGczbTFzazg9IiwKICAiZXBrIiA6IHsKICAgICJ5IiA6ICJlcmY5bkVrRUM4U2l1d1AtN2Y3dWREN0NuWDVLRWF1VklmQlBvcW5tbFlvIiwKICAgICJ4IiA6ICJWSVhkZ3UzeDBlTGdFVnRST1o1WVE0R1VTOFdaUVQtM0hQcVgyRlBvWTRJIiwKICAgICJrdHkiIDogIkVDIiwKICAgICJjcnYiIDogIlAtMjU2IgogIH0sCiAgImFwdSIgOiAiQUFBQUJVRlFVRXhGQUFBQVFRUlVoZDJDN2ZIUjR1QVJXMUU1bmxoRGdaUkx4WmxCUDdjYy1wZllVLWhqZ25xM19aeEpCQXZFb3JzRF91My03blEtd3AxLVNoR3JsU0h3VDZLcDVwV0siLAogICJ0eXAiIDogIkpXVCIsCiAgImFsZyIgOiAiRUNESC1FUyIKfQ..cFAKroCUiODyXmdK.Clpc69y98u7GwODBB9u4ZIcxyOY-MHlVmPIlP5Tz9pKKMLJfHTKkWtHpP1Y8YKAdT7iuRN09bTNRgArfPLIlo7WkUolOGoU3oV07p3m3cOmTzmVqOmVs0dXlEVZlF21TX_hjN2sj5RpC4tWBdKVdoCej4u0Brkgypw0jXtKUzjIM2HcE-8Yy4fC-ixTnescR1M3eM_6IWRR1MtEYTy1C7JrBcw9gZVSmvC1DpeH49gYw9FkIQUpdnfvyreVU0DfvqhABvp29fpVmQqoaENoLuqDt0Ajfko5LWRz3sLcZipoZ0gdRgwQpcNLnBUYAZs5D7t8Yuay2CZjAoTZcbFv4F8Mrg2BgEncVwhC9jTEVGe3GinlsziPdSVIt-7lXbV99yk2qX0eYb4ItScWgUfl3y_p623Xtr3AOxlslahF7fm8PN3sAJnwb_aQQxeeQZQyRZKD9uMHHUTMZeoJbXxV1KdGgQMYdW0Z40_WYFtqT8UwboptazbZX02GOmz2gO7JSe0OHgLCPAfvp9Ah2apYrEDqp01tYwhCG8SNuBB_sXPuJx-euUuxu70s1809k44A_hAc_iYDPwTBpAXBLOiuJIxVZgy54WNNiP_WqBImjsA1ioE7Mrvqkn-DnkM0NP2rt1GvaZ-IpUNgAXKudjiT51guQLnRcr9r3pNmmIaUrqKepMJdAYqUbc9PjYUus7RX-20r5pudVi8Ef0Tg5y9Hk3f7sfiX9peBea_L5yQP-tjXJN8lITRBFCtvvsTb0ALVbKTTHiItmYFxl7XzAljiOMiXEKDKwb0VqOtkU4Ljdz2_M7mW0sT1M6_8XZ6dn3W9RMAeqmLnKlxU5gxj0rK5C8Dnok-I2jOlDzr7uS01WBmaln4E2MTRLyGsdUhXk6JLewtomMTrM7dfq1x6iZubbV8fOk4ayKlEh6xQONPfUXAnr-OB45gllZ2GWNaipd9nwJyGnktSQYpjHiMgl-eKQ3nwwD6Tnj9yYZgvq-D5_DUknvk1XMGTF1CAKaGWDWvf4t2LTyxLld6qgDKyrQWYVKRbHY5LtUqlQjTUP9WGVCNnojVfEIVJIxGXspgL_QwViuBBkmHa_IEd18UE68_yhtBh1dxi_K3td6AG01_Fm1UgYNhi4SPHJqA22zJQ397HdAAGk1bYk5IacY9qyqpVXPBRhEE92DG5oDZcCUB9li87NWRJIaF46Q1z5S2ROSBimBi-nyOX5G4DpgrPjst3lK7NacpssjdPk2fDh3XXKu2r4RXBr7l7hweuwKNgyzPBoTZ37dadYKz1MpxO5Ag43xLzTougLDkVrS5w.4dpX5cVdPodXep2NyC2Vyg
```

#### 

## Processing the JSON Web Encryption (JWE) login response
> https://developer.apple.com/documentation/authenticationservices/processing-the-json-web-encryption-jwe-login-response

### 
If the HTTP response code is `200`, the system decrypts the response body according to RFC 7516 Section 5.2, using JWE Compact Serialization. Use of the zip header isn’t supported. The system checks `PartyUInfo` for the Ephemeral Public Key in the response. `PartyVInfo` is the `jwe_crypto.apv` from the login request.
The following code sample provides an example of an encrypted login response JWE:
```http
HTTP/1.1 200 OK
Cache-Control: no-store, no-cache
Pragma: no-cache
Content-Type: application/platformsso-login-response+jwt; charset=utf-8
ewogI...luEng
```

#### 
| `nonce` | The `nonce` value from the login request. | Required. |
| `iss` | Must match the . | Required. |
| `aud` | Must match the  or must contain the . | Required. |
| `azp` | If present, must match the . | Required only if `aud` is an array. |
| `iat` | Must be in past. | Required. |
| `exp` | Must be in the future. | Required. |
| `nbf` | If present, must be in the past. | Optional. |
| `groups` or | The requested group membership for the user. | Optional. |

## Supporting Security Key Authentication Using Physical Keys
> https://developer.apple.com/documentation/authenticationservices/supporting-security-key-authentication-using-physical-keys

### 
#### 
The following code sets up the process of registration. Create an instance of  and pass it your relying party identifier, which is usually the service’s domain name.
```swift
var challenge : NSData? // Obtain this from the server.
let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider("example.com")
let securityKeyRequest = securityKeyProvider.createCredentialRegistrationRequest(challenge: challenge, displayName: "Anne Johnson", name: "annejohnson1@icloud.com", userID: "anne_johnson")
securityKeyRequest.credentialParameters = [ ASAuthorizationPublicKeyCredentialParameters(algorithm: ASCOSEAlgorithmIdentifier.ES256) ]
let authController = ASAuthorizationController([securityKeyRequest])
authController.delegate = self
authController.presentationContextProvider = self
authController.performRequests()

```

#### 
Obtain the challenge from the server, then create an instance of  and set its provider to the service URL. Set the challenge, and then create an .
Create the authorization controller with the platform key request, set the controller’s delegate and presentation context provider, and direct the authorization controller to perform the request.
```swift
let securityKeyProvider = ASAuthorizationSecurityKeyPublicKeyCredentialProvider("example.com")
var challenge : NSData?
let securityKeyRequest = securityKeyProvider.createCredentialAssertionRequestWithChallenge(challenge)
let authController = ASAuthorizationController([securityKeyRequest])
authController.delegate = self
authController.presentationContextProvider = self
authController.performRequests()

```

#### 
 provides information about the outcome of a registration or authentication request. Adopt this protocol to determine how to react to authorization success or errors. The following code defines  to handle registration and assertion, as well as  to handle any errors:
```swift
func authorizationController(controller: controller, didCompleteWithAuthorization: authorization) {
  if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialRegistration {
    // Take steps to handle the registration.
 } else if let credential = authorization.credential as? ASAuthorizationSecurityKeyPublicKeyCredentialAssertion {
    // Take steps to verify the challenge.
  } else {
    // Handle other authentication cases, such as Sign in with Apple.
}

func authorizationController(controller: controller, didCompleteWithError: error) {
  // Handle the error.
} 
```


## Supporting Single Sign-On in a Web Browser App
> https://developer.apple.com/documentation/authenticationservices/supporting-single-sign-on-in-a-web-browser-app

### 
#### 
#### 
Adopt the  protocol in your web browser app to receive authentication requests. Choose a class that can act as the handler, and declare conformance to the protocol:
```swift
class MyAuthenticationHandler: ASWebAuthenticationSessionWebBrowserSessionHandling {
    var request: ASWebAuthenticationSessionRequest?
}
```

```
From within the conforming class, implement the protocol’s  method to receive new  instances. Handle the request using the data it encapsulates as described in  below.
```swift
func begin(_ request: ASWebAuthenticationSessionRequest!) {
    self.request = request   // Store for later.

    if request.shouldUseEphemeralSession == true {
        // Load request.url in an isolated session and wait for the callback.
    } else {
        // Load request.url and wait for the callback.
    }
}
```

```
Implement the  method to listen for cancellations, which might happen if the calling app terminates or cancels the operation. If you have multiple requests in progress, you can use the cancellation request’s  property to identify the in-progress request to cancel:
```swift
func cancel(_ request: ASWebAuthenticationSessionRequest!) {
    // Abandon the request and clean up.
    self.request = nil
}
```

```
After implementing the interface, tell the system how to find your session handler by setting the  property of the shared session manager. You typically do this once at startup. For example, you might set the property in your app delegate’s  method:
```swift
func applicationDidFinishLaunching(_ aNotification: Notification) {
    let manager = ASWebAuthenticationSessionWebBrowserSessionManager.shared
    manager.sessionHandler = MyAuthenticationHandler()
    // The manager keeps a strong reference to your handler.
}
```

#### 
When your handler receives a new authentication request, load the URL given in the request’s  property and display the content to the user. The user interacts with the content to authenticate—for example, by entering credentials and clicking a button. The service performing the authentication indicates the outcome by redirecting the browser to a URL that uses a known callback scheme.
The request’s  property tells your browser what callback scheme the service uses. When your browser detects a redirect involving this scheme, pass the entire URL back to the session manager by calling the request’s  method. For example, when using the WebKit API, you can do this from the navigation delegate’s  method:
```swift
func webView(_ webView: WKWebView,
             decidePolicyFor navigationAction: WKNavigationAction,
             decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    guard let url = navigationAction.request.url else { return }

    if url.scheme == request?.callbackURLScheme {
        request?.complete(withCallbackURL: url)
    } else {
        // Handle normally.
    }
}
```

#### 
When your browser supports the authentication flow, the system might launch the browser specifically for the purpose of authentication. You can detect this condition by checking the  property of the shared session manager.
```swift
func applicationDidFinishLaunching(_ aNotification: Notification) {
    let manager = ASWebAuthenticationSessionWebBrowserSessionManager.shared
    manager.sessionHandler = MyAuthenticationHandler()

    if manager.wasLaunchedByAuthenticationServices == true {
        // Adjust startup behavior accordingly.
    }
}
```


## Supporting key requests and key exchange requests
> https://developer.apple.com/documentation/authenticationservices/supporting-key-requests-and-key-exchange-requests

### 
#### 
| `typ` | `platformsso-key-request+jwt` | Required. |
| `alg` | `ES256` | Required. The signing algorithm, only `ES256` is supported. |
| `kid` | The base-64 encoded SHA256 hash of the ANSI X9.63 formatted public key for the signing key | Required. |
| `x5c` | The base-64 encoded device signing certificate from | Optional: The value is base-64 encoded per RFC 7517. |
| `version` | 1.0 | Required. |
| `request_type` | key_request | Required. |
| `key_purpose` | user_unlock | Required. |
| `aud` |  | Required. The identity provider (IdP) needs to verify this value to ensure that the assertion was created for them. |
| `iss` |  | Required. Per RFC 7523 Section 3. |
| `iat` | The current time | Required. The IdP needs to verify this value. |
| `exp` | 5 minutes from now | Required. The IdP needs to verify this value. |
| `nonce` | A nonce value | Required. A unique nonce value for this request. |
| or `request_nonce` | The value returned from the nonce request | Required. The key name is either the  or the default value `request_nonce`. |
| `username` |  | Required. The login user name. If not set, the system uses the local account name. |
| `sub` |  | Required. Per RFC 7523 Section 3. |
| `refresh_token` | The current refresh token | Required. |
| `loginConfiguration.customKeyRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the assertion. |
| `loginConfiguration.customKeyRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the assertion. |
The following code provides an example of a key request:
```javascript
{
    "kid" : "6cgzt+gMK7vzj4iXhQj4AA4lyJUQ4ZVA/wTnA2kaYcg=",
    "x5c" : "MIIBg...Mhw==",
    "typ" : "platformsso-key-request+jwt",
    "alg" : "ES256"
}.{
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...TNGMQ"
    },
    "exp" : 1685756137,
    "request_type" : "key_request",
    "nonce" : "EA7D38B1-B9EA-444B-9141-97FFE7D0E3F1",
    "version" : "1.0",
    "request_nonce" : "AwABA...YQgAA",
    "refresh_token" : "abcd1234",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "key_purpose" : "user_unlock",
    "sub" : "foo",
    "username" : "foo",
    "iat" : 1685755837
}.[Signature]
```

| `platform_sso_version` | `2.0` | Required. The version of the login protocol. |
| `grant_type` | `urn:ietf:params:oauth:grant-type:jwt-bearer` | Required. The assertion type. |
|  |  | Optional. If present, adds the key value pairs to the key request. |
The following code provides an example of a key network request:
```http
POST /oauth2/token HTTP/1.1
Host: auth.example.com
Accept: application/platformsso-key-response+jwt
Content-Type: application/x-www-form-urlencoded
client-request-id: DCAB01D3-B1FE-4E1C-802F-B3EBDCDF9E67
platform_sso_version2.0&grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=ewogI...HGuQg
```

#### 
| `typ` | `platformsso-key-response+jwt` | Required. |
| `enc` | `A256GCM` | Required. The supported encryption algorithm per RFC 7518 Section 4.6. |
| `alg` | `ECDH-ES` | Required: The supported key agreement algorithm per RFC 7518 Section 5.3. |
| `epk` | The ephemeral public key for the key exchange | Required. Per RFC 7518 Section 4.6.1.1, formatted per RFC 7517. |
| `kid` | The `kid` of the ephemeral public key | Optional. |
| `apu` | The base-64 URL encoded `PartyUInfo` for Concat KDF | Required. Per RFC 7518 Section 4.6.1.2. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Optional. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Optional. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
The following code provides an example of a key response JWE header:
```javascript
{
    "enc" : "A256GCM",
    "kid" : "8fWc60nKm8I07JE3yG+xf9Kb61wUNrjWnVBV9zIB5mQ=",
    "epk" : {
        "y" : "SwUUA5FVmbe5K8OZ7ElRH5_qB8Z9klZyiGVvrTMyn8A",
        "x" : "o7YsVVlHr5VrMLFX6rqT5MQkNip9_GgYAnm8nQYIrVQ",
        "kty" : "EC",
        "crv" : "P-256"
    }, 
    "apu" : "AAAAB...zMp_A",
    "typ" : "platformsso-key-response+jwt",
    "alg" : "ECDH-ES"
}
```

| `certificate` | The base-64 URL encoded certificate that contains the provisioned public key | Required. |
| `exp` | 5 minutes from now | Required. Per RFC 7523 Section 3. |
| `iat` | The current time | Required. Per RFC 7523 Section 3. |
| `key_context` | The key context for the key | Optional. |
| `key_context` | The key context for the key | Optional. |
The following code provides an example of a key response JWE body:
```javascript
{
    "certificate" : "MIIBc...2dGpb",
    "exp" : 1685756137,
    "iat" : 1685755837,
    "key_context" : "BHmTq...scA=="
}
```

#### 
The key exchange request is a JOSE that’s formatted per RFC 7519 and signed with the `DeviceSigningKey` and `ES256` per RFC 7515.
| `typ` | `platformsso-key-request+jwt` | Required. |
| `alg` | `ES256` | Required. The signing algorithm. The system only supports `ES256`. |
| `kid` | The base-64 encoded SHA256 hash of the ANSI X9.63 formatted public key for the signing key | Required. |
| `x5c` | The base-64 encoded device signing certificate from | Optional. The value is base-64 encoded per RFC 7517. |
| `loginConfiguration.customKeyExchangeRequestHeaderClaims` |  | Optional. If present, adds the key value pairs to the assertion. |
| `version` | `1.0` | Required. |
| `request_type` | `key_exchange` | Required. |
| `key_purpose` | `user_unlock` | Required. |
| `aud` |  | Required. The identity provider (IdP) needs to verify the value to ensure that the assertion was created for them. |
| `iss` |  | Required. Per RFC 7523 Section 3. |
| `iat` | The current time | Required. The identity provider (IdP) needs to verify the value. |
| `exp` | 5 minutes from now | Required. The identity provider (IdP) needs to verify the value. |
| `nonce` | A nonce value | Required. A unique nonce value for this request. |
| or `request_nonce` | The value returned from the nonce request | Required. The key name is either the  or the default value `request_nonce`. |
| `username` |  | Required. If not set, the system uses the local account name. |
| `sub` |  | Required. Per RFC 7523 Section 3. If not set, the system uses the local account name. |
| `refresh_token` | The current refresh token | Required. |
| `other_publickey` | The base-64 encoded other party public key | Required. |
| `key_context` | The context for the key | Optional. |
| `loginConfiguration.customKeyRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the assertion. |
| `loginConfiguration.customKeyRequestBodyClaims` |  | Optional. If present, adds the key value pairs to the assertion. |
The following code provides an example of a key exchange request:
```javascript
{
    "kid" : "NKuTL/WHlroXidcyrxgA2Eqpt/cXjh5s22NAkJl7Acs=",
    "x5c" : "MIIBg...YtQ==",
    "typ" : "platformsso-key-request+jwt",
    "alg" : "ES256"
}.{
    "jwe_crypto" : {
        "alg" : "ECDH-ES",
        "enc" : "A256GCM",
        "apv" : "AAAAB...UEwRQ"
    },
    "exp" : 1685759411,
    "request_type" : "key_exchange",
    "nonce" : "7F48971A-E559-4668-A680-97D1BCF7AA0E",
    "version" : "1.0",
    "request_nonce" : "AwABA...HYQgAA",
    "other_publickey" : "BCdD2...RJIv0=",
    "refresh_token" : "abcd1234",
    "key_context" : "BHp+H...Axw==",
    "iss" : "aaff1524-fa35-40c5-94e3-2b233c5f2965",
    "key_purpose" : "user_unlock",
    "sub" : "foo",
    "username" : "foo",
    "iat" : 1685759111
}.[Signature]
```

| `platform_sso_version` | `2.0` | Required. The version of the login protocol. |
| `grant_type` | `urn:ietf:params:oauth:grant-type:jwt-bearer` | Required. The assertion type. |
| or `assertion` | The base-64 URL encoded signed key exchange request | Required. |
|  |  | Optional. If present, adds the key value pairs to the key exchange request. |
The following code sample provides an example of a key exchange network request:
```http
POST /oauth2/token HTTP/1.1
Host: auth.example.com
Accept: application/platformsso-key-response+jwt
Content-Type: application/x-www-form-urlencoded
client-request-id: DCAB01D3-B1FE-4E1C-802F-B3EBDCDF9E67
platform_sso_version=2.0&grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=ewogIC...JmVhg
```

#### 
| `typ` | `platformsso-key-response+jwt` | Required. |
| `enc` | `A256GCM` | Required: The supported encryption algorithm per RFC 7518 Section 4.6. |
| `alg` | `ECDH-ES` | Required. The supported key agreement algorithm per RFC 7518 Section 5.3. |
| `epk` | The ephemeral public key for the key exchange | Required: Per RFC 7518 Section 4.6.1.1, formatted per RFC 7517. |
| `kid` | The `kid` of the ephemeral public key | Optional. |
| `apu` | The base-64 URL encoded `PartyUInfo` for Concat KDF | Required. Per RFC 7518 Section 4.6.1.2. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Optional. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
| `apv` | The base-64 URL encoded `PartyVInfo` for Concat KDF | Optional. Per RFC 7518 Section 4.6.1.3, the client uses the value from the request. |
The following code provides an example of a key exchange response JWE header:
```javascript
{
    "enc" : "A256GCM",
    "kid" : "cNYXaKrqHO+mBB0MHxuaEUZ2edf0T/GgMNB/tlHGews=",
    "epk" : {
        "y" : "WFUG_Llu2uD70NfbIFOkP5LaNsZlJ1JGIme2DPdbijU",
        "x" : "kXzpm4kt-sbm5QlOJPNZAHhaW8rQ5QE_E2HLFcz2uNs",
        "kty" : "EC",
        "crv" : "P-256"
    }, 
    "apu" : "AAAAB...z3W4o1",
    "typ" : "platformsso-key-response+jwt",
    "alg" : "ECDH-ES"
}
```

| `exp` | 5 minutes from now | Required. Per RFC 7523 Section 3. |
| `iat` | The current time | Required. Per RFC 7523 Section 3. |
| `key_context` | The updated key context for the key | Optional. |
| `key_context` | The updated key context for the key | Optional. |
The following code provides an example of a key exchange response JWE body:
```javascript
{
    "exp" : 1685756137,
    "iat" : 1685755837,
    "key" : "DpWD3c4SPmfYteESkRYk+pKVHHuryb1EtnuzhF9OjTc=",
    "key_context" : "BHp+H...Axw=="
}
```


## Supporting passkeys
> https://developer.apple.com/documentation/authenticationservices/supporting-passkeys

### 
#### 
To onboard users to a new service, such as an online bank or grocery delivery app, without passwords, you need to obtain a  from the server. A challenge is data that the server generates to prove that you, as the authenticator, own the account.
The following code sets up the process of registration. Create an instance of  and pass it your relying party identifier, which is usually the service’s domain name.
```swift
let challenge: Data // Obtain this from the server.
let userID: Data // Obtain this from the server.
let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: "Anne Johnson", userID: userID)
let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
authController.delegate = self
authController.presentationContextProvider = self
authController.performRequests()
```

#### 
Create the authorization controller by encapsulating the platform key request in an array. You can pass additional assertion requests in the array, such as passwords and the Sign in with Apple service. The sheet displays whatever credentials the device has for those types.
Set the controller’s delegate and presentation context provider, and direct the authorization controller to perform the request.
```swift
let challenge: Data // Obtain this from the server.
let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "example.com")
let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
let authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
authController.delegate = self
authController.presentationContextProvider = self
authController.performRequests()
```

#### 
 provides information about the outcome of a registration or authentication request. Adopt this protocol to determine how to react to authorization success or errors. The following code defines  to handle registration and assertion, as well as  to handle any errors:
```swift
func authorizationController(controller: controller, didCompleteWithAuthorization: authorization) {
  if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
    // Take steps to handle the registration.
 } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
    // Take steps to verify the challenge.
  } else {
    // Handle other authentication cases, such as Sign in with Apple.
}

func authorizationController(controller: controller, didCompleteWithError: error) {
  // Handle the error.
} 
```

#### 
#### 
#### 

## Upgrading Account Security With an Account Authentication Modification Extension
> https://developer.apple.com/documentation/authenticationservices/upgrading-account-security-with-an-account-authentication-modification-extension

### 
#### 
#### 
#### 
#### 
When the user initiates a strong password upgrade, the system invokes your extension to perform the upgrade. To perform a one-tap automatic upgrade to strong passwords, the system loads your extension and instantiates a subclass of . The system calls the  method you implement in the view controller.
```swift
class AccountAuthenticationModificationViewController: ASAccountAuthenticationModificationViewController {
    override func changePasswordWithoutUserInteraction(
        for serviceIdentifier: ASCredentialServiceIdentifier,
        existingCredential: ASPasswordCredential,
        newPassword: String,
        userInfo: [AnyHashable : Any]?)
    {
        // Verify with your server that the user is authorized to
        // update the password.

        // Once confirmed, send the user data to your server.
    }
}
```

To perform the automatic upgrade, the extension communicates with your server to authorize and perform the upgrade. Use the current password, existing token, or credential information from your app to confirm with your server that the user is authorized to perform the password upgrade. Once the server confirms the user authorization, send the new password to your server to perform the upgrade. If the system-generated password doesn’t satisfy your server’s requirements, you can use a different password than the one the system provides.
After completing the password change on your server, call  on the view controller’s , passing the new credential for the service. The system stores the new credential in the Keychain, and removes the old credential.
```swift
let newCredential = ASPasswordCredential(
    user: existingCredential.user,
    password: newPassword
)
self.extensionContext.completeChangePasswordRequest(updatedCredential: newCredential)
```

```
If the user isn’t authorized to perform the upgrade, or the update fails, cancel the request as follows:
```swift
let error = ASExtensionError(.failed)
self.extensionContext.cancelRequest(withError: error)
```

To display a custom error message to the user, initialize an `ASExtensionError` with  and specify an error string, as follows:
```
To display a custom error message to the user, initialize an `ASExtensionError` with  and specify an error string, as follows:
```swift
let error = ASExtensionError(.failed, userInfo: [
    ASExtensionLocalizedFailureReasonErrorKey: "Authentication failed."
])
self.extensionContext.cancelRequest(withError: error)
```

#### 
Use the current password to authorize with your server that the user can perform the upgrade. If not, fail the request as described above.
To perform the upgrade, request the Sign in with Apple credentials from the extensionContext by calling . If the system provides a Sign in with Apple credential, send the credential information to your server, and then complete the request by calling . Once complete, the system removes the old password from the Keychain.
```swift
let myState: String = ...
let myNonce: String = ...

self.extensionContext.getSignInWithAppleUpgradeAuthorization(
    state: myState,
    nonce: myNonce
) { appleIDCredential, error in
    guard let appleIDCredential = appleIDCredential else {
        self.extensionContext.cancelRequest(
            withError: ASExtensionError(.failed)
        )
        return
    }

    // Verify with your server that the user is authorized to
    // convert the account to Sign in with Apple.

    let userIdentifier = appleIDCredential.user
    let fullName = appleIDCredential.fullName
    let email = appleIDCredential.email
    // Once confirmed, send the user data to your server.

    self.extensionContext.completeUpgradeToSignInWithApple()
}

```

#### 
If the user initiates an account authentication upgrade but you require additional security steps, such as using two-factor authentication, fail the initial automatic request with an error that specifies user interaction is required.
```swift
let error = ASExtensionError(.userInteractionRequired)
self.extensionContext.cancelRequest(withError: error)
```

#### 
4. Call  on the controller to initiate the request.
The following example shows how to configure and initiate a request to upgrade to a strong password:
```swift
let username = "jappleseed"
let serviceIdentifier = ASCredentialServiceIdentifier(
    identifier: "myservice.example.com",
    type: .domain
)

let userInfo = ["com.example.authTokenKey": authToken]
let upgradeRequest = ASAccountAuthenticationModificationUpgradePasswordToStrongPasswordRequest(
    user: username,
    serviceIdentifier: serviceIdentifier,
    userInfo: userInfo
)

let requestController = ASAccountAuthenticationModificationController()
requestController.delegate = self
requestController.presentationContextProvider = self
requestController.perform(upgradeRequest)
```

```
For upgrading to Sign in with Apple, the process is the same, except you instantiate an  object instead:
```swift
let upgradeRequest = ASAccountAuthenticationModificationReplacePasswordWithSignInWithAppleRequest(
    user: username,
    serviceIdentifier: serviceIdentifier,
    userInfo: userInfo
)
```


