# Apple CONTACTS Skill


## Accessing the contact store
> https://developer.apple.com/documentation/contacts/accessing-the-contact-store

### 
#### 
#### 
The authorization status of your app is  until the person authorizes or denies access. The person can approve or deny your app’s request for authorization, then change the authorization status later in the Settings app.
To determine your authorization status, call the  class method of  with an entity type :
```swift
let status = CNContactStore.authorizationStatus(for: .contacts)

switch status {
case .notDetermined:
// The person hasn't yet decided whether the app may access contact data.
case .restricted:
// The app isn't authorized and the person can't authorize the app due to restrictions.
case .denied:
// The person explicitly denies access to contact data.
case .authorized: 
// The person authorizes access to all contact data.
case .limited: 
// The person authorizes access to some contact data. 
}
```

#### 
If the authorization status of your app is , prompt the person for access by initializing the contact store, then calling its  or `requestAccess(for:)` method with an entity type `contacts`:
```swift
// Initialize the contact store. 
var store = CNContactStore()

// Request access to contacts.
do {
    let response = try await store.requestAccess(for: .contacts)
} catch {
    // Handle the error.
}
```

#### 
Your app can use the entire Contacts API when it has limited contact access. Use  to let people choose contacts to share with your app. When someone searches for a contact, the search results present contacts that your app doesn’t have access to. If the person taps the button, the system immediately grants access to the contact without prompting them for authorization, and your app receives a callback that includes the identifier of the newly added contact. To fetch information about this contact, create a fetch request that uses , pass the identifier to the predicate, and execute the request:
```swift
@State private var searchQuery = ""

var body: some View {
    ContactAccessButton(queryString: searchQuery) { identifiers in
        // Fetch contacts whose identifiers match newly added contacts.
        fetchContacts(withIdentifiers: identifiers)
    }
}
```

For more information, see .
If your app needs to read or modify contacts, consider presenting the contact access picker to let people update which contacts you can access. The picker has full access to all contacts on the device regardless of your app’s authorization status. When the person dismisses the picker, your app receives a callback that returns the identifiers of additional contacts the person chose. The callback doesn’t provide any information about contacts you can no longer access or those you can already access. The following example creates a fetch request that searches for all approved contacts, executes the request, and then uses the identifiers to highlight newly added contacts in the fetch result in your UI:
```swift
// Indicates whether to present the contact access picker.
@State private var isPresented = false

var body: some View {
    // Tap the add button to present the picker.
    addButton
        .contactAccessPicker(isPresented: $isPresented) { identifiers in
            // Fetch all contacts your app can access.
            let contacts = fetchContacts()

            // Highlight contacts whose identifiers match newly selected contacts.
            highlightContacts(withIdentifiers: identifiers, in: contacts)
        }
}

// An add button.
private var addButton: some View {
    Button {
        isPresented.toggle()
    } label: {
        Label("Add contacts", systemImage: "person.fill.badge.plus")
    }
}

```

#### 

