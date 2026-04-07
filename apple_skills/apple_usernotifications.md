# Apple USERNOTIFICATIONS Skill


## Asking permission to use notifications
> https://developer.apple.com/documentation/usernotifications/asking-permission-to-use-notifications

### 
#### 
To ask for authorization, get the shared  instance and call its  method. Specify all of the interaction types that your app employs. For example, you can request authorization to display alerts, add a badge to the app icon, or play sounds:
```swift
let center = UNUserNotificationCenter.current()

do {
    try await center.requestAuthorization(options: [.alert, .sound, .badge])
} catch {
    // Handle the error here.
}
    
// Enable or disable features based on the authorization.
```

#### 
If the person presses the Turn Off button, the system confirms the selection before denying your app authorization to send additional notifications.
To request provisional authorization, add the  option when requesting permission to send notifications.
```swift
let center = UNUserNotificationCenter.current()

do {
    try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
} catch {
    // Handle errors that may occur during requestAuthorization.
}
```

#### 
Always check your app’s authorization status before scheduling local notifications. People can change your app’s authorization settings at any time. They can also change the type of interactions allowed by your app — which may cause you to alter the number or type of notifications your app sends.
To provide the best experience for people, call the notification center’s  method to get the current notification settings. Then customize the notification based on these settings.
```swift
let center = UNUserNotificationCenter.current()

// Obtain the notification settings.
let settings = await center.notificationSettings()

// Verify the authorization status.
guard (settings.authorizationStatus == .authorized) ||
      (settings.authorizationStatus == .provisional) else { return }

if settings.alertSetting == .enabled {
    // Schedule an alert-only notification.
} else {
    // Schedule a notification with a badge and sound.
}
```


## Declaring your actionable notification types
> https://developer.apple.com/documentation/usernotifications/declaring-your-actionable-notification-types

### 
#### 
Listing 1 shows how to register a custom category with two actions. In addition to a title and options, each action has a unique identifier. When the user selects the action, the system passes that identifier to your app.
Listing 1. Registering actions and notification types
```swift
// Define the custom actions.
let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
      title: "Accept", 
      options: [])
let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
      title: "Decline", 
      options: [])
// Define the notification type
let meetingInviteCategory = 
      UNNotificationCategory(identifier: "MEETING_INVITATION",
      actions: [acceptAction, declineAction], 
      intentIdentifiers: [], 
      hiddenPreviewsBodyPlaceholder: "",
      options: .customDismissAction)
// Register the notification type.
let notificationCenter = UNUserNotificationCenter.current()
notificationCenter.setNotificationCategories([meetingInviteCategory])
```

#### 
To assign a category to a local notification, assign the appropriate string to the  property of your  object. Listing 2 shows the creation of the content for a local notification. In addition to the basic information, this code also adds custom data to the notification’s  dictionary, which it uses later to process the invitation.
Listing 2. Assigning a category to a local notification
```swift
let content = UNMutableNotificationContent()
content.title = "Weekly Staff Meeting"
content.body = "Every Tuesday at 2pm"
content.userInfo = ["MEETING_ID" : meetingID, 
                    "USER_ID" : userID ]
content.categoryIdentifier = "MEETING_INVITATION"
```

To add a category identifier to a remote notification, include the `category` key in the `aps` dictionary of your JSON payload, as shown in Listing 3. Set the value of this key to the appropriate category string. In the example, the category is set to the same meeting invitation category that was previously defined. As in the local notification example, the payload includes custom keys with the meeting ID and user ID, which are put into the payload’s  dictionary. The app can use that information to accept or decline the invitation.
Listing 3. Assigning a category to a remote notification
```other
{
   "aps" : {
      "category" : "MEETING_INVITATION"
      "alert" : {
         "title" : "Weekly Staff Meeting"
         "body" : "Every Tuesday at 2pm"
      },
   },
   "MEETING_ID" : "123456789",
   "USER_ID" : "ABCD1234"

} 
```

#### 
Listing 4 shows an implementation of the delegate method for an app that manages meeting invitations. The method uses the  property of the response to determine whether to accept or decline a given invitation. It also relies on custom data from the notification payload to process the notification successfully. Always call the completion handler after you finish handling the action.
Listing 4. Performing a selected action
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
       didReceive response: UNNotificationResponse,
       withCompletionHandler completionHandler: 
         @escaping () -> Void) {
       
   // Get the meeting ID from the original notification.
   let userInfo = response.notification.request.content.userInfo
   let meetingID = userInfo["MEETING_ID"] as! String
   let userID = userInfo["USER_ID"] as! String
        
   // Perform the task associated with the action.
   switch response.actionIdentifier {
   case "ACCEPT_ACTION":
      sharedMeetingManager.acceptMeeting(user: userID, 
                                    meetingID: meetingID)
      break
        
   case "DECLINE_ACTION":
      sharedMeetingManager.declineMeeting(user: userID, 
                                     meetingID: meetingID)
      break
        
   // Handle other actions...
   default:
      break
   }
    
   // Always call the completion handler when done.    
   completionHandler()
}
```


## Establishing a connection to Apple Push Notification service (APNs)
> https://developer.apple.com/documentation/usernotifications/establishing-a-connection-to-apns

### 
#### 
#### 
#### 
The code listing below verifies the `TLS` handshake with device push notifications sandbox endpoint
You can verify the TLS handshake between your provider server and APNs by running the `OpenSSL s_client` command from your server, as shown below. This command can also show if your `TLS/SSL` certificates are expired or revoked.
The code listing below verifies the `TLS` handshake with device push notifications sandbox endpoint
```Other
$ openssl s_client -connect api.development.push.apple.com:443 -cert YourSSLCertAndPrivateKey.pem -debug 
-showcerts -CAfile server-ca-cert.pem
```


## Establishing a token-based connection to APNs
> https://developer.apple.com/documentation/usernotifications/establishing-a-token-based-connection-to-apns

### 
#### 
#### 
#### 
- An authentication token signing key, specified as a text file (with a `.p8` file extension).
For detailed instructions on how to use an authentication token, see the `authorization` header field in .
#### 
| `alg` | The encryption algorithm you used to encrypt the token. APNs supports only the ES256 algorithm, so set the value of this key to `ES256`. |
| `kid` | The 10-character Key ID you obtained from your developer account; see . |
| `iat` | The “issued at” time, whose value indicates the time when the JSON token generated. Specify the value as the number of seconds since Epoch, in UTC. The value must be no more than one hour from the current time. |
The keys divide between the header and claims payload of the JSON Web Token. The header of the token contains the encryption algorithm and Key ID, and the claims payload contains your Team ID and the token generation time. The code snippet below shows an example of a JSON token for a fictional developer account.
```other
{
   "alg" : "ES256",
   "kid" : "ABC123DEFG"
}
{
   "iss": "DEF123GHIJ",
   "iat": 1437179036
}
```

#### 
When creating the POST request for a notification, include your encrypted token in the `authorization` header of your request. The token is in Base64URL-encoded JWT format, and is specified as `bearer <token data>`, as shown in the following example:
```other
authorization = bearer eyAia2lkIjogIjhZTDNHM1JSWDciIH0.eyAiaXNzIjogIkM4Nk5WOUpYM0QiLCAiaWF0I
		 jogIjE0NTkxNDM1ODA2NTAiIH0.MEYCIQDzqyahmH1rz1s-LFNkylXEa2lZ_aOCX4daxxTZkVEGzwIhALvkClnx5m5eAT6
		 Lxw7LZtEQcH6JENhJTMArwLf3sXwi

```

#### 
#### 

## Generating a remote notification
> https://developer.apple.com/documentation/usernotifications/generating-a-remote-notification

### 
#### 
Listing 1 shows a notification payload that displays an alert message inviting the user to play a game. If the `category` key identifies a previously registered  object, the system adds action buttons to the alert. For example, the category here includes a play action to start the game immediately. The custom `gameID` key contains an identifier that the app can use to retrieve the game invitation.
Listing 1. A remote notification payload for showing an alert
```json
{
   "aps" : {
      "alert" : {
         "title" : "Game Request",
         "subtitle" : "Five Card Draw",
         "body" : "Bob wants to play poker"
      },
      "category" : "GAME_INVITATION"
   },
   "gameID" : "12345678"
}
```

Listing 2 shows a notification payload that badges the app’s icon and plays a sound. The specified sound file must be on the user’s device already, either in the app’s bundle or in the `Library/Sounds` folder of the app’s container. The `messageID` key contains app-specific information for identifying the message that caused the notification.
Listing 2. A remote notification payload for playing a sound
```json
{
   "aps" : {
      "badge" : 9,
      "sound" : "bingbong.aiff"
   },
   "messageID" : "ABCDEFGHIJ"
}
```

#### 
If the text of your notification messages is predetermined, you can store your message strings in the `Localizable.strings` file of your app bundle and use the `title-loc-key`, `subtitle-loc-key`, and `loc-key` payload keys to specify which strings you want to display. Your localized strings may contain placeholders so that you can insert content dynamically into the final string. Listing 3 shows an example of a payload with a message derived from an app-provided string. The `loc-args` key contains an array of replacement variables to substitute into the string.
Listing 3. A remote notification payload with localized content
```json
{
   "aps" : {
      "alert" : {
         "loc-key" : "GAME_PLAY_REQUEST_FORMAT",
         "loc-args" : [ "Shelly", "Rick"]
      }
   }
}
```

#### 
Table 1. Keys to include in the `aps` dictionary
| `badge` | Number | The number to display in a badge on your app’s icon. Specify `0` to remove the current badge, if any. |
| `thread-id` | String | An app-specific identifier for grouping related notifications. This value corresponds to the  property in the  object. |
| `category` | String | The notification’s type. This string must correspond to the  of one of the  objects you register at launch time. See . |
Table 2. Keys to include in the `alert` dictionary
| `subtitle` | String | Additional information that explains the purpose of the notification. |
| `body` | String | The content of the alert message. |
Table 3 lists the keys that you may include in the `sound` dictionary. Use these keys to configure the sound for a critical alert.
Table 3. Keys to include in the `sound` dictionary
| `critical` | Number | The critical alert flag. Set to `1` to enable the critical alert. |
| `volume` | Number | The volume for the critical alert’s sound. Set this to a value between `0` (silent) and `1` (full volume). |

## Handling Communication Notifications and Focus Status Updates
> https://developer.apple.com/documentation/usernotifications/handling-communication-notifications-and-focus-status-updates

### 
#### 
#### 
Donate an intent interaction for each communication that takes place in the app. The app should donate both outgoing and incoming communication interactions. Donate incoming interactions to update communication notifications and enable their unique user experience and breakthrough behavior. Donate outgoing interactions when the current user sends messages or initiates calls. This allows the system to make better suggestions and provide communication notification functionality.
The sample initializes interactions in `CommunicationMapper.ineraction(communicationInformation:)` and donates them in the `suggest(communicationInformation:completion:)` method. The provided communication information determines the interaction’s direction.
```swift
    /// Outgoing messages and calls suggest people involved for Focus breakthrough.
    static func suggest(communicationInformation: CommunicationInformation,
                        completion: @escaping (Result<INInteraction, Error>) -> Void) {
        do {
            // Create an INInteraction.
            let interaction = try CommunicationMapper.interaction(communicationInformation: communicationInformation)
            // Donate INInteraction to the system.
            interaction.donate { [completion] error in
                DispatchQueue.global(qos: .userInitiated).async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(interaction))
                    }
                }
            }
        } catch let error {
            // Catch CommunicationMapper errors.
            completion(.failure(error))
        }
    }
```

#### 
To display a communication notification, your app should update the notification’s content. This allows the notification to break through scheduled notification summaries. It’s also possible for communication notifications to break through an enabled Focus when the Allowed People list contains the sender. Use the same intent object that initialized the `incoming` interaction. Wait for the interaction donation to complete before updating notification content.
The sample updates notification content in the Notification Service Extension by calling `CommunicationInteractor.update(notificationContent:communicationInformation:completion:)`.
```swift
    /// Update incoming notifications with a message or call information to allow the following:
    /// - Display an avatar, if present.
    /// - Check if sender is allowed to break through.
    /// - Update notification title (sender's name) and subtitle (group information).
    @available(iOS 15.0, watchOS 8.0, macOS 12.0, *)
    static func update(notificationContent: UNNotificationContent,
                       communicationInformation: CommunicationInformation,
                       completion: @escaping (Result<UNNotificationContent, Error>) -> Void) {
        suggest(communicationInformation: communicationInformation) { [notificationContent] result in
            switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let interaction):
                    guard let notificationContentProvider = interaction.intent as? UNNotificationContentProviding else {
                        completion(.failure(CommunicationInteractorError.unexpectedIntentType))
                        return
                    }
                    do {
                        let updatedContent = try notificationContent.updating(from: notificationContentProvider)
                        completion(.success(updatedContent))
                    } catch let error {
                        completion(.failure(error))
                    }
            }
        }
    }
```

#### 
When a user has enabled a Focus, it may be useful to display that status to other users of an app. This informs other users when someone silences their notifications and may not see communications right away.
Accessing the user’s Focus status requires explicit user authorization. To request authorization, use `INFocusStatusCenter.default.requestAuthorization(completionHandler:)` and parse the result. Someone can choose to authorize the app to access their Focus status, deny the app access, or choose neither.
```swift
    /// Requests FocusStatusCenter authorization.
    /// Parameter completion: Result contains AuthorizationStatus or error.
    @available(iOS 15.0, watchOS 8.0, macOS 12.0, *)
    static func requestFocusStatusAuthorization(completion: @escaping (Result<AuthorizationStatus, Error>) -> Void) {
        INFocusStatusCenter.default.requestAuthorization { status in
            switch status {
                case .denied:
                    completion(.success(.denied))
                case .authorized:
                    completion(.success(.authorized))
                case .notDetermined:
                    completion(.success(.notDetermined))
                case .restricted:
                    completion(.success(.restricted))
                @unknown default:
                    completion(.success(.notSupported))
            }
        }
    }
```

Once authorized, an app can request the user’s current Focus status. The perspective of the app is important; the user doesn’t appear focused to an app if an enabled Focus allows notifications from that app.
The sample accesses the current Focus status in the `requestFocusStatus(completion:)` method. Unauthorized apps don’t receive a Focus status value. Ensure the app handles the `nil` Focus status case.
```swift
    /// Requests current focus status.
    /// Requires UserNotifications and FocusStatus to be authorized and Communication Notifications capability enabled for the app's target.
    /// Parameter completion: Result contains FocusStatus isFocused Bool, which will be true if Focus is enabled and this app
    /// isn't in its Allowed Apps list.
    @available(iOS 15.0, watchOS 8.0, macOS 12.0, *)
    static func requestFocusStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let isFocused = INFocusStatusCenter.default.focusStatus.isFocused else {
            completion(.failure(CommunicationInteractorError.focusStatusNotAvailable))
            return
        }
        completion(.success(isFocused))
    }
```

Observe Focus status changes from an Intents app extension. This extension launches in the background to handle interactions between your app and SiriKit. To learn more about Intents app extensions, see . Ensure your Intents app extension target includes support for . The Intents app extension target’s General tab in the project file contains the list of supported intents. Include the class names of all supported intents in the Supported Intents section.
The Intents app extension in the sample handles incoming  objects. When doing so, the sample uses the intent itself to access the `isFocused` bool directly instead of using the default `INFocusStatusCenter`.
```swift
/**
     For this Intent to be handled, the following requirements must be met:
     FocusStatusCenter authorized for parent app (target).
     UserNotifications authorized for parent app (target).
     Communication Notifications capability (entitlement) added to the parent app (target).
     */
    func handle(intent: INShareFocusStatusIntent, completion: @escaping (INShareFocusStatusIntentResponse) -> Void) {
        let response = INShareFocusStatusIntentResponse(code: .success, userActivity: nil)
        if let isFocused = intent.focusStatus?.isFocused {
            // Send isFocused value to servers or AppGroup.
            print("Is user focused: \(isFocused)")
        }
        completion(response)
    }
```


## Handling error responses from Apple Push Notification service
> https://developer.apple.com/documentation/usernotifications/handling-error-responses-from-apns

### 
#### 
| `:status` | The HTTP status code. For a failed response the status code can be `4xx` or `5xx`. |
The table below lists the possible values in the `:status` header of the error response.
| 404 | The request contained an invalid `:path` value. |
| 405 | The request used an invalid `:method` value. |
#### 
| `reason` | The error code (specified as a string) indicating the reason for the failure. The table below lists possible values. |
| `400` | `FeatureNotEnabled` | The feature isn’t enabled for this topic. Refer to  to enable broadcast capabilities. |
| `400` | `MissingChannelId` | The `apns-channel-id` header is missing. |
| `400` | `BadChannelId` | The `apns-channel-id` header isn’t properly encoded, or it’s greater than the allowed length. |
| `400` | `ChannelNotRegistered` | The `apns-channel-id` header used in the request doesn’t exist. |
| `400` | `BadRequestParams` | The JSON Request payload contained an unrecognizable attribute. |
| `400` | `BadRequestPayload` | The JSON Request payload is unparseable. |
| `400` | `PayloadEmpty` | The push notification request didn’t include a notification payload. |
| `400` | `BadMessageId` | The `apns-id` value is invalid. |
| `400` | `MissingPushType` | The `apns-push-type` attribute is missing. |
| `400` | `InvalidPushType` | The `apns-push-type` attribute is set to an incorrect value. The only allowed value is `LiveActivity`. |
| `400` | `CannotCreateChannelConfig` | You have reached the maximum channel limit for your application. Delete channels that you no longer use. |
| `400` | `TopicDisallowed` | The topic is not allowed. Ensure that no push type suffix is added to the bundle ID. |
| `400` | `BadPriority` | The `apns-priority` header is an invalid value. |
| `403` | `BadCertificate` | The certificate is invalid. |
| `403` | `BadCertificateEnvironment` | The client certificate is for the wrong environment. |
| `403` | `TopicMismatch` | The bundle IDs parsed from your token or certificate don’t include the topic present in the path. |
| `403` | `MissingProviderToken` | No certificate or JWT token provided. |
| `403` | `ExpiredProviderToken` | The JWT Token is expired. |
| `403` | `InvalidProviderToken` | The JWT Token is invalid. |
| `404` | `BadPath` | The URL is invalid. Either the `HTTP/2` method or the `HTTP/2` path is incorrect. |
| `405` | `MethodNotAllowed` | The specified `:method` value isn’t allowed. |
| `413` | `PayloadTooLarge` | The message payload is too large. For information about the allowed payload size, refer to . |
| `429` | `TooManyRequests` | The request was throttled because too many requests were received. |
| `500` | `InternalServerError` | An unexpected error occurred. |
| `503 ` | `Service Unavailable` | The service is unavailable |
| `503` | `Shutdown` | The server is shutting down and unavailable. |
| `503` | `Shutdown` | The server is shutting down and unavailable. |
The following code snippet shows a sample response when an error occurs.
```Other
HEADERS
  - END_STREAM
  + END_HEADERS
  :status = 400
  content-type = application/json
  apns-request-id: <a_UUID>
DATA
  + END_STREAM
  { "reason" : "MissingChannelId" }
```


## Handling notification responses from APNs
> https://developer.apple.com/documentation/usernotifications/handling-notification-responses-from-apns

### 
#### 
| `:status` | The HTTP status code. |
The table below lists the possible values in the `:status` header of the response.
| `200` | Success. |
| `400` | Bad request. |
| `403` | There was an error with the certificate or with the provider’s authentication token. |
| `404` | The request contained an invalid `:path` value. |
| `405` | The request used an invalid `:method` value. Only `POST` requests are supported. |
| `410` | The device token is no longer active for the topic. |
| `413` | The notification payload was too large. |
| `429` | The server received too many requests for the same device token. |
| `500` | Internal server error. |
| `503` | The server is shutting down and unavailable. |
#### 
| `400` | `BadCollapseId` | The collapse identifier exceeds the maximum allowed size. |
| `400` | `BadExpirationDate` | The `apns-expiration` value is invalid. |
| `400` | `BadMessageId` | The `apns-id` value is invalid. |
| `400` | `BadPriority` | The `apns-priority` value is invalid. |
| `400` | `BadTopic` | The `apns-topic` value is invalid. |
| `400` | `DeviceTokenNotForTopic` | The device token doesn’t match the specified topic. |
| `400` | `DuplicateHeaders` | One or more headers are repeated. |
| `400` | `IdleTimeout` | Idle timeout. |
| `400` | `InvalidPushType` | The `apns-push-type` value is invalid. |
| `400` | `MissingDeviceToken` | The device token isn’t specified in the request `:path`. Verify that the `:path` header contains the device token. |
| `400` | `PayloadEmpty` | The message payload is empty. |
| `400` | `TopicDisallowed` | Pushing to this topic is not allowed. |
| `403` | `BadCertificate` | The certificate is invalid. |
| `403` | `BadCertificateEnvironment` | The client certificate doesn’t match the environment. |
| `403` | `ExpiredProviderToken` | The provider token is stale and a new token should be generated. |
| `403` | `Forbidden` | The specified action is not allowed. |
| `403` | `InvalidProviderToken` | The provider token is not valid, or the token signature can’t be verified. |
| `403` | `BadEnvironmentKeyIdInToken` | The key ID in the provider token doesn’t match the environment. |
| `404` | `BadPath` | The request contained an invalid `:path` value. |
| `405` | `MethodNotAllowed` | The specified `:method` value isn’t `POST`. |
| `410` | `ExpiredToken` | The device token has expired. |
| `429` | `TooManyRequests` | Too many requests were made consecutively to the same device token. |
| `500` | `InternalServerError` | An internal server error occurred. |
| `503` | `ServiceUnavailable` | The service is unavailable. |
| `503` | `Shutdown` | The APNs server is shutting down. |
The code listing below shows a sample response for a successful push request.
```other
HEADERS
  + END_STREAM
  + END_HEADERS
  apns-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
  :status = 200
```

```
The code listing below shows a sample response when an error occurs.
```other
HEADERS
  - END_STREAM
  + END_HEADERS
  :status = 400
  content-type = application/json
  apns-id: <a_UUID>
DATA
  + END_STREAM
  { "reason" : "BadDeviceToken" }
```


## Handling notifications and notification-related actions
> https://developer.apple.com/documentation/usernotifications/handling-notifications-and-notification-related-actions

### 
#### 
Listing 1 shows an example that processes actions associated with a meeting invitation. The `ACCEPT_ACTION` and `DECLINE_ACTION` strings identify the app-specific actions, which generate an appropriate response to the meeting invitation. If the user doesn’t choose one of the app-defined actions, the method saves the invitation until the user launches the app.
Listing 1. Handling the actions in your actionable notifications
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: 
               @escaping () -> Void) {
   // Get the meeting ID from the original notification.
   let userInfo = response.notification.request.content.userInfo
        
   if response.notification.request.content.categoryIdentifier ==
              "MEETING_INVITATION" {
      // Retrieve the meeting details.
      let meetingID = userInfo["MEETING_ID"] as! String
      let userID = userInfo["USER_ID"] as! String
            
      switch response.actionIdentifier {
      case "ACCEPT_ACTION":
         sharedMeetingManager.acceptMeeting(user: userID, 
               meetingID: meetingID)
         break
                
      case "DECLINE_ACTION":
         sharedMeetingManager.declineMeeting(user: userID, 
               meetingID: meetingID)
         break
                
      case UNNotificationDefaultActionIdentifier,
           UNNotificationDismissActionIdentifier:
         // Queue meeting-related notifications for later
         //  if the user does not act.
         sharedMeetingManager.queueMeetingForDelivery(user: userID,
               meetingID: meetingID)
         break
                
      default:
         break
      }
   }
   else {
      // Handle other notification types...
   }
        
   // Always call the completion handler when done.
   completionHandler()
}
```

#### 
When a notification arrives, the system calls the  method of the  object’s delegate. Use that method to process the notification and let the system know how you want it to proceed. Listing 2 shows a version of this method for a calendar app. When a meeting invitation arrives, the app calls its custom `queueMeetingForDelivery` method to show the new invitation in the app’s interface. The app also asks the system to play the notification’s sound by passing the  value to the completion handler. For other notification types, the method silences the notification.
Listing 2. Processing notifications in the foreground
```swift
func userNotificationCenter(_ center: UNUserNotificationCenter,
         willPresent notification: UNNotification,
         withCompletionHandler completionHandler: 
            @escaping (UNNotificationPresentationOptions) -> Void) {
   if notification.request.content.categoryIdentifier == 
            "MEETING_INVITATION" {
      // Retrieve the meeting details.
      let meetingID = notification.request.content.
                       userInfo["MEETING_ID"] as! String
      let userID = notification.request.content.
                       userInfo["USER_ID"] as! String
            
      // Add the meeting to the queue.
      sharedMeetingManager.queueMeetingForDelivery(user: userID,
            meetingID: meetingID)

      // Play a sound to let the user know about the invitation.
      completionHandler(.sound)
      return
   }
   else {
      // Handle other notification types...
   }

   // Don't alert the user for other types.
   completionHandler(UNNotificationPresentationOptions(rawValue: 0))
}
```


## Implementing communication notifications
> https://developer.apple.com/documentation/usernotifications/implementing-communication-notifications

### 
#### 
#### 
#### 
When the user receives a message, you create an . An  has a single sender and one or more recipients. For incoming communication notification donations, the system includes the current user as a recipient in addition to those your app provides in the `recipients` array. Provide a unique `conversationIdentifier` that represents the conversation. Use the same identifier for each message that the user receives in the same conversation. This is especially important for group conversations where the group name and membership can change for each message.
The example below represents a direct message. There are no recipients other than the current user in this case. The `image` of the sender becomes the avatar for the notification.
```swift
// Initialize only the sender for a one-to-one message intent.
let handle = INPersonHandle(value: "unique-user-id-1", type: .unknown)
let avatar = INImage(named: "profilepicture.png")
let sender = INPerson(personHandle: handle,
                      nameComponents: nil,
                      displayName: "Example",
                      image: avatar,
                      contactIdentifier: nil,
                      customIdentifier: nil)

// Because this communication is incoming, you can infer that the current user is
// a recipient. Don't include the current user when initializing the intent.
let intent = INSendMessageIntent(recipients: nil,
                                 outgoingMessageType: .outgoingMessageText,
                                 content: "Message content",
                                 speakableGroupName: nil,
                                 conversationIdentifier: "unique-conversation-id-1",
                                 serviceName: nil,
                                 sender: sender,
                                 attachments: nil)
```

#### 
When the user receives an incoming call, you create an . An  has an array of one or more contacts that are participants of the call. For incoming communication notification donations, the system includes the current user as a recipient in addition to those added to the `contacts` array. Provide the most accurate additional information available about the call, including a callback record to use in the event of a missed call. The example below represents a call between `caller` and the current user. The caller’s image becomes the avatar for the notification.
```swift
// Initialize only the caller for a one-to-one call intent.
let handle = INPersonHandle(value: "unique-user-id-1", type: .unknown)
let avatar = INImage(named: "profilepicture.png")
let caller = INPerson(personHandle: handle,
                      nameComponents: nil,
                      displayName: "Example",
                      image: avatar,
                      contactIdentifier: nil,
                      customIdentifier: nil)

// Include the other participants of the call in the contacts array.
// Because this communication is incoming, you can infer that the current user is
// a participant of the call. Don't include the user in the contacts array.
let intent = INStartCallIntent(callRecordFilter: nil,
                               callRecordToCallBack: callRecordToCallBack,
                               audioRoute: .bluetoothAudioRoute,
                               destinationType: .normal,
                               contacts: [caller],
                               callCapability: .audioCall)
```

#### 
After you configure a communication intent, donate an interaction for the intent. Initialize an  object from the previously configured message or call intent. Set the interaction’s direction to . This indicates the user is the recipient of an interaction — the incoming communication. Call  on the interaction and handle errors that may occur in its completion handler.
If the donation completes successfully, update the content of a received notification to display a communication notification. Call  on the received notification content. Use the updated notification content to display a communication notification. In the example below, the handling of this process happens in an NSE. Call the `contentHandler` with the updated notification content to display a communication notification before returning from the  method.
```swift
func didReceive(_ request: UNNotificationRequest,
                withContentHandler contentHandler:
                @escaping (UNNotificationContent) -> Void) async {

    // Create an intent as shown in previous code listings.
    // For an incoming message, refer to the first code listing.
    // For an incoming call, refer to the second code listing.
    let intent: INSendMessageIntent = sendMessageIntent()

    // Use the intent to initialize the interaction.
    let interaction = INInteraction(intent: intent, response: nil)

    // Interaction direction is incoming because the user is
    // receiving this message.
    interaction.direction = .incoming

    // Donate the interaction before updating notification content.
    do {
        try await interaction.donate()
    } catch {
        // Handle errors that may occur during donation.
        return
    }
        
    // After donation, update the notification content.
    let content = request.content
    
    do {
        // Update notification content before displaying the
        // communication notification.
        let updatedContent = try content.updating(from: intent)
        
        // Call the content handler with the updated content
        // to display the communication notification.
        contentHandler(updatedContent)
        
    } catch {
        // Handle errors that may occur while updating content.
    }
}
```

#### 
#### 

## Modifying content in newly delivered notifications
> https://developer.apple.com/documentation/usernotifications/modifying-content-in-newly-delivered-notifications

### 
#### 
#### 
Listing 1 shows an implementation of the  object that decrypts the contents of a secret message delivered using a remote notification. The  method decrypts the data and returns a modified version of the notification’s content if it’s successful. If it’s unsuccessful, or if time expires, the extension returns content indicating that the data is still encrypted.
Listing 1. Decrypting data contained in a remote notification
```swift
// Storage for the completion handler and content.
var contentHandler: ((UNNotificationContent) -> Void)?
var bestAttemptContent: UNMutableNotificationContent?
// Modify the payload contents.
override func didReceive(_ request: UNNotificationRequest,
         withContentHandler contentHandler: 
         @escaping (UNNotificationContent) -> Void) {
   self.contentHandler = contentHandler
   self.bestAttemptContent = (request.content.mutableCopy() 
         as? UNMutableNotificationContent)
   
   // Try to decode the encrypted message data.
   let encryptedData = bestAttemptContent?.userInfo["ENCRYPTED_DATA"]
   if let bestAttemptContent = bestAttemptContent {
      if let data = encryptedData as? String {
         let decryptedMessage = self.decrypt(data: data)
        bestAttemptContent.body = decryptedMessage
      }
      else {
         bestAttemptContent.body = "(Encrypted)"
      }
      
      // Always call the completion handler when done.      
      contentHandler(bestAttemptContent)
   }
}
    
// Return something before time expires.
override func serviceExtensionTimeWillExpire() {
   if let contentHandler = contentHandler, 
      let bestAttemptContent = bestAttemptContent {
         
      // Mark the message as still encrypted.   
      bestAttemptContent.subtitle = "(Encrypted)"
      bestAttemptContent.body = ""
      contentHandler(bestAttemptContent)
   }
}
```

#### 
- The payload must include the `mutable-content` key with a value of `1`.
- The payload must include an `alert` dictionary with title, subtitle, or body information.
Listing 2 shows the JSON data for a notification payload containing encrypted data. The `mutable-content` flag is set so that the user’s device knows to run the corresponding service app extension, the code for which is shown in .
Listing 2. Specifying the remote notification payload
```json
{
   "aps" : {
      "category" : "SECRET",
      "mutable-content" : 1,
      "alert" : {
         "title" : "Secret Message!",
         "body"  : "(Encrypted)"
     },
   },
   "ENCRYPTED_DATA" : "Salted__·öîQÊ$UDì_¶Ù∞èΩ^¬%gq∞NÿÒQùw"
}
```


## Pushing background updates to your App
> https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app

### 
#### 
#### 
To send a background notification, create a remote notification with an `aps` dictionary that includes only the `content-available` key, as shown in the sample code below. You may include custom keys in the payload, but the `aps` dictionary must not contain any keys that would trigger user interactions.
```swift
{
   "aps" : {
      "content-available" : 1
   },
   "acme1" : "bar",
   "acme2" : 42
}

```

#### 

## Registering your app with APNs
> https://developer.apple.com/documentation/usernotifications/registering-your-app-with-apns

### 
#### 
#### 
In addition to handling successful registrations with APNs, prepare your app to handle unsuccessful registrations by implementing the  method. Registration might fail if the user’s device isn’t connected to the network, if the APNs server is unreachable for any reason, or if the app doesn’t have the proper code-signing entitlement. When a failure occurs, set a flag and try to register again at a later time.
The code snippet below shows a sample implementation of the iOS app delegate methods needed to register for remote notifications and receive the corresponding token. The `sendDeviceTokenToServer` method is a custom method that the app uses to send the data to its provider server.
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    UIApplication.shared.registerForRemoteNotifications()
    return true
}

func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    self.sendDeviceTokenToServer(data: deviceToken)
}

func application(_ application: UIApplication,
                 didFailToRegisterForRemoteNotificationsWithError
                 error: Error) {
    // Try again later.
}
```

#### 

## Scheduling a notification locally from your app
> https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app

### 
#### 
Fill in the properties of a  object with the details of your notification. The fields you fill in define how the system delivers your notification. For example, to play a sound, assign a value to the  property of the object. Listing 1 shows a content object that displays an alert containing a title string and body text. You can specify multiple types of interaction in the same request.
Listing 1. Configuring the notification content
```swift
let content = UNMutableNotificationContent()
content.title = "Weekly Staff Meeting"
content.body = "Every Tuesday at 2pm"
```

#### 
Listing 2 shows you how to configure a notification for the system to deliver every Tuesday at 2pm. The  structure specifies the timing for the event. Configuring the trigger with the `repeats` parameter set to  causes the system to reschedule the event after its delivery.
Listing 2. Configuring a recurring date-based trigger
```swift
// Configure the recurring date.
var dateComponents = DateComponents()
dateComponents.calendar = Calendar.current

dateComponents.weekday = 3  // Tuesday
dateComponents.hour = 14    // 14:00 hours
   
// Create the trigger as a repeating event.    
let trigger = UNCalendarNotificationTrigger(
         dateMatching: dateComponents, repeats: true)
```

#### 
Create a  object that includes your content and trigger conditions, and call the  ( method to schedule your request with the system. Listing 1 shows an example that uses the content from Listing 1 and Listing 2 to fill in the request object.
Listing 1. Registering the notification request
```swift
let uuidString = UUID().uuidString
let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

// Schedule the request with the system.
let notificationCenter = UNUserNotificationCenter.current()
do {
    try await notificationCenter.add(request)
} catch {
    // Handle errors that may occur during add.
}
```

#### 

## Sending broadcast push notification requests to APNs
> https://developer.apple.com/documentation/usernotifications/sending-broadcast-push-notification-requests-to-apns

### 
#### 
#### 
| `:method` | Required | The value `POST`. |
| `:path` | Required | The value of this header is `/4/broadcasts/apps/<bundle ID>`. |
| `apns-push-type` | Required | The allowed value is `Liveactivity`. |
Put the `JSON` payload with the notification’s content into the body of your request. Don’t use a compressed JSON payload, and the payload is limited to a maximum size of 5 KB (5,120 bytes).
The code snippet below shows a sample request constructed with an authentication token to the development enviroment.
```other
HEADERS
  - END_STREAM
  + END_HEADERS
  :method = POST
  :scheme = https
  :path = 4/broadcasts/apps/com.example.MyApp
  host = api-broadcast.sandbox.push.apple.com
  authorization = bearer eyAia2lkIjogIjhZTDNHM1JSWDciIH0.eyAiaXNzIjogIkM4Nk5WOUpYM0QiLCAiaWF0I
         jogIjE0NTkxNDM1ODA2NTAiIH0.MEYCIQDzqyahmH1rz1s-LFNkylXEa2lZ_aOCX4daxxTZkVEGzwIhALvkClnx5m5eAT6
         Lxw7LZtEQcH6JENhJTMArwLf3sXwi
  apns-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
  apns-push-type = liveactivity
  apns-expiration = 0
  apns-priority = 10
  apns-channel-id = dHN0LXNyY2gtY2hubA==
DATA
  + END_STREAM
  {
    "aps": {
        "timestamp": 1685952000,
        "event": "update",
        "content-state": {
            "currentHealthLevel": 0.0,
            "eventDescription": "Power Panda has been knocked down!"
        },
        "alert": {
            "title": {
                "loc-key": "%@ is knocked down!",
                "loc-args": ["Power Panda"]
            },
            "body": {
                "loc-key": "Use a potion to heal %@!",
                "loc-args": ["Power Panda"]
            },
            "sound": "HeroDown.mp4"
        }
    }
}
```

```
The code snippet below shows a sample request constructed for use with a certificate.
```other
HEADERS
  - END_STREAM
  + END_HEADERS
  :method = POST
  :scheme = https
  :path = 4/broadcasts/apps/com.example.MyApp
  host = api-broadcast.sandbox.push.apple.com
  apns-request-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
  apns-push-type = liveactivity
  apns-expiration = 0
  apns-priority = 10
  apns-channel-id = dHN0LXNyY2gtY2hubA==
DATA
  + END_STREAM
  {
    "aps": {
        "timestamp": 1685952000,
        "event": "update",
        "content-state": {
            "currentHealthLevel": 0.0,
            "eventDescription": "Power Panda has been knocked down!"
        },
        "alert": {
            "title": {
                "loc-key": "%@ is knocked down!",
                "loc-args": ["Power Panda"]
            },
            "body": {
                "loc-key": "Use a potion to heal %@!",
                "loc-args": ["Power Panda"]
            },
            "sound": "HeroDown.mp4"
        }
    }
}
```

| `:status` | 200 A HTTP success status code |
| `apns-request-id` | The request identifier specified in the corresponding request. If not specified, the server generates the request identifier. |

## Sending channel management requests to APNs
> https://developer.apple.com/documentation/usernotifications/sending-channel-management-requests-to-apns

### 
#### 
#### 
| `:method` | Required | The value `POST`. |
| `:path` | Required | `/1/apps/<bundleId>/channels` |
| `push-type` | Required | The push type configured for the channel. Allowed value is `LiveActivity`. |
| `push-type` | Required | The push type configured for the channel. Allowed value is `LiveActivity`. |
The code snippet below shows a sample to request a channel using a JWT.
```other
curl -v -X POST \
-H "authorization: bearer <token>" \
-H "apns-request-id: 2288cf3f-70d8-46a6-97d7-dd5d00867127" \
-d '{"message-storage-policy": 1, "push-type": "LiveActivity"}' \
--http2 \
https://api-manage-broadcast.sandbox.push.apple.com:2195/1/apps/com.example.MyApp/channels 

HEADERS
  - END_STREAM
  + END_HEADERS
  :method = POST
  :scheme = https
  :path = /1/apps/com.example.MyApp/channels
  host = api-manage-broadcast.sandbox.push.apple.com
  authorization = bearer <token>
  apns-request-id = 2288cf3f-70d8-46a6-97d7-dd5d00867127
DATA
  + END_STREAM
  { "message-storage-policy": 1, "push-type": "LiveActivity" }
```

| `:status` | The HTTP status code for a successul request is 201. For a failed request and a list of all possible status codes, refer to . |
| `apns-request-id` | The request identifier specified in the corresponding request. If not specified, the server generates the identifier. |
| `apns-channel-id` | A base64-encoded string that identifies the newly created channel. |
#### 
| `:method` | Required | The value `GET`. |
| `:path` | Required | `/1/apps/<bundleId>/channels` |
| `apns-channel-id` | Required | A base64-encoded string that identifies the channel. Your server receives the channel ID as part of the channel creation response. |
The code snippet below shows a sample request constructed for reading the configuration for a channel using a JWT.
```other
curl -v -X GET \
-H "authorization: bearer <token>" \
-H "apns-request-id: 2288cf3f-70d8-46a6-97d7-dd5d00867127" \
-H "apns-channel-id: dHN0LXNyY2gtY2hubA==" \ 
--http2 \
https://api-manage-broadcast.sandbox.push.apple.com:2195/1/apps/com.example.MyApp/channels 

HEADERS
  - END_STREAM
  + END_HEADERS
  :method = GET
  :scheme = https
  :path = /1/apps/com.example.MyApp/channels
  host = api-manage-broadcast.sandbox.push.apple.com
  authorization = bearer <token>
  apns-request-id = 2288cf3f-70d8-46a6-97d7-dd5d00867127
  apns-channel-id = dHN0LXNyY2gtY2hubA==
DATA
  + END_STREAM
```

| `:status` | The HTTP status code for a successul request is 200. For a failed request and a list of all possible status codes, refer to . |
| `push-type` | The push type configured for the channel. Allowed value is `LiveActivity`. |
#### 
| `:method` | Required | The value `DELETE`. |
| `:path` | Required | `/1/apps/<bundleId>/channels` |
| `apns-channel-id` | Required | The base64 bytes that identify the channel. Your server receives the channel ID as part of the channel creation response. |
The code snippet below shows a sample request constructed for deleting a channel JWT.
```other
curl -v -X DELETE \
-H "authorization: bearer <token>" \
-H "apns-request-id: 2288cf3f-70d8-46a6-97d7-dd5d00867127" \
-H "apns-channel-id: dHN0LXNyY2gtY2hubA==" \ 
--http2 \
https://api-manage-broadcast.sandbox.push.apple.com:2195/1/apps/com.example.MyApp/channels

HEADERS
  - END_STREAM
  + END_HEADERS
  :method = DELETE
  :scheme = https
  :path = /1/apps/com.example.MyApp/channels
  host = api-manage-broadcast.sandbox.push.apple.com
  authorization = bearer <token>
  apns-request-id = 2288cf3f-70d8-46a6-97d7-dd5d00867127
  apns-channel-id = dHN0LXNyY2gtY2hubA==
DATA
  + END_STREAM
```

| `:status` | The HTTP status code for a successul request is 204. For a failed request and a list of all possible status codes, refer to . |
#### 
| `:method` | Required | The value `GET`. |
| `:path` | Required | `/1/apps/<bundleId>/all-channels` |
| `apns-request-id` | Optional | A canonical UUID that’s the unique ID for this request. If an error occurs when processing the request, APNs includes this value when reporting the error to your server. Canonical UUIDs are 32 lowercase hexadecimal digits, displayed in five groups separated by hyphens in the form `8-4-4-4-12`; For example: `123e4567-e89b-12d3-a456-4266554400a0`. If you omit this header, APNs creates a `UUID` for you and returns it in its response. |
The code snippet below shows a sample request constructed for listing all the channels belonging to a bundle ID.
```other
curl -v -X GET \
-H "authorization: bearer <token>" \
-H "apns-request-id: 2288cf3f-70d8-46a6-97d7-dd5d00867127" \
--http2 \
https://api-manage-broadcast.sandbox.push.apple.com:2195/1/apps/com.example.MyApp/all-channels 

HEADERS
  - END_STREAM
  + END_HEADERS
  :method = GET
  :scheme = https
  :path = /1/apps/com.example.MyApp/all-channels
  host = api-manage-broadcast.sandbox.push.apple.com
  authorization = bearer <token>
  apns-request-id = 2288cf3f-70d8-46a6-97d7-dd5d00867127
DATA
  + END_STREAM
```

| `:status` | The HTTP status code for a successul request is 200. For a failed request and a list of all possible status codes, refer to . |
| `channels` | List of all the base64-encoded channel identifiers for the topic. |

## Sending notification requests to APNs
> https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns

### 
#### 
#### 
#### 
| `:method` | Required | The value `POST`. |
- Encode the `:path` and `authorization` values as .
- Encode the `apns-id`, `apns-expiration`, and `apns-collapse-id` values differently based on whether this is an initial or subsequent request.
Put the JSON payload with the notification’s content into the body of your request. You must not use a compressed JSON payload, and it’s limited to a maximum size of 4 KB (4096 bytes). The maxiumum size for a Voice over Internet Protocol (VoIP) notification is 5 KB (5120 bytes).
The code snippet below shows a sample request constructed with an authentication token.
```other
HEADERS
  - END_STREAM
  + END_HEADERS
  :method = POST
  :scheme = https
  :path = /3/device/00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0
  host = api.sandbox.push.apple.com
  authorization = bearer eyAia2lkIjogIjhZTDNHM1JSWDciIH0.eyAiaXNzIjogIkM4Nk5WOUpYM0QiLCAiaWF0I
         jogIjE0NTkxNDM1ODA2NTAiIH0.MEYCIQDzqyahmH1rz1s-LFNkylXEa2lZ_aOCX4daxxTZkVEGzwIhALvkClnx5m5eAT6
         Lxw7LZtEQcH6JENhJTMArwLf3sXwi
  apns-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
  apns-push-type = alert
  apns-expiration = 0
  apns-priority = 10
  apns-topic = com.example.MyApp
DATA
  + END_STREAM
  { "aps" : { "alert" : "Hello" } }

```

```
The code snippet below shows a sample request constructed for use with a certificate. APNs uses the app’s bundle ID as the default topic.
```other
HEADERS
  - END_STREAM
  + END_HEADERS
  :method = POST
  :scheme = https
  :path = /3/device/00fc13adff785122b4ad28809a3420982341241421348097878e577c991de8f0
  host = api.sandbox.push.apple.com
  apns-id = eabeae54-14a8-11e5-b60b-1697f925ec7b
  apns-push-type = alert
  apns-expiration = 0
  apns-priority = 10
DATA
  + END_STREAM
  { "aps" : { "alert" : "Hello" } }

```

#### 
#### 

## Sending push notifications using command-line tools
> https://developer.apple.com/documentation/usernotifications/sending-push-notifications-using-command-line-tools

### 
#### 
- Your App ID. To learn more about App IDs, refer to .
Start by launching the Terminal app in the most recent macOS version. Then set these shell variables:
```bash
CERTIFICATE_FILE_NAME=path to the certificate file
CERTIFICATE_KEY_FILE_NAME=path to the private key file
TOPIC=App ID
```

#### 
- The device token from your app, as a hexadecimal-encoded ASCII string. To learn more about device tokens, refer to .
In the Terminal app in the most recent macOS version, set these additional shell variables:
```bash
DEVICE_TOKEN=device token for your app
APNS_HOST_NAME=api.sandbox.push.apple.com
```

```
Test that you can use your certificate to connect to APNs using this command:
```shell
% openssl s_client 
-connect "${APNS_HOST_NAME}":443 
-cert "${CERTIFICATE_FILE_NAME}" 
-certform DER -key "${CERTIFICATE_KEY_FILE_NAME}" 
-keyform PEM
```

```
Then send a push notification using this command:
```shell
% curl -v 
  --header "apns-topic: ${TOPIC}" 
  --header "apns-push-type: alert" 
  --cert "${CERTIFICATE_FILE_NAME}" 
  --cert-type DER --key "${CERTIFICATE_KEY_FILE_NAME}" 
  --key-type PEM --data '{"aps":{"alert":"test"}}' 
  --http2  https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}
```

#### 
- Ensure the Live Activity is active on the device.
In the Terminal app in the most recent macOS version, set these additional shell variables:
```bash
CHANNEL_ID=channel ID for your application
APNS_HOST_NAME=api.sandbox.push.apple.com 
```

```
Test that you can use your certificate to connect to APNs using this command:
```shell
% openssl s_client 
   -connect "${APNS_HOST_NAME}":443 
   -cert "${CERTIFICATE_FILE_NAME}" 
   -certform DER 
   -key "${CERTIFICATE_KEY_FILE_NAME}" 
   -keyform PEM
```

```
Then send a push notification using this command:
```shell
% curl -v 
  --header "apns-channel-id: ${CHANNEL_ID}" 
  --header "apns-push-type: Liveactivity"
  --header "apns-priority: 10" 
  --cert "${CERTIFICATE_FILE_NAME}" 
  --cert-type DER 
  --key "${CERTIFICATE_KEY_FILE_NAME}" 
  --key-type PEM --data '{"aps":{"alert":"test"}}' 
  --http2  https://${APNS_HOST_NAME}/4/broadcasts/apps/${TOPIC}
```

#### 
- Your App ID. To learn more about App IDs, refer to .
Start by launching the Terminal app in the most recent macOS version. Then set these shell variables:
```bash
TEAM_ID=Team ID
TOKEN_KEY_FILE_NAME=path to the private key file
AUTH_KEY_ID=your key identifier
TOPIC=App ID
```

#### 
- The device token from your app, as a hexadecimal-encoded ASCII string. To learn more about device tokens, refer to .
In the Terminal app, set these additional shell variables:
```bash
DEVICE_TOKEN=device token for your app
APNS_HOST_NAME=api.sandbox.push.apple.com
```

```
Test that you can connect to APNs using this command:
```shell
% openssl s_client -connect "${APNS_HOST_NAME}":443
```

```
Set these additional shell variables just before sending a push notification:
```shell
JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"
```

```
Send the push notification using this command:
```shell
% curl -v 
   --header "apns-topic: $TOPIC" 
   --header "apns-push-type: alert" 
   --header "authorization: bearer $AUTHENTICATION_TOKEN" 
   --data '{"aps":{"alert":"test"}}' 
   --http2 https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}
```

#### 
- Ensure the Live Activity is active on the device.
In the Terminal app in the most recent macOS version, set these additional shell variables:
```bash
CHANNEL_ID=channel ID for your application
APNS_HOST_NAME=api.sandbox.push.apple.com
```

```
Test that you can use your certificate to connect to APNs using this command:
```shell
% openssl s_client -connect "${APNS_HOST_NAME}":443 
```

```
Set these additional shell variables just before sending a push notification:
```shell
JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"
```

```
Then send a push notification using this command:
```shell
% curl -v 
   --header "authorization: bearer $AUTHENTICATION_TOKEN" 
   --header "apns-channel-id: ${CHANNEL_ID}" 
   --header "apns-push-type: Liveactivity"
   --header "apns-priority: 10" 
   --data '{"aps":{"alert":"test"}}' 
   --http2  https://${APNS_HOST_NAME}/4/broadcasts/apps/${TOPIC}
```


## Troubleshooting push notifications
> https://developer.apple.com/documentation/usernotifications/troubleshooting-push-notifications

### 
Depending on whether you are troubleshooting issues with device or broadcast notifications, there are different areas you can verify to fix your connection with APNs.
You can verify the TLS handshake between your provider server and APNs by running the OpenSSL `s_client` command from your server, as in code snippet below.. This command can also show if your TLS/SSL certificates have expired or been revoked.
```other
$ openssl s_client -connect api-broadcast.push.apple.com:443 -cert YourSSLCertAndPrivateKey.pem -debug 
-showcerts -CAfile server-ca-cert.pem
```

#### 
#### 

