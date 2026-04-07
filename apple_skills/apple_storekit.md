# Apple STOREKIT Skill


## Determining service entitlement on the server
> https://developer.apple.com/documentation/storekit/determining-service-entitlement-on-the-server

### 
- URL: `localhost:3000/simulate` — Use `/simulate` for testing using real or artificial receipts. This endpoint requires no special configuration.
- URL: `localhost:3000/entitle` — Use `/entitle` with real Base64-encoded receipts. This endpoint requires additional configuration.
#### 
2. Open the Terminal app (`/Applications/Utilities`).
3. Navigate to the sample code `/Sample` directory.
4. In Terminal, enter `npm install` and press Return. Make sure it completes successfully.
5. In Terminal, copy the example environment file: `cp env.example`.
#### 
The requests to the service entitlement engine take JSON data from a receipt. The data must be in the same JSON format that you receive by calling the `/verifyReceipt` endpoint when you pass it a valid receipt. The example file `flatJSONExample` in the `Source/Example` directory contains sample receipt data in the correct format for the requests.
To run the request, switch to the second Terminal window and type the following `curl` command. Replace the `<FLAT JSON DATA>` with the `flatJSONExample`.
```swift
curl -XPOST -H "Content-type: application/json" -d '<FLAT JSON DATA>' 'localhost:3000/simulate'
```

If you have real receipt data, replace the `<FLAT JSON DATA>` in the command with your receipt data.
#### 
The response contains the result of the engine’s analysis of the receipt data. Use it to determine whether a customer has the necessary entitlements to service, offers, or other messaging. The response object contains an array of subscription objects organized by product ID, each containing fields that provide insights for that subscription.
The following example response shows a customer who was previously subscribed and then resubscribed. The customer is in state 5, which indicates an active subscription with autorenew still in an enabled state.
```swift
{
    "products": [
        {
            "product_id": "com.example.monthly",
            "entitlementCode": 5,
            "expiration": 1599391591000,
            "totalRenewals": 7,
            "groupID": "13472270",
            "originalTransactions": [
                {
                    "originalTX": "190000625698817",
                    "start": 1564455960000,
                    "expiration": 1599391591000,
                    "renewals": 7
                }
            ],
            "trialConsumed": true
        }
    ],
    "trialConsumedForGroup": [
        "13472270"
    ]
}
```


## Generating JWS to sign App Store requests
> https://developer.apple.com/documentation/storekit/generating-jws-to-sign-app-store-requests

### 
#### 
#### 
| `alg` - Encryption Algorithm | `ES256`   You need to sign JWS with ES256 encryption. |
| `kid` - Key ID | Your private key ID from App Store Connect (example: `2X9R4HXF34`) |
| `typ` - Token Type | `JWT` |
| `typ` - Token Type | `JWT` |
Here’s an example of a JWS header:
```javascript
{
  "alg": "ES256",
  "kid": "2X9R4HXF34",
  "typ": "JWT"
}
```

#### 
| `iss` - Issuer | Your issuer ID from the Keys page in App Store Connect (example: “`57246542-96fe-1a63-e053-0824d011072a"`) |
| `aud` - Audience | A value that depends on the feature you’re using (see the table below) |
| `bid` - Bundle ID | Your app’s bundle ID (example: `“com.example.testbundleid”)` |
| `nonce` - Nonce | A one-time-use UUID that identifies this request (example: “`368f3888-dcd8-11ef-b3c8-325096b39f47"`) |
Choose the `aud` value to match the feature you’re using:
| Advanced Commerce API in-app request | “`advanced-commerce-api"` |
| Promotional offer signature | “`promotional-offer"` |
| Introductory offer eligibility | “`introductory-offer-eligibility"` |
| Introductory offer eligibility | “`introductory-offer-eligibility"` |
Here’s an example of the base payload, without any feature-specific fields:
```javascript
{
  "iss": "57246542-96fe-1a63e053-0824d011072a",
  "iat": 1741043663,
  "aud": "promotional-offer",
  "bid": "com.example.testbundleid",
  "nonce": "6584bedf-2ed0-4c01-93ed-c0c64a1670cc"
}
```

#### 
| `request` | Base64-encoded request data |
For more information on generating the base64-encoded request data, see .
Here’s an example of a payload for an Advanced Commerce API in-app request:
```javascript
{
  "iss": "57246542-96fe-1a63e053-0824d011072a",
  "iat": 1741043663,
  "aud": "advanced-commerce-api",
  "bid": "com.example.testbundleid",
  "nonce": "df2b8374-95a1-425b-a6a5-77a4d7648333",
  "request": "<base64-encoded request data>"
}
```

#### 
| `productId` | The unique identifier of the product (for more information, see ) |
| `offerIdentifier` | The promotional offer identifier that you set up in App Store Connect |
| `transactionId` | The unique identifier of any transaction that belongs to the customer. You can use the customer’s , even for customers who haven’t made any In-App Purchases in your app. This field is optional, but recommended. |
Here’s an example of a payload for a promotional offer signature:
```javascript
{ 
    "iss": "57246542-96fe-1a63e053-0824d011072a",
    "iat": 1741043663,
    "aud": "promotional-offer",
    "bid": "com.example.testbundleid",
    "nonce": "368f3088-dcd5-11ef-b3c8-325096b39f46",
    "productId": "com.example.product",
    "offerIdentifier": "com.example.product.offer",
    "transactionId": "1000011859217"
}
```

#### 
| `productId` | The unique identifier of the product (for more information, see ) |
| `allowIntroductoryOffer` | A Boolean value, `true` or `false`, that determines whether the customer is eligible for an introductory offer |
| `transactionId` | The unique identifier of any transaction that belongs to the customer. You can use the customer’s , even for customers who haven’t made any In-App Purchases in your app. |
Here’s an example of a payload for introductory offer eligibility:
```javascript
{
  "iss": "57246542-96fe-1a63e053-0824d011072a",
  "iat": 1741043663,
  "aud": "introductory-offer-eligibility",
  "bid": "com.example.testbundleid",
  "nonce": "cfb43594-4f92-4fe2-8b06-d947a848adaa",
  "productId": "com.example.product",
  "allowIntroductoryOffer": false,
  "transactionId": "1000011859217"
}
```

#### 

## Generating a Promotional Offer Signature on the Server
> https://developer.apple.com/documentation/storekit/generating-a-promotional-offer-signature-on-the-server

### 
All of the work is done in `routes/index.js`. You set up environment variables for your key ID and your private key in the `start-server` file.
#### 
3. Run `npm install` from the command line, and make sure it completes successfully.
#### 
- Navigate to the sample code source folder and run `./start-server` from the command line. The server is now running locally and is ready to accept connections on port 3000.
- Open another terminal window and use the `curl` command to send a request. This example command uses the same data listed in the JSON example below:
```swift
curl -X GET -H "Content-type: application/json" -d '{"appBundleID": "com.example.yourapp", "productIdentifier": "com.example.yoursubscription", "offerID": "your_offer_id", "applicationUsername": "8E3DC5F16E13537ADB45FB0F980ACDB6B55839870DBCE7E346E1826F5B0296CA"}' http://127.0.0.1:3000/offer
```

#### 
The request must have a `Content-type` header of `application/json`, and JSON body data with the following format:
To run this sample code, send a request to this URL: `GET http://<yourdomain>/offer`, where `<yourdomain>` is the domain name or IP address of the server this sample code is running on.
The request must have a `Content-type` header of `application/json`, and JSON body data with the following format:
```swift
{
    "appBundleID": "com.example.yourapp",
    "productIdentifier": "com.example.yoursubscription",
    "offerID": "your_offer_id",
    "applicationUsername": "8E3DC5F16E13537ADB45FB0F980ACDB6B55839870DBCE7E346E1826F5B0296CA"
}
```


## Generating a signature for promotional offers
> https://developer.apple.com/documentation/storekit/generating-a-signature-for-promotional-offers

### 
#### 
> **important:**  Use lowercase for the string representation of the `nonce` and the `appAccountToken`.
Combine the parameters into a UTF-8 string with an invisible separator (`'\u2063'`) between them in the same order as the following example:
Combine the parameters into a UTF-8 string with an invisible separator (`'\u2063'`) between them in the same order as the following example:
```http
appBundleId + '\u2063' + keyIdentifier + '\u2063' + productIdentifier + '\u2063' + offerIdentifier + '\u2063' + appAccountToken + '\u2063' + nonce + '\u2063' + timestamp
```

If you provide `applicationUsername` instead of `appAccountToken`, replace it accordingly in the UTF-8 string above.
#### 
- Your PKCS #8 private key (downloaded from App Store Connect) that corresponds to the `keyIdentifier` in the UTF-8 string
#### 
Consider validating your signatures locally to ensure your signing process works correctly. You can create a public key derivative of your private key to test against. One way to create this key is by running the `openSSL` command from the terminal app, as the example below shows:
```shell
openssl ec -in {downloaded_private_key} -pubout -out public_key.pem
```

```
Use Base64 encoding for the binary signature you generated to obtain the final signature string to send to the App Store for validation. The signature string resembles the following:
```None
MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg==
```

#### 

## Getting started with In-App Purchase using StoreKit views
> https://developer.apple.com/documentation/storekit/getting-started-with-in-app-purchases-using-storekit-views

### 
### 
### 
### 
In your app, define products that someone can buy, in order to prototype your store. Choose descriptive product IDs that are easy for you to read and understand. In this example, the product IDs describe the product type they represent.
Although you could write product IDs in your code as an array of strings, defining an enumeration whose raw value is a string can help make your code easier to read. For example, when you add a new product, any `switch` that handles product IDs but omits the new product produces a compile-time error.
```swift
enum ProductID: String {
    case consumable = "consumable"
    case consumablePack = "consumable_pack"

    case nonconsumable = "nonconsumable"

    case subscriptionMonthly = "subscription_monthly"
    case subscriptionYearly = "subscription_yearly"
    case subscriptionPremiumYearly = "premium_subscription_yearly"
}
```

### 
StoreKit provides several asynchronous sequences that provide your app with information and updates. For example, the class below checks  and  at startup, and continues to check  in the background while the app is running.
```swift
import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class Store {
    private let defaultsKey = "com.example.consumable count"
    private let nonConsumableDefaultsKey = "com.example.nonconsumable"

    public var consumableCount: Int {
        willSet {
            UserDefaults.standard.set(newValue, forKey: defaultsKey)
        }
    }
    public var boughtNonConsumable: Bool = false
    public var activeSubscription: String? = nil

    init() {
        self.consumableCount = UserDefaults.standard.integer(forKey: defaultsKey)  // Returns 0 on first app launch.

        // Because the tasks below capture 'self' in their closures, this object must be fully initialized before this point.
        Task(priority: .background) {
            // Finish any unfinished transactions -- for example, if the app was terminated before finishing a transaction.
            for await verificationResult in Transaction.unfinished {
                await handle(updatedTransaction: verificationResult)
            }

            // Fetch current entitlements for all product types except consumables.
            for await verificationResult in Transaction.currentEntitlements {
                await handle(updatedTransaction: verificationResult)
            }
        }
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await handle(updatedTransaction: verificationResult)
            }
        }
    }
}
```

```
The `handle(updatedTransaction:)` method handles new verification results from all three sources of updates, to provide access to newly purchased content. For example, this work could include allocating consumable in-game coins, or delivering an in-game object.
```swift
private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
    // The code below handles only verified transactions; handle unverified transactions based on your business model.
    guard case .verified(let transaction) = verificationResult else { return }

    if let _ = transaction.revocationDate {
        // Remove access to the product identified by `transaction.productID`.
        // `Transaction.revocationReason` provides details about the revoked transaction.
        guard let productID = ProductID(rawValue: transaction.productID) else {
            print("Unexpected product: \(transaction.productID).")
            return
        }

        switch productID {
        case .consumable:
            consumableCount -= 1
        case .consumablePack:
            consumableCount -= 10
        case .nonconsumable:
            boughtNonConsumable = false
        case .subscriptionMonthly, .subscriptionYearly, .subscriptionPremiumYearly:
            // In an app that supports Family Sharing, there might be another entitlement that still provides access to the subscription.
            activeSubscription = nil
        }
        await transaction.finish()
        return
    } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
        // In an app that supports Family Sharing, there might be another entitlement that still provides access to the subscription.
        activeSubscription = nil
        return
    } else {
        // Provide access to the product identified by transaction.productID.
        guard let productID = ProductID(rawValue: transaction.productID) else {
            print("Unexpected product: \(transaction.productID).")
            return
        }
        print("transaction ID \(transaction.id), product ID \(transaction.productID)")
        switch productID {
        case .consumable:
            consumableCount += 1
        case .consumablePack:
            consumableCount += 10
        case .nonconsumable:
            boughtNonConsumable = true
        case .subscriptionMonthly, .subscriptionYearly, .subscriptionPremiumYearly:
            // In an app that supports Family Sharing, there might be another entitlement that already provides access to the subscription.
            activeSubscription = transaction.productID
        }
        await transaction.finish()
        return
    }
}
```

### 
### 
After completing the local configuration, you can show all of your products on one page with a simple, compact SwiftUI view.
```swift
import StoreKit
import SwiftUI

struct AllProductsView: View {
    // Your app's data store.
    @Environment(Store.self) private var store: Store

    var body: some View {
        @Bindable var store = store
        VStack {
            // ProductID.all is an array of your product ID strings.
            StoreView(ids: ProductID.all)
                .storeButton(.hidden, for: .cancellation)
                .storeButton(.visible, for: .restorePurchases)
        }
        .padding()
    }
}
```

Here, the `StoreView` view from StoreKit constructs a page and lays out a grid that contains each product, as shown in the following screenshot:

## Handling Subscriptions Billing
> https://developer.apple.com/documentation/storekit/handling-subscriptions-billing

### 
#### 
#### 
#### 
#### 
The App Store renews the subscription slightly before it expires, to prevent any lapse in the subscription. However, lapses are still possible. For example, if the user’s payment information is no longer valid, the first renewal attempt fails. Billing-related issues trigger the subscription to enter a billing retry state where the App Store attempts to renew the subscription for up to 60 days. You can check the `expiration_intent` and `is_in_billing_retry_period` values to monitor the retry status of the subscription. During this period, your app may optionally offer a grace period to the user and show them a message in the app to update their payment information. Additionally, your app can deep link customers to the payment details page within App Store on their device by opening this URL
```http
https://apps.apple.com/account/billing
```

#### 
#### 
#### 
#### 
#### 
Consider building auto-renewable subscription management UI in the app for subscribers to easily move between different subscription levels in their subscription group. Use the  property of `SKProduct` to determine which products to display in the UI. For users who wish to cancel their subscription, your app can open the following URL:
```http
https://apps.apple.com/account/subscriptions
```


## Implementing promotional offers in your app
> https://developer.apple.com/documentation/storekit/implementing-promotional-offers-in-your-app

### 
#### 
The following code example shows how to request a signature from your server and prepare the discount offer.
```swift
// Fetch the signature from your server to be applied to the offer.
// At this point you know the user and the product the offer is for, and which offer you want to display.
public func prepareOffer(usernameHash: String, productIdentifier: String, offerIdentifier: String, completion: (SKPaymentDiscount) -> Void) {

    // Make a secure request to your server, providing the username, product, and discount data
    // Your server will use these values to generate the signature and return it, along with the nonce, timestamp, and key identifier that it uses to generate the signature.
    YourServer.fetchOfferDetails(username: usernameHash, productIdentifier: productIdentifier, offerIdentifier: offerIdentifier, completion: { (nonce: UUID, timestamp: NSNumber, keyIdentifier: String, signature: String) in 

        // Create an SKPaymentDiscount to be used later when the user initiates the purchase
        let discountOffer = SKPaymentDiscount(identifier: offerIdentifier, keyIdentifier: keyIdentifier, nonce: nonce, signature: discountsignature, timestamp: timestamp)

        completion(discountOffer)
    })
}
```

#### 
When the user initiates a buy of the offer in the app, send an  to the App Store with the signed offer. Create an  object that includes the signature you generated and its `identifier`, `keyIdentifier`, `nonce` (one-time use), and `timestamp` parameters. Add this object as the  property to the  object.
Include in the  object the same , often a unique hash of the username, that the signature contains. Add the  object to the queue.
```swift
// An example function that makes a buy request with a promotional offer attached.
public func buyProduct(productIdentifier: SKProduct, forUser usernameHash: String, withOffer discountOffer: SKPaymentDiscount) {

    // The original product being purchased.
    let payment = SKMutablePayment(product: product)

    // You must set applicationUsername to be the same as the one used to generate the signature.
    payment.applicationUsername = usernameHash

    // Add the offer to the payment.
    payment.paymentDiscount = discountOffer

    // Add the payment to the queue for purchase.
    SKPaymentQueue.default().add(payment)
}
```


## Loading in-app product identifiers
> https://developer.apple.com/documentation/storekit/loading-in-app-product-identifiers

### 
#### 
- The app or product doesn’t require a server.
Include a property list file in your app bundle containing an array of product identifiers, such as the following:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <string>com.example.level1</string>
    <string>com.example.level2</string>
    <string>com.example.rocket_car</string>
</array>
</plist>
```

#### 
- Your app or product requires a server.
Host a JSON file on your server with the product identifiers. For example, the following JSON file contains three product IDs:
```xml
[
    "com.example.level1",
    "com.example.level2",
    "com.example.rocket_car"
]
```


## Merchandising win-back offers in your app
> https://developer.apple.com/documentation/storekit/merchandising-win-back-offers-in-your-app

### 
#### 
You may choose to delay this message, or suppress it if you customize the way your app presents win-back offers. Listen for messages using the  asynchronous sequence when your app launches. Intercept the win-back offer message, which has a  reason. After you intercept the message, you can suppress it by not calling `displayStoreMessage`, as in the example below.
The following example code suppresses the win-back offer redemption message, and displays all other App Store messages immediately.
```swift
struct MessageExampleView: View {
    @Environment(\.displayStoreKitMessage) private var displayStoreMessage
    
    var body: some View {
        MyContentView()
            .task {
                for await message in StoreKit.Message.messages {
                    if message.reason != .winBackOffer {
                        // Ask the system to display messages now.
                        try? displayStoreMessage(message)
                    }
                }
            }
    }
}
```

#### 
#### 

## Offering media for sale in your app
> https://developer.apple.com/documentation/storekit/offering-media-for-sale-in-your-app

### 
#### 
1. Set the sample’s `productIdentifier` key to your media’s iTunes identifier. For more information about iTunes identifiers, see .
2. Set the `title` key to your media’s name.
3. Set the `isApplication` key to YES if your media is an app, and NO, otherwise.
To add more data, duplicate and update the `Product` entry in `Products.plist` as necessary.
#### 
This sample launches to the `TableViewController`, which shows a list of media associated with iTunes identifiers in `Products.plist`. When the user taps any item in the list, `TableViewController` presents a page where they can purchase the media from the App Store.
The sample creates a parameters dictionary and sets the  key to the media’s iTunes identifier.
```swift
var parametersDictionary = [SKStoreProductParameterITunesItemIdentifier: product.productIdentifier]
```

```
The sample creates an `SKStoreProductViewController` object and sets the view controller class as its delegate. Then it passes the dictionary to the  method of the `SKStoreProductViewController` object.
```swift
// Create a store product view controller.
let store = SKStoreProductViewController()
store.delegate = self
```

Then the sample presents the `SKStoreProductViewController` object modally.
```
Then the sample presents the `SKStoreProductViewController` object modally.
```swift
/*
   Attempt to load the selected product from the App Store. Display the
   store product view controller if successful. Print an error message,
   otherwise.
*/
store.loadProduct(withParameters: parametersDictionary, completionBlock: {[unowned self] (result: Bool, error: Error?) in
    if result {
        self.present(store, animated: true, completion: {
            print("The store view controller was presented.")
        })
    } else {
        if let error = error {
            print("Error: \(error.localizedDescription)")
        }
    }})
```

#### 
The `SKStoreProductParameterCampaignToken` and `SKStoreProductParameterProviderToken` keys track advertising and promotion for the app. When the user taps an item in the list, `TableViewController` adds these keys and their values to a dictionary, which already contains `SKStoreProductParameterItunesItemIdentifier` with the iTunes identifier.
`TableViewController` passes the dictionary to a created `SKStoreProductViewController` object, and then displays the store product view controller modally.
```swift
/*
    Update `parametersDictionary` with the `campaignToken` and
    `providerToken` values if they exist and the specified `product`
    is an app.
*/
if product.isApplication, !product.campaignToken.isEmpty, !product.providerToken.isEmpty {
    parametersDictionary[SKStoreProductParameterCampaignToken] = product.campaignToken
    parametersDictionary[SKStoreProductParameterProviderToken] = product.providerToken
}
```


## Offering, completing, and restoring in-app purchases
> https://developer.apple.com/documentation/storekit/offering-completing-and-restoring-in-app-purchases

### 
#### 
5. Open the `ProductIds.plist` file in the sample and update its content with your existing in-app purchases product IDs.
#### 
The sample configures the app so it confirms that the user has authorization to make payments on the device before presenting products for sale.
```swift
var isAuthorizedForPayments: Bool {
    return SKPaymentQueue.canMakePayments()
}
```

```
After the app confirms authorization, it sends a products request to the App Store to fetch localized product information. Querying the App Store ensures that the app only presents users with products available for purchase. The app initializes the products request with a list of product identifiers associated with products to sell in its UI. Be sure to keep a strong reference to the products request object; the system may release it before the request completes. See  for more information.
```swift
fileprivate func fetchProducts(matchingIdentifiers identifiers: [String]) {
    // Create a set for the product identifiers.
    let productIdentifiers = Set(identifiers)
    
    // Initialize the product request with the above identifiers.
    productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productRequest.delegate = self
    
    // Send the request to the App Store.
    productRequest.start()
}
```

```
The App Store responds to the products request with an  object. Its  property contains information about all the products that are available for purchase in the App Store. The app uses this property to update its UI. The response’s `invalidProductIdentifiers` property includes all product identifiers that the App Store doesn’t recognize. See `invalidProductIdentifiers` for reasons the App Store may return invalid product identifiers.
```swift
// Contains products with identifiers that the App Store recognizes. As such, they are available for purchase.
if !response.products.isEmpty {
    availableProducts = response.products
}

// invalidProductIdentifiers contains all product identifiers that the App Store doesn’t recognize.
if !response.invalidProductIdentifiers.isEmpty {
    invalidProductIdentifiers = response.invalidProductIdentifiers
}
```

```
To display the price of a product in the UI, the app uses the locale and currency that the App Store returns. For instance, consider a user who is logged in to the French App Store and their device uses the United States locale. When attempting to purchase a product, the App Store displays the product’s price in Euros. Converting and showing the product’s price in U.S. dollars to match the device’s locale would be incorrect.
```swift
extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}
```

#### 
#### 
When a transaction is pending in the payment queue, StoreKit notifies the app’s transaction observer by calling its  method. Every transaction has five possible states, including , , , , and . For more information, see . The observer’s `paymentQueue(_:updatedTransactions:)` needs to be able to respond to any of these states at any time.
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        switch transaction.transactionState {
        case .purchasing: break
        // Don’t block the UI. Allow the user to continue using the app.
        case .deferred: print(Messages.deferred)
        // The purchase was successful.
        case .purchased: handlePurchased(transaction)
        // The transaction failed.
        case .failed: handleFailed(transaction)
        // There are restored products.
        case .restored: handleRestored(transaction)
        @unknown default: fatalError(Messages.unknownPaymentTransaction)
        }
    }
}
```

```
When a transaction fails, the app inspects the  property to determine what happened. The app only displays errors with code that is different from .
```swift
// Don’t send any notifications when the user cancels the purchase.
if (transaction.error as? SKError)?.code != .paymentCancelled {
    DispatchQueue.main.async {
        self.delegate?.storeObserverDidReceiveMessage(message)
    }
}
```

#### 
When users purchase non-consumables, auto-renewable subscriptions, or non-renewing subscriptions, they expect them to be available on all their devices indefinitely. The app provides a UI that allows users to restore their past purchases. See  for more information.
```swift
@IBAction func restore(_ sender: UIBarButtonItem) {
    // Calls StoreObserver to restore all restorable purchases.
    StoreObserver.shared.restore()
}
```

#### 
Unfinished transactions stay in the payment queue. StoreKit calls the app’s persistent observer’s `paymentQueue(_:updatedTransactions:)` each time upon launching or resuming from the background until the app finishes these transactions. As a result, the App Store may repeatedly prompt users to authenticate their purchases or prevent them from purchasing products from the app.
The sample calls  on transactions with a state of `.failed`, `.purchased`, or `.restored` to remove them from the queue. Finished transactions aren’t recoverable. Therefore, apps need to provide the purchased content or complete their purchase process before finishing transactions.
```swift
// Finish the successful transaction.
SKPaymentQueue.default().finishTransaction(transaction)
```


## Promoting In-App Purchases
> https://developer.apple.com/documentation/storekit/promoting-in-app-purchases

### 
#### 
In the delegate method, return `true` to continue the transaction, or `false` to defer or cancel it.
#### 
To continue an in-app purchase transaction, implement the delegate method in the  protocol and return `true`. StoreKit then displays the payment sheet, and the user can complete the transaction.
```swift
//Continuing a transaction from the App Store.

//MARK: - SKPaymentTransactionObserver

func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment,
        for product: SKProduct) -> Bool {
    // Check to see if you can complete the transaction.
    // Return true if you can.
    return true
}
```

#### 
2. Return `false`.
1. Return `false`.
1. Return `false`.
2. Provide feedback to the user. Although this step is optional, if you don’t provide feedback, the app’s lack of action after the user selects to purchase an in-app product in the App Store may seem like a bug.
```swift
//Handling a transaction from the App Store.

//MARK: - SKPaymentTransactionObserver

func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment,
        for product: SKProduct) -> Bool {

    // Add code here to check if your app needs to defer the transaction.
    let shouldDeferPayment = ...
    // If you need to defer until onboarding is complete, save the payment and return false.
    if shouldDeferPayment {
        self.savedPayment = payment
        return false
    }

    // Add code here to check if your app needs to cancel the transaction.
    let shouldCancelPayment = ...
    // If you need to cancel the transaction, then return false:
    if shouldCancelPayment {
        return false
    }
}

// If you cancel the transaction, provide feedback to the user.

// Continuing a previously deferred payment.
SKPaymentQueue.default().add(savedPayment)
```

#### 
To get the visibility settings for a promoted product, call , providing the product information.
```swift
// Reading visibility override of a promoted in-app purchase.

// Fetch product info for "Hidden Beaches pack."

let storePromotionController = SKProductStorePromotionController.default()
storePromotionController.fetchStorePromotionVisibility(forProduct: hiddenBeaches,
    completionHandler: { visibility: SKProductSTorePromotionVisiblity, error: Error?) in
        // visibility == .default
})
```

#### 
For each device, you can decide whether to make in-app purchases visible or hidden. For example, you may want to hide products the customer already purchased, and show only the products they can buy.
For example, to hide the Pro Subscription product after a user purchases it, fetch the product information and update the store promotion controller with the `.hide` setting, as the following code example shows. The Pro Subscription promoted in-app purchase no longer appears in the App Store on the device.
```swift
// Hide the promoted product Pro Subscription after the user purchases it.

let storePromotionController = SKProductStorePromotionController.default()
storePromotionController.update(storePromotionVisibility: .hide, for: proSubscription,
    completionHandler: { (error: Error?) in
        // Completion.
    })
```

#### 
You can customize the promoted in-app purchases on each device by overriding their default order. Use overrides to show promotions that are relevant to the user. For example, you can override the order to promote an in-app purchase that unlocks a level in your game when a user reaches the preceding level.
To override the promotion order, add the product information to an array in the order they are to appear. Pass the array to the  method. The App Store displays the products in the array, followed by the remaining promoted products, which appear in the same relative order that you set in App Store Connect.
```swift
// Overriding the order of promoted in-app purchases.

// Fetch product information for three products: Pro Subscription, Fishing Hot Spots, and Hidden Beaches.
let storePromotionController = SKProductStorePromotionController.default()

// Update the order.
let newProductsOrder = [hiddenBeaches, proSubscription, fishingHotSpots]
storePromotionController.updateStorePromotionOrder(newProductsOrder,
    completionHandler: { (error: Error?) in
        // Complete.
    })
```

#### 
#### 
To get the product promotion order for the device, call . This method returns an array of products that have an overridden order. If you get an empty array, there aren’t any overrides and the products are in the default order.
```swift
// Getting the order override of promoted in-app purchases.

let storePromotionController = SKProductStorePromotionController.default()
storePromotionController.fetchStorePromotionOrder(completionHandler: {
    (products: [SKProduct], error: Error?) in
        // products == [hiddenBeaches, proSubscription, fishingHotSpots]
    })
```


## Receiving and decoding external purchase tokens
> https://developer.apple.com/documentation/storekit/receiving-and-decoding-external-purchase-tokens

### 
#### 
| Customer installs an app for the first time across all of their devices | The system generates both the `ACQUISITION` and `SERVICES` tokens. |
#### 
- Request an `IN_APP` token type for flows that use an alternative payment provider inside the app
- Request a `LINK_OUT` token type for flows where customers can complete transactions on your website, outside of the app
#### 
The  endpoint requires the  field to report tokens and transactions. To get the `externalPurchaseId`, decode the token string using Base64URL decoding.
The following example shows an external purchase token. For a token string that is:
```None
ewoJImFwcEFwcGxlSWQiOjEyMzQ1Njc4OTAsCgkiYnVuZGxlSWQiOiJjb20uZXhhbXBsZSIsCgkidG9rZW5DcmVhdGlvbkRhdGUiOjE3MDYxNjk2MDAwMDAsCgkiZXh0ZXJuYWxQdXJjaGFzZUlkIjoiMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIgp9
```

```
The token’s value after Base64URL decoding is the following JSON:
```json
{  
  "appAppleId":1234567890,  
  "bundleId":"com.example",  
  "tokenCreationDate":1706169600000,
  "externalPurchaseId":"00000000-0000-0000-0000-000000000000"
}
```

The following example shows a custom link token with a `SERVICES` token type. The token string is:
```
The following example shows a custom link token with a `SERVICES` token type. The token string is:
```None
eyJhcHBBcHBsZUlkIjoxMjM0NTY3ODkwLCJidW5kbGVJZCI6ImNvbS5leGFtcGxlIiwidG9rZW5DcmVhdGlvbkRhdGUiOjE3NTA4OTYwMDAwMDAsImV4dGVybmFsUHVyY2hhc2VJZCI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwLTAwMDAwMDAwMDAwMCIsInRva2VuVHlwZSI6IlNFUlZJQ0VTIiwidG9rZW5FeHBpcmF0aW9uRGF0ZSI6MTc4MjQzMjAwMDAwMH0K
```

```
The custom link token’s value after Base64URL decoding is the following JSON:
```json
{
  "appAppleId": 1234567890,
  "bundleId": "com.example",
  "tokenCreationDate": 1750896000000,
  "externalPurchaseId": "00000000-0000-0000-0000-000000000000",
  "tokenType": "SERVICES", // Present only in custom link tokens
  "tokenExpirationDate": 1782432000000 // Present only in custom link tokens
}
```

#### 
The  API returns external purchase tokens that are specific to the app’s environment: production or sandbox. You can recognize a token for the sandbox environment by its `externalPurchaseId` property, which always begins with `SANDBOX`.
The following example is an external purchase token that the system created in the sandbox environment. The sandbox token string is:
```None
eyJhcHBBcHBsZUlkIjoxMjM0NTY3ODkwLCJidW5kbGVJZCI6ImNvbS5leGFtcGxlIiwidG9rZW5DcmVhdGlvbkRhdGUiOjE3MDYxNjk2MDAwMDAsImV4dGVybmFsUHVyY2hhc2VJZCI6IlNBTkRCT1hfMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIiwidG9rZW5UeXBlIjoiU0VSVklDRVMiLCJ0b2tlbkV4cGlyYXRpb25EYXRlIjoxNzA2MTczMjAwMDAwfQo=
```

```
The token’s JSON content after Base64URL decoding is:
```json
{
    "appAppleId":1234567890,
    "bundleId":"com.example",
    "tokenCreationDate":1706169600000,
    "externalPurchaseId":"SANDBOX_00000000-0000-0000-0000-000000000000"
}
```

```
The following example is a custom link token with a `SERVICES` token type, that the system created in the sandbox environment. The sandbox token string is:
```None
eyJhcHBBcHBsZUlkIjoxMjM0NTY3ODkwLCJidW5kbGVJZCI6ImNvbS5leGFtcGxlIiwidG9rZW5DcmVhdGlvbkRhdGUiOjE3MzA0NDg3MjAwMDAsImV4dGVybmFsUHVyY2hhc2VJZCI6IlNBTkRCT1hfMDAwMDAwMDAtMDAwMC0wMDAwLTAwMDAtMDAwMDAwMDAwMDAwIiwidG9rZW5UeXBlIjoiU0VSVklDRVMiLCJ0b2tlbkV4cGlyYXRpb25EYXRlIjoxNzMwNDUyMzIwMDAwfQ==
```

```
The custom link token’s JSON content after Base64URL decoding is:
```json
{
  "appAppleId": 1234567890,
  "bundleId": "com.example",
  "tokenCreationDate": 1706169600000,
  "externalPurchaseId": "SANDBOX_00000000-0000-0000-0000-000000000000",
  "tokenType": "SERVICES", // Present only in custom link tokens
  "tokenExpirationDate": 1706173200000 // Present only in custom link tokens
}
```


## Reducing Involuntary Subscriber Churn
> https://developer.apple.com/documentation/storekit/reducing-involuntary-subscriber-churn

### 
#### 
Your app may optionally present in-app messaging that informs users they can avoid losing access to paid service by taking action and resolving their billing error. If you choose to prompt the user, ensure your app’s subscription logic can handle different values of  along with , to show the appropriate message. An invalid payment method could be due to a number of things, such as a low balance on a stored value card or an expired credit card. Your app should be ready to react immediately to a billing information update. Your app can deep link customers to the Manage Payments page on their account settings by opening this URL:
```http
https://apps.apple.com/account/billing
```

#### 
#### 

## Requesting App Store reviews
> https://developer.apple.com/documentation/storekit/requesting-app-store-reviews

### 
#### 
To present a review request, the app reads the  environment value to get an instance of `RequestReviewAction` and calls it as a function:
- A person must pause on the Process Completed scene for a few seconds. This requirement limits the possibility of the prompt interrupting them before they move to a different task in the app.
To present a review request, the app reads the  environment value to get an instance of `RequestReviewAction` and calls it as a function:
```swift
@Environment(\.requestReview) private var requestReview
```

```
The conditions above exist purely to delay the call to `requestReview`, so days, weeks, or even months can elapse without the app prompting a user for a review.
```swift
/// Presents the rating and review request view after a two-second delay.
private func presentReview() {
    Task {
        // Delay for two seconds to avoid interrupting the person using the app.
        try await Task.sleep(for: .seconds(2))
        await requestReview()
    }
}
```

```
Techniques to delay the call are valuable because they cause an app to show a review request when people are more experienced at using the app and can provide better feedback.
```swift
/*
    The lastVersionPromptedForReview property stores the version of the app that last prompts for a review.
    The app presents the rating and review request view if the person completed the three-step process at least four times and
    its current version is different from the version that last prompted them for review.
*/
if processCompletedCount >= 4, currentAppVersion != lastVersionPromptedForReview {
    presentReview()
        
    // The app already displayed the rating and review request view. Store this current version.
    lastVersionPromptedForReview = currentAppVersion
}
```

```
In the following code, the app stores the usage data that delays the review request in :
```swift
/// An identifier for the three-step process the person completes before this app chooses to request a review.
@AppStorage("processCompletedCount") var processCompletedCount = 0

/// The most recent app version that prompts for a review.
@AppStorage("lastVersionPromptedForReview") var lastVersionPromptedForReview = ""
```

#### 
To enable a person to initiate a review as a result of an action in the UI, the sample code uses a deep link to the App Store page for the app with the query parameter `action=write-review` appended to the URL:
```swift
// Replace the YOURAPPSTOREID value below with the App Store ID for your app.
// You can find the App Store ID in your app's product URL.
let url = "https://apps.apple.com/app/idYOURAPPSTOREID?action=write-review"

guard let writeReviewURL = URL(string: url) else {
    fatalError("Expected a valid URL")
}

openURL(writeReviewURL)
```


## Sending Advanced Commerce API requests from your app
> https://developer.apple.com/documentation/storekit/sending-advanced-commerce-api-requests-from-your-app

### 
4. In your app, use the `advancedCommerceRequestData` as the value of a purchase option in your product purchase call.
### 
Place the Advanced Commerce request data in a UTF-8 JSON string and base64-encode the request.
For example, the following JSON represents a  for the purchase of a one-time charge product:
```JSON
{
    "operation": "CREATE_ONE_TIME_CHARGE",
    "version": "1",                     
    "requestInfo": {
        "requestReferenceId": "f55df048-4cd8-4261-b404-b6f813ff70e5"
    },
    "currency": "USD",
    "taxCode": "C003-00-2", 
    "storefront": "USA",
    "item": {
        "SKU": "BOOK_SHERLOCK_HOMLES",
        "displayName": "Sherlock Holmes", 
        "description": "The Sherlock Holmes, 5th Edition",
        "price": 4990
    }
}
```

### 
### 
Wrap the JWS to create a `signatureInfo` JSON string that contains a `token` key.  You can complete this step on your server or in your app. Create the `signatureInfo` JSON string as shown below:
```JSON
{
    "signatureInfo": {
        "token": "<your JWS compact serialization>"
    }
}
```

Set the value of the `token` key to your JWS compact serialization.
Next, convert the `signatureInfo` JSON string into a `Data` buffer, as shown below:
Set the value of the `token` key to your JWS compact serialization.
Next, convert the `signatureInfo` JSON string into a `Data` buffer, as shown below:
```swift
let jsonString ="<# your signatureInfo UTF-8 JSON string>"
let advancedCommerceRequestData = Data(jsonString.utf8)
```

The result is the Advanced Commerce request data object, referred to as `advancedCommerceRequestData` in the code snippets.
Securely send the `advancedCommerceRequestData` to your app.
### 
To complete the Advanced Commerce request in the app, call a StoreKit purchase method and provide the signed request, in the Advanced Commerce request data form, as a purchase option.
The following code example sets up the purchase request:
```swift
let purchaseResult = try await product.purchase(
    options: [ 
        Product.PurchaseOption.custom( 
            key: “advancedCommerceData”, 
            value: advancedCommerceRequestData
        )
    ]
)
```

- Use the custom key `"advancedCommerceData"` for all Advanced Commerce in-app requests. For more information about the custom purchase option, see .

## Setting up the transaction observer for the payment queue
> https://developer.apple.com/documentation/storekit/setting-up-the-transaction-observer-for-the-payment-queue

### 
#### 
Create and build a custom observer class to handle changes to the payment queue.
```swift
class StoreObserver: NSObject, SKPaymentTransactionObserver {
                ....
    //Initialize the store observer.
    override init() {
        super.init()
        //Other initialization here.
    }

    //Observe transaction updates.
    func paymentQueue(_ queue: SKPaymentQueue,updatedTransactions transactions: [SKPaymentTransaction]) {
        //Handle transaction states here.
    }
                ....
}
```

```
Create an instance of this observer class to act as the observer of changes to the payment queue.
```swift
let iapObserver = StoreObserver()
```

#### 
StoreKit attaches your observer to the queue when your app calls.
```swift
SKPaymentQueue.default().add(iapObserver)
```

StoreKit can notify your  instance automatically when the content of the payment queue changes upon resuming or while running your app.
Implement the transaction observer.
```swift
import UIKit
import StoreKit

class AppDelegate: UIResponder, UIApplicationDelegate {
                ....
    // Attach an observer to the payment queue.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SKPaymentQueue.default().add(iapObserver)
        return true
    }

    // The system calls this when the app is about to terminate.
    func applicationWillTerminate(_ application: UIApplication) {
        // Remove the observer.
        SKPaymentQueue.default().remove(iapObserver)
    }
                ....
}
```


## Supporting business model changes by using the app transaction
> https://developer.apple.com/documentation/storekit/supporting-business-model-changes-by-using-the-app-transaction

### 
#### 
1. The app’s code includes a constant that indicates the version the business model changed; that constant is `"2"` in this example.
#### 
The code examples below demonstrate how an app obtains an , compares the  with a constant that represents a specific app version, and then determines the customer’s entitlements.
Here’s how it looks in macOS:
```swift
do {
    // Get the `appTransaction`.
    let shared = try await AppTransaction.shared
    if case .verified(let appTransaction) = shared {
        // Hard-code the major version number in which the app's business model changed.
        let newBusinessModelMajorVersion = "2" 

        // Get the major version number of the version the customer originally purchased.
        let versionComponents = appTransaction.originalAppVersion.split(separator: ".")
        let originalMajorVersion = versionComponents[0]

        if originalMajorVersion < newBusinessModelMajorVersion {
            // This customer purchased the app before the business model changed.
            // Deliver content that they're entitled to based on their app purchase.
        }
        else {
            // This person purchased the app after the business model changed.
        }
    }
}
catch {
    // Handle errors.
}

// Iterate over any other products they purchased.
for await result in Transaction.currentEntitlements {
    if case .verified(let transaction) = result {
        // Deliver the content based on their current entitlements.
    }
}
```

```
Here’s an example of the code for an app in iOS, tvOS, watchOS, and visionOS:
```swift
do {
    // Get the `appTransaction`.
    let shared = try await AppTransaction.shared
    if case .verified(let appTransaction) = shared {
        // Hard-code the `CFBundleVersion` number in which the app's business model changed.
        let newBusinessModelVersion = "2"

        // Compare this number with the version number the person originally purchased.
        if appTransaction.originalAppVersion < newBusinessModelVersion {
            // Handle a case in which a person purchased the app before the business model changed.
            // Deliver content that they're entitled to based on their app purchase.
        }
        else {
            // This person purchased the app after the business model changed.
        }
    }
}
catch {
    // Handle errors.
}

// Iterate over any other products they purchased.
for await result in Transaction.currentEntitlements {
    if case .verified(let transaction) = result {
    // Deliver the content based on their current entitlements.
    }
}
```


## Supporting promoted In-App Purchases in your app
> https://developer.apple.com/documentation/storekit/supporting-promoted-in-app-purchases-in-your-app

### 
#### 
#### 
To complete the transaction, call the  method on the  of the . Follow the same workflow your app uses for any In-App Purchase, such as unlocking the purchased content and finishing the transaction ().
The following code example listens for purchase intents from the App Store. It receives a  object when the user taps a promoted In-App Purchase on the App Store, and performs its purchase workflow.
```swift
for await purchaseIntent in PurchaseIntent.intents {
    // Complete the purchase workflow.
    do {
        try await purchaseIntent.product.purchase()
    }
    catch {
        <#Handle Error#>
    }
}
```

#### 
#### 
These overrides are specific to the device, and take effect after the user launches the app at least once.
The following code example uses an array of product identifiers to set their order. It calls  to get the  objects, and sets their visibility directly. It then calls  to save the changes.
```swift
// Set the product order.
let orderedProductIdentifiers = [
    "com.example.ExampleApp.product1",
    "com.example.ExampleApp.product2",
    "com.example.ExampleApp.product3"
]

do {
    try await Product.PromotionInfo.updateProductOrder(byID: orderedProductIdentifiers)
}
catch {
    <#Handle Error#>
}

// Get the current product order.
var promotions: [Product.PromotionInfo] = []

do {
    promotions = try await Product.PromotionInfo.currentOrder
}
catch {
    <#Handle Error#>
}

// Set the visibility for all the products and save the changes.
for i in promotions.indices {
    promotions[i].visibility = .visible
}

do {
    try await Product.PromotionInfo.updateAll(promotions)
}
catch {
    <#Handle Error#>
}
```

```
The following code example hides a promoted product after the user purchases it:
```swift
// Change the visibility to hide a promoted product after a user purchases it.
let purchasedProductIdentifier = "com.example.ExampleApp.product1"

do {
    try await Product.PromotionInfo.updateProductVisibility(.hidden, for: purchasedProductIdentifier)
}
catch {
    <#Handle Error#>
}
```

#### 
#### 

## Supporting win-back offers in your app
> https://developer.apple.com/documentation/storekit/supporting-win-back-offers-in-your-app

### 
#### 
#### 
#### 
#### 
#### 
#### 
4. Your app calls the  method on the  of the  to enable the customer to complete the purchase. Be sure to add the win-back offer to the purchase options.
The following example checks the  property of  to detect whether the purchase intent is for a win-back offer, and adds the offer to the purchase options:
```swift
// Prepare the purchase options.
var purchaseOptions: Set<Product.PurchaseOption> = []

// Add the win-back offer to the purchase.
if let offer = purchaseIntent.offer, offer.type == .winBack {
    purchaseOptions.insert(.winBackOffer(offer))
}

// Present the purchase.
let result = try await purchaseIntent.product.purchase(options: purchaseOptions)
```

#### 
- In your app, check the  property, . An offer type value of `winback` indicates the customer redeemed a win-back offer.
#### 

## Testing In-App Purchases in Xcode
> https://developer.apple.com/documentation/storekit/testing-in-app-purchases-in-xcode

### 
#### 
#### 
The test environment’s certificate is a root certificate. There’s no certificate chain to validate when you verify the receipt signature. The following code example retrieves the local receipt:
```swift
// Get the receipt if it's available.
if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
    FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
    do {
        let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
        let receiptString = receiptData.base64EncodedString(options: [])
        // Add code to read receiptData.
    }
    catch { 
        print("Couldn't read receipt data: " + error.localizedDescription) }
}
```

#### 
#### 
#### 
#### 
#### 
#### 
#### 
#### 

## Unlocking purchased content
> https://developer.apple.com/documentation/storekit/unlocking-purchased-content

### 
#### 
Or, using the user defaults system.
After you define the Boolean variable that represents the in-app purchase content, use the purchase information to enable the appropriate code paths in your app.
```swift
if (rocketCarEnabled) {
    // Use the rocket car.
} else {
    // Use the regular car.
}
```

#### 
#### 
Load local content using the `NSBundle` class as you load other resources from your app bundle.
#### 
#### 
#### 

