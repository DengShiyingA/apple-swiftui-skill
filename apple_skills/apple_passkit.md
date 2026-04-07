# Apple PASSKIT Skill


## Configuring your environment for the Verify with Wallet API
> https://developer.apple.com/documentation/passkit/configuring-your-environment-for-the-verify-with-wallet-api

### 
### 
3. Add the `In App Identity Presentment` capability to your App ID. This capability appears in the  tab of the  page.
### 
Choose the `document-type` you want to add the entitlement to from the entitlement request you submitted. For more information, see .
Choose the `document-type` you want to add the entitlement to from the entitlement request you submitted. For more information, see .
Filter the list of entitlements to just the ones you requested through the entitlement request. The following example shows what a entitlement with the `us-drivers-license` doc-type request might look like:
```json

"com.apple.developer.in-app-identity-presentment": {
    "document-types": [
        "us-drivers-license"
    ],
    "elements": [
        "given-name",
        "family-name",
        "portrait",
        "address",
        "issuing-authority",
        "document-expiration-date",
        "document-number",
        "driving-privileges",
        "age",
        "date-of-birth"
    ]
},

"com.apple.developer.in-app-identity-presentment.merchant-identifiers": [
    “your-merchant-id-goes-here”
]

```


## Offering Apple Pay in Your App
> https://developer.apple.com/documentation/passkit/offering-apple-pay-in-your-app

### 
A shared `PaymentHandler` class handles payment in each of the apps.
#### 
#### 
Apple Pay includes pre-built buttons to start a payment interaction, or to set up payment methods. The iOS app displays the payment button if the device can make payments, and it contains at least one payment card; otherwise it displays the button to add a payment.
This sample checks for the ability to make payments using , and checks for available payment cards using . Both of these methods are part of .
```swift
static let supportedNetworks: [PKPaymentNetwork] = [
    .amex,
    .discover,
    .masterCard,
    .visa
]

class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
    return (PKPaymentAuthorizationController.canMakePayments(),
            PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
}
```

> **note:** The sample app doesn’t display the add button if a device can’t accept payments due to hardware limitations, parental controls, or any other reasons.
```swift
let result = PaymentHandler.applePayStatus()
var button: UIButton?

if result.canMakePayments {
    button = PKPaymentButton(paymentButtonType: .book, paymentButtonStyle: .black)
    button?.addTarget(self, action: #selector(ViewController.payPressed), for: .touchUpInside)
} else if result.canSetupCards {
    button = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
    button?.addTarget(self, action: #selector(ViewController.setupPressed), for: .touchUpInside)
}

if let applePayButton = button {
    let constraints = [
        applePayButton.centerXAnchor.constraint(equalTo: applePayView.centerXAnchor),
        applePayButton.centerYAnchor.constraint(equalTo: applePayView.centerYAnchor)
    ]
    applePayButton.translatesAutoresizingMaskIntoConstraints = false
    applePayView.addSubview(applePayButton)
    NSLayoutConstraint.activate(constraints)
}
```

#### 
The app defines two shipping methods: delivery with estimated shipping dates and on-site collection. The payment sheet displays the delivery information for the chosen shipping method, including estimated delivery dates. Configuring the dates requires a calendar, start date components, and end date components
```swift
func shippingMethodCalculator() -> [PKShippingMethod] {
    // Calculate the pickup date.
    
    let today = Date()
    let calendar = Calendar.current
    
    let shippingStart = calendar.date(byAdding: .day, value: 3, to: today)!
    let shippingEnd = calendar.date(byAdding: .day, value: 5, to: today)!
    
    let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingStart)
    let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingEnd)
     
    let shippingDelivery = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
    shippingDelivery.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
    shippingDelivery.detail = "Ticket sent to you address"
    shippingDelivery.identifier = "DELIVERY"
    
    let shippingCollection = PKShippingMethod(label: "Collection", amount: NSDecimalNumber(string: "0.00"))
    shippingCollection.detail = "Collect ticket at festival"
    shippingCollection.identifier = "COLLECTION"
    
    return [shippingDelivery, shippingCollection]
}
```

#### 
Both iOS and watchOS implementations start the payment process by calling the `startPayment` method of the shared `PaymentHandler`. Updates to the payment sheet use the completion handlers implemented by both apps. The `startPayment` method stores the completion handlers because the Apple Pay functionality is asynchronous; and then the method creates an array of  to display the charges on the payment sheet.
```swift
let ticket = PKPaymentSummaryItem(label: "Festival Entry", amount: NSDecimalNumber(string: "9.99"), type: .final)
let tax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "1.00"), type: .final)
let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "10.99"), type: .final)
paymentSummaryItems = [ticket, tax, total]
```

```
The app configures a  using the list of payment items and other details.
```swift
let paymentRequest = PKPaymentRequest()
paymentRequest.paymentSummaryItems = paymentSummaryItems
paymentRequest.merchantIdentifier = Configuration.Merchant.identifier
paymentRequest.merchantCapabilities = .capability3DS
paymentRequest.countryCode = "US"
paymentRequest.currencyCode = "USD"
paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
paymentRequest.shippingType = .delivery
paymentRequest.shippingMethods = shippingMethodCalculator()
paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
#if !os(watchOS)
paymentRequest.supportsCouponCode = true
#endif
```

Next the app displays the payment sheet by calling  with the payment request. Both apps present the payment sheet using `present(completion:)`.
Next the app displays the payment sheet by calling  with the payment request. Both apps present the payment sheet using `present(completion:)`.
The payment sheet handles all user interactions, including payment confirmation. It requests updates using the completion handlers stored by the `startPayment` method when a user updates the sheet.
```swift
paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
paymentController?.delegate = self
paymentController?.present(completion: { (presented: Bool) in
    if presented {
        debugPrint("Presented payment controller")
    } else {
        debugPrint("Failed to present payment controller")
        self.completionHandler(false)
    }
})
```

#### 
The `PaymentHandler` class handles coupons by implementing the  protocol method .
> **note:** This method is wrapped in a conditional compilation flag as watchOS 8 doesn’t support coupon codes.
```swift
#if !os(watchOS)

func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController,
                                    didChangeCouponCode couponCode: String,
                                    handler completion: @escaping (PKPaymentRequestCouponCodeUpdate) -> Void) {
    // The `didChangeCouponCode` delegate method allows you to make changes when the user enters or updates a coupon code.
    
    func applyDiscount(items: [PKPaymentSummaryItem]) -> [PKPaymentSummaryItem] {
        let tickets = items.first!
        let couponDiscountItem = PKPaymentSummaryItem(label: "Coupon Code Applied", amount: NSDecimalNumber(string: "-2.00"))
        let updatedTax = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(string: "0.80"), type: .final)
        let updatedTotal = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "8.80"), type: .final)
        let discountedItems = [tickets, couponDiscountItem, updatedTax, updatedTotal]
        return discountedItems
    }
    
    if couponCode.uppercased() == "FESTIVAL" {
        // If the coupon code is valid, update the summary items.
        let couponCodeSummaryItems = applyDiscount(items: paymentSummaryItems)
        completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: applyDiscount(items: couponCodeSummaryItems)))
        return
    } else if couponCode.isEmpty {
        // If the user doesn't enter a code, return the current payment summary items.
        completion(PKPaymentRequestCouponCodeUpdate(paymentSummaryItems: paymentSummaryItems))
        return
    } else {
        // If the user enters a code, but it's not valid, we can display an error.
        let couponError = PKPaymentRequest.paymentCouponCodeInvalidError(localizedDescription: "Coupon code is not valid.")
        completion(PKPaymentRequestCouponCodeUpdate(errors: [couponError], paymentSummaryItems: paymentSummaryItems, shippingMethods: shippingMethodCalculator()))
        return
    }
}

#endif
```

#### 
When the user authorizes the payment, the system calls the  method of the  protocol. Your handler confirms that the shipping address meets the criteria needed, and then calls the completion handler to report success or failure of the payment.
The sample code contains a comment at the place you add code for processing the payment.
```swift
func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
    
    // Perform basic validation on the provided contact information.
    var errors = [Error]()
    var status = PKPaymentAuthorizationStatus.success
    if payment.shippingContact?.postalAddress?.isoCountryCode != "US" {
        let pickupError = PKPaymentRequest.paymentShippingAddressUnserviceableError(withLocalizedDescription: "Sample App only available in the United States")
        let countryError = PKPaymentRequest.paymentShippingAddressInvalidError(withKey: CNPostalAddressCountryKey, localizedDescription: "Invalid country")
        errors.append(pickupError)
        errors.append(countryError)
        status = .failure
    } else {
        // Send the payment token to your server or payment provider to process here.
        // Once processed, return an appropriate status in the completion handler (success, failure, and so on).
    }
    
    self.paymentStatus = status
    completion(PKPaymentAuthorizationResult(status: status, errors: errors))
}
```

```
Once the sample app calls the completion handler in the  method, Apple Pay tells the app it can dismiss the payment sheet by calling . iOS and watchOS both handle dismissing the sheet as appropriate for each platform. In the iOS app, if payment succeeds the completion handler performs a segue to display a new view controller. If the payment fails, it remains on the payment sheet so the user can attempt payment with a different card or correct any issues.
```swift
@objc func payPressed(sender: AnyObject) {
    paymentHandler.startPayment() { (success) in
        if success {
            self.performSegue(withIdentifier: "Confirmation", sender: self)
        }
    }
}
```


## Requesting identity data from a Wallet pass
> https://developer.apple.com/documentation/passkit/requesting-identity-data-from-a-wallet-pass

### 
#### 
The following code shows how you create the different identity document descriptors:
To check whether the identity document you describe is available to request, create a  and call . If the document exists, show a  to allow the user to begin the authorization request.
```swift
let controller = PKIdentityAuthorizationController()
controller.checkCanRequestDocument(descriptor) { canRequest in
    // Show or hide the identity button.
}
```

#### 
To create an identity request, you need the merchant identifier you configure in the developer portal. A merchant identifier never expires, and you can use the same one that you use for Apple Pay.
A request also needs a  to prevent your server from using a response document more than once. Your server needs the  to decrypt the response document, so generate it there and associate it with the user’s session.
```swift
let request = PKIdentityRequest()
request.descriptor = descriptor
request.merchantIdentifier = // The merchant identifier.
request.nonce = // The nonce your server generates.
```

#### 
When requesting a document, the system presents a sheet to the user to confirm the request before retrieving any data. If the user rejects the request, your app receives a  error.
```swift
do {
    let document = try await controller.requestDocument(request)
} catch {
    // Handle the error.
}
```

#### 

## Verifying Wallet identity requests
> https://developer.apple.com/documentation/passkit/verifying-wallet-identity-requests

### 
#### 
The framework encodes the HPKE envelope and underlying plaintext with concise binary object representation (CBOR) — a binary JSON-like format that RFC 8949 defines. Because the framework encrypts the response data by using HPKE, it doesn’t use session encryption as ISO 18013-5 section 9.1.1 defines. The encryption envelope contains two parts, the encryption metadata and the encrypted data. When you decrypt the data, you get a CBOR-encoded data structure that contains an `mdoc` response object that ISO 18013-5 defines.
In HPKE, the `info` parameter — a session transcript — isn’t part of the package that you send. The sender and recipient need to build the `info` parameter independently, and need to generate the same value to successfully decrypt it. The following shows the HPKE envelope format:
```other
HPKEEnvelope = {
    “algorithm”: tstr,    ; A value that's always “APPLE-HPKE-v1”.
    “params”: HPKEParams,
    “data”: bstr          ; The encrypted data.
}

HPKEParams = {
    “mode”: uint,         ; A value that's always 0.
    “pkEm”: bstr,         ; An ephemeral sender public key.
    “pkRHash”: bstr,      ; The SHA256 hash of the recipient public key.
    “infoHash”: bstr      ; The SHA256 hash of the HPKE info param.
}
```

#### 
The session transcript structure includes the same  and merchant identifier you use in your , a team identifier, and the SHA256 hash of the public key of the server’s decryption certificate. The session transcript values need to match your app and developer account.
The API uses a modified version of the `SessionTranscript` structure that ISO 18013-5 section 9.1.5.1 defines. The API doesn’t use `DeviceEngagementBytes` and `AReaderKeyBytes`, so those elements are `nil`. The handover element contains the `AppleHandover` structure, as the following code example shows:
```other
SessionTranscript = [
    nil,           ; DeviceEngagementBytes isn't available.
    nil,           ; EReaderKeyBytes isn't available.        
    AppleHandover  ; A custom handover structure. 
]

AppleHandover = [
    “AppleIdentityPresentment_1.0”  ; The version number.
    nonce,                          ; The app-provided nonce you use.  
    merchantId,                     ; The merchant ID of the requesting client.  
    teamID,                         ; The team ID of the requesting client.
    pkRHash                         ; A SHA256 hash of the recipient public key, the same as in HPKEParams.
]
```

Compute the SHA256 hash of the session transcript to produce a value that matches the `infoHash` parameter in the HPKE envelope.
#### 
The output is a CBOR topics structure that wraps an ISO 18013-5 `mdoc` response structure.
| AEAD | AES-128-GCM |
The output is a CBOR topics structure that wraps an ISO 18013-5 `mdoc` response structure.
```other
Topics = {
    “identity”: DeviceResponse      ; A DeviceResponse structure.
}

DeviceResponse = {
    "version": tstr,                ; A value that's always 1.0.
    "documents": [+Document],       ; A list of documents with a length of 1.
    "status": uint,                 ; A value that's always 0.
}
```

The identity value contains the `DeviceResponse` structure that ISO 18013-5 section 8.2.2.1.2.2 defines.
The identity value contains the `DeviceResponse` structure that ISO 18013-5 section 8.2.2.1.2.2 defines.
An `mdoc` response contains three sections you use to verify that the response is valid. The issuer-signed items contain the elements your app requests. The issuer authentication structure contains the issuing authority’s signature and the metadata you use to verify the response authenticity. The device authentication structure contains a signature from the iPhone that’s requesting the information.
```other
Document = {
    “docType”: DocType,                 ; The document type.
    “issuerSigned”: IssuerSigned,       ; The data elements the issuer signs.
    “deviceSigned”: DeviceSigned,       ; The data elements the mdoc signs.
    ? “errors”: Errors                 
}
```

#### 
#### 
#### 

