# Apple NETWORK Skill


## Creating an Identity for Local Network TLS
> https://developer.apple.com/documentation/network/creating-an-identity-for-local-network-tls

### 
#### 
#### 
On iOS, the certificate authority owner is faced with the challenge of distributing the identity to the server. After transferring the identity on the server — either through thumb drive or through secure network transfer — save it to the Keychain. To save the identity in the iOS Keychain, use the following:
```swift
let password = <# A password from the Keychain #>
let options = [kSecImportExportPassphrase: password ] as NSDictionary
var rawItems: CFArray?
let status = SecPKCS12Import(data as CFData, // Data from imported Identity.
                             options as CFDictionary,
                             &rawItems)

guard status == errSecSuccess,
      let items = rawItems,
      let dictionaryItems = items as? Array<Dictionary<String, Any>> else {
    // handle error …
}

let secIdentity: SecIdentity = dictionaryItems[0][kSecImportItemIdentity as String] as! SecIdentity

// Notice that kSecClass as String: kSecClassIdentity isn't used here as this is inferred from kSecValueRef.
let identityAddition = [
    kSecValueRef: secIdentity,
    kSecAttrLabel: "ListenerIdentityLabel"
] as NSDictionary

let identityStatus = SecItemAdd(identityAddition as CFDictionary, nil)

guard identityStatus == errSecSuccess else {
    // handle error …
}
// Added identity successfully.
```

```
To retrieve the identity from the iOS Keychain, use the following:
```swift
func getSecIdentity() -> SecIdentity? {

    // On the query, use kSecClassIdentity to make sure a SecIdentity is extracted.
    let identityQuery = [
        kSecClass: kSecClassIdentity,
        kSecReturnRef: true,
        kSecAttrLabel: "ListenerIdentityLabel"
    ] as NSDictionary
    var identityItem: CFTypeRef?
    let getIdentityStatus = SecItemCopyMatching(identityQuery as CFDictionary, &identityItem)

    guard getIdentityStatus == errSecSuccess else {
        // handle error …
    }
    let secIdentity = identityItem as! SecIdentity
    return secIdentity
}
```

```
With the local identity accessible from the Keychain, set it to  to serve connections using TLS 1.2+ with the following:
```swift
let tlsOptions = NWProtocolTLS.Options()
let tlsParams = NWParameters(tls: tlsOptions, tcp: .init())

if let secIdentity = getSecIdentity(),
   let identity = sec_identity_create(secIdentity) {
    sec_protocol_options_set_min_tls_protocol_version(
        tlsOptions.securityProtocolOptions, .TLSv12)
    sec_protocol_options_set_local_identity(
        tlsOptions.securityProtocolOptions, identity)
} 
let listener = try NWListener(using: tlsParams, on: 4433)
```

```
On macOS, the code is largely the same except if the `NWListener` is running on the same machine that set up the local certificate authority then the app’s code can reference the identity by loading a reference from the  in the Keychain. To retrieve the identity from the Keychain on macOS, use the following:
```swift
func getSecIdentity() -> SecIdentity? {

    var identity: SecIdentity?
    let getquery = [kSecClass: kSecClassCertificate,
        kSecAttrLabel: "certificate_name_in_keychain",
        kSecReturnRef: true] as NSDictionary

    var item: CFTypeRef?
    let status = SecItemCopyMatching(getquery as CFDictionary, &item)
    guard status == errSecSuccess else {
        // handle error …
    }
    let certificate = item as! SecCertificate

    let identityStatus = SecIdentityCreateWithCertificate(nil, certificate, &identity)
    guard identityStatus == errSecSuccess else {
        // handle error …
    }
    return identity
}
```

After loading the identity on macOS, you can use the exact same `NWListener` code on iOS.
#### 
For clients that connect to the server, install the root certificate on the client device to avoid overriding trust evaluation. After installing the root certificate on the client device, the client connects to the server using a local network name. When connecting from the client side of the connection, use the following:
```swift
let tlsOptions = NWProtocolTLS.Options()
sec_protocol_options_set_min_tls_protocol_version(
    tlsOptions.securityProtocolOptions, 
    .TLSv12)

let tlsParams = NWParameters(tls: tlsOptions, tcp: .init())

let endpoint = NWEndpoint.hostPort(host: "listener-name.local", port: 4433)
let connection = NWConnection(to: endpoint, using: tlsParams)
```

If your client needs to connect over IP, instead of using a local network name, the server needs to use a leaf certificate that lists the IP in the “IP Address” field of the Subject Alternative Name. This also avoids having to override trust evaluation on the client and allows client connections to use the following:
```swift
let tlsOptions = NWProtocolTLS.Options()
sec_protocol_options_set_min_tls_protocol_version(
    tlsOptions.securityProtocolOptions, 
    .TLSv12)

let tlsParams = NWParameters(tls: tlsOptions, tcp: .init())

let endpoint = NWEndpoint.hostPort(host: "x.x.x.x", port: 4433)
let connection = NWConnection(to: endpoint, using: tlsParams)
```

```
Attempting to connect from a client to a server without the root certificate installed on the client iOS device results in application errors similar to the following:
```None
// [BoringSSL] boringssl_context_error_print(1863) boringssl ctx 0x2813acbe0: 4348594328:error:1000007d:SSL routines:OPENSSL_internal:CERTIFICATE_VERIFY_FAILED
// [BoringSSL] boringssl_session_handshake_incomplete(164) [C1:1][0x1032186d0] SSL library error
```

To work around this on the client, use `sec_protocol_options_set_verify_block` to perform your own verification checks on the peer’s leaf certificate. This isn’t the recommended path, but could be done in extreme cases. In the following example,  checks against the certificate’s basic x509 policy:
```swift
sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { (_, trust, completionHandler) in
    let secTrustRef = sec_trust_copy_ref(trust).takeRetainedValue() as SecTrust

    // Cannot do hostname here because of IP.
    let x509Policy = SecPolicyCreateBasicX509()
    SecTrustSetPolicies(secTrustRef, x509Policy)

    var error: CFError?
    if !SecTrustEvaluateWithError(secTrustRef, &error) {
        completionHandler(false)
    }
    // Perfom other certificate-based checks.  

    completionHandler(true)
}, .main)
```


## Debugging HTTP Server-Side Errors
> https://developer.apple.com/documentation/network/debugging-http-server-side-errors

### 
#### 
In some cases, the error response from the server includes an HTTP response body that explains what the problem is. Look at the HTTP response body to see whether such an explanation is present. If it is, that’s the easiest way to figure out what went wrong. For example, consider this standard  request code.
```swift
URLSession.shared.dataTask(with: url) { (responseBody, response, error) in
    if let error = error {
        // Handle transport error.
    }
    let response = response as! HTTPURLResponse
    let responseBody = responseBody!
    if !(200...299).contains(response.statusCode) {
        // Handle HTTP server-side error.
    }
    // Handle success.
    print("success")
}.resume()
```

```
A server-side error runs the line labeled “Handle HTTP server-side error.” To see if the server’s response contains any helpful hints as to what went wrong, add some code that prints the HTTP response body.
```swift
        // Handle HTTP server-side error.
        if let responseString = String(bytes: responseBody, encoding: .utf8) {
            // The response body seems to be a valid UTF-8 string, so print that.
            print(responseString)
        } else {
            // Otherwise print a hex dump of the body.
            print(responseBody as NSData)
        }
```

#### 
- A command-line tool, like `curl`
#### 

## Debugging HTTPS Problems with CFNetwork Diagnostic Logging
> https://developer.apple.com/documentation/network/debugging-https-problems-with-cfnetwork-diagnostic-logging

### 
#### 
#### 
#### 
To investigate problems outside of Xcode, programmatically enable CFNetwork diagnostic logging by setting the environment variable directly.
```objc
setenv("CFNETWORK_DIAGNOSTICS", "3", 1);
```

- If you’re programming in Objective-C, put the code at the start of your `main` function.
- If you’re programming in Swift, put this code in `main.swift`.
> **note:**  By default, Swift apps don’t have a `main.swift`;  explains how to add one.
#### 

## Implementing netcat with Network Framework
> https://developer.apple.com/documentation/network/implementing-netcat-with-network-framework

### 
The `netcat` tool (abbreviated `nc` on macOS) is a UNIX tool that lets you:
- Transfer data between a network connection and `stdin` and `stdout`.
This sample code shows how you can build `nwcat`, which provides this functionality and also adds TLS and Bonjour support.
This sample code shows how you can build `nwcat`, which provides this functionality and also adds TLS and Bonjour support.
The `nwcat` tool supports two modes: one that makes an outbound connection and one that listens for an inbound connection.  You select the mode using command-line arguments.  To make an outbound connection to port 80 on `example.com`, you run:
```shell
$ nwcat example.com 80
```

To listen for an inbound connection, you supply the `-l` option and the port number to listen on:
```
To listen for an inbound connection, you supply the `-l` option and the port number to listen on:
```shell
$ nwcat -l 12345
```

#### 
- Any constraints on the connection, like whether or not to use the cellular interface.
To create a parameters object, call either the  or the  convenience function, depending on whether you want to use TCP or UDP.
```objc
nw_parameters_configure_protocol_block_t configure_tls = NW_PARAMETERS_DISABLE_PROTOCOL;
if (g_use_udp) {
    parameters = nw_parameters_create_secure_udp(
        configure_tls,
        NW_PARAMETERS_DEFAULT_CONFIGURATION
    );
} else {
    parameters = nw_parameters_create_secure_tcp(
        configure_tls,
        NW_PARAMETERS_DEFAULT_CONFIGURATION
    );
}
```

- The first configures the security protocol for the connection.  Pass `NW_PARAMETERS_DISABLE_PROTOCOL` to use no security.
- The second configures the transport protocol for the connection.  Pass `NW_PARAMETERS_DEFAULT_CONFIGURATION` to get a default configuration.
 An endpoint, of type , holds a network host or service name.  For an outbound connection, the endpoint determines the remote host to which you want to connect.  In most cases this consists of a host name and a port number, but there are other options.  For example, you can also create endpoints that target a Bonjour service.
In the `nwcat` tool, the user supplies a host name and a port number via command-line arguments, and you will need to create an endpoint from those two strings.  You do this by calling .
```objc
nw_endpoint_t endpoint = nw_endpoint_create_host(name, port);
```

- The port can be a numeric value, like `"80"`, or a service name, like `"https"`.
  Once you have your parameters object and endpoint, you can create a connection object by calling .
```objc
nw_connection_t connection = nw_connection_create(endpoint, parameters);
```

3. Start the connection by calling .
You must set your queue before starting the connection, and you cannot change the queue after that.
```objc
void
start_connection(nw_connection_t connection)
{
    nw_connection_set_queue(connection, dispatch_get_main_queue());
    nw_retain(connection);
    nw_connection_set_state_changed_handler(connection, ^(nw_connection_state_t state, nw_error_t error) {
        … your state changed handler …
    });
    nw_connection_start(connection);
}
```

A state changed handler is a block that’s called by the connection object whenever the connection state changes.  For a simple application, like `nwcat`, you can use a very simple state changed handler.
```objc
if (state == nw_connection_state_waiting) {
    … tell the user that a connection couldn’t be opened but will retry when conditions are favourable …
} else if (state == nw_connection_state_failed) {
    … tell the user that the connection has failed irrecoverably …
} else if (state == nw_connection_state_ready) {
    … tell the user that you are connected …
} else if (state == nw_connection_state_cancelled) {
    nw_release(connection);
}
```

#### 
 A listener object must know what local endpoint to listen on, that is, the endpoint to which clients must connect.  The local endpoint can include a port number and an interface address, both of which are optional.  If you don’t specify a port number, the system chooses a port for you.  If you don’t specify an interface address, the system listens on all interfaces and addresses.
Most applications don’t need to listen on a specific interface address and thus can create a listener using the  convenience function.  However, `nwcat` allows the user to specify an interface address (via a command line argument) and thus you have to use a slightly more complex technique.  If the user has specified an interface address or a port, you can call  to create an endpoint representing the address to listen on, and then call  to apply that to your parameters object.
```objc
if (address || port) {
    nw_endpoint_t local_endpoint = nw_endpoint_create_host(address ? address : "::", port ? port : "0");
    nw_parameters_set_local_endpoint(parameters, local_endpoint);
    nw_release(local_endpoint);
}
```

- The `port` parameter can either be a numeric string, like `"443"`, or a service name, like `"https"`.
- If you pass `"0"` to the `port` parameter the system will choose a port on your behalf.
- If you pass `"0"` to the `port` parameter the system will choose a port on your behalf.
 Once you’ve set up your parameters object, you can create a listener object by calling .
```objc
nw_listener_t listener = nw_listener_create(parameters);
```

```
 Starting a listener object is much like starting a connection object, with one significant difference: in addition to setting a state changed handler, you must also set a new connection handler, which is called whenever the listener object receives a new inbound connection.
```objc
nw_listener_set_queue(listener, dispatch_get_main_queue());
nw_retain(listener);
nw_listener_set_state_changed_handler(listener, ^(nw_listener_state_t state, nw_error_t error) {
    … your state changed handler …
});
nw_listener_set_new_connection_handler(listener, ^(nw_connection_t connection) {
    … your new connection handler …
});
nw_listener_start(listener);
```

```
 Your new connection handler is responsible for either starting the network connection or rejecting it.  The `nwcat` command can only handle one connection at a time, so if there’s already a network connection in place, call  to reject the new connection.  If not, retain the network connection and then run the connection using the same `start_connection` function you used in the outbound case.
```objc
if (g_inbound_connection != NULL) {
    nw_connection_cancel(connection);
} else {
    g_inbound_connection = connection;
    nw_retain(g_inbound_connection);

    start_connection(g_inbound_connection);
}
```

#### 
- Inbound data is received from the network connection and written to `stdout`.
- Outbound data is read from `stdin` and sent to the network connection.
You use a similar strategy for both inbound and outbound data, but there are some subtle differences, discussed in the sections that follow.
 You can receive data with code like this.
```objc
void
receive_loop(nw_connection_t connection)
{
    nw_connection_receive(connection, 1, UINT32_MAX, ^(dispatch_data_t content, nw_content_context_t context, bool is_complete, nw_error_t receive_error) {

        nw_retain(context);
        dispatch_block_t schedule_next_receive = ^{
            … discussed below …
            nw_release(context);
        };

        if (content != NULL) {
            schedule_next_receive = Block_copy(schedule_next_receive);
            dispatch_write(STDOUT_FILENO, content, dispatch_get_main_queue(), ^(__unused dispatch_data_t _Nullable data, int stdout_error) {
                if (stdout_error != 0) {
                    … error logging …
                } else {
                    schedule_next_receive();
                }
                Block_release(schedule_next_receive);
            });
        } else {
            // No content, so directly schedule the next receive
            schedule_next_receive();
        }
    });
}
```

- A  which, if not `NULL`, contains the data received.
- An `is_complete` parameter that is true if the data received is the last part of a logical unit of data.
- A `receive_error` parameter, which is not `NULL` if an error occurred during the receive process.
1. It processes any data that was received by starting an asynchronous write to `stdout`.
2. When that asynchronous write completes—or immediately if there was no content—it calls `schedule_next_receive` to continue the receive.
In `schedule_next_receive` you must handle three cases:
- Otherwise, start the next asynchronous receive by calling `receive_loop`.
- If the receive failed with an error, handle that error.
- Otherwise, start the next asynchronous receive by calling `receive_loop`.
```objc
nw_retain(context);
dispatch_block_t schedule_next_receive = ^{
    if (is_complete &&
        (context == NULL || nw_content_context_get_is_final(context))) {
        exit(0);
    }
    if (receive_error == NULL) {
        receive_loop(connection);
    } else {
        … error logging …
    }
    nw_release(context);
};
```

- If you only handle TCP, you can simply test the `is_complete` flag.
- If you only handle TCP, you can simply test the `is_complete` flag.
 Your send code should have the same basic structure as your receive code.
```objc
void
send_loop(nw_connection_t connection)
{
    dispatch_read(STDIN_FILENO, 8192, dispatch_get_main_queue(), ^(dispatch_data_t _Nonnull read_data, int stdin_error) {
        if (stdin_error != 0) {
            … error logging …
        } else if (read_data == NULL) {
            … handle end of file …
        } else {
            nw_connection_send(connection, read_data, NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT, true, ^(nw_error_t  _Nullable error) {
                if (error != NULL) {
                    … error logging …
                } else {
                    send_loop(connection);
                }
            });
        }
    });
}
```

- Finally, when you receive an end of file from `stdin`, you must close the send side of your connection.  The code for this is shown below.
- You must tell the network connection to send the data as a single message by calling  with `NW_CONNECTION_DEFAULT_MESSAGE_CONTEXT` and passing true to the `is_complete` parameter.  This approach is appropriate for both TCP and UDP connections.  For TCP connections, message boundaries don’t affect how the protocol sends data, but the boundaries are required for sending UDP datagrams.
- Finally, when you receive an end of file from `stdin`, you must close the send side of your connection.  The code for this is shown below.
```objc
nw_connection_send(connection, NULL, NW_CONNECTION_FINAL_MESSAGE_CONTEXT, true, ^(nw_error_t  _Nullable error) {
    if (error != NULL) {
        … handle error …
    }
    // Stop reading from stdin, so don't schedule another send_loop
});
```


## Indicating the source of network activity
> https://developer.apple.com/documentation/network/indicating-the-source-of-network-activity

### 
#### 
#### 
To mark a connection as user-initiated when using the , create an explicit  and set its  property to  before calling one of the  methods that takes a request, like :
```swift
import Foundation

let url = URL(string: "https://example.com")!
var request = URLRequest(url: url)
request.attribution = .user

let (data, response) = try await URLSession.shared.data(for: request)
```

#### 
A  network access that you initiate with a URL request using the  method honors the attribution parameter that you set on the  instance, just like the previous section describes for a  access. If you want to set an attribution when you use WebKit to load an HTML string, data, or a file URL, use one of the corresponding load methods that takes a request. For example, you can load an HTML string with attribution using the  method, relying on the `request` defined in the previous section:
```swift
import WebKit

let webView = WKWebView()
let html = "<html><body><h1>Hello, world!</h1></body></html>"

webView.loadSimulatedRequest(request, responseHTML: html)
```

```
Alternatively, you can load a data version of the same content using the  method:
```swift
let data = Data(html.utf8)
let response = URLResponse(
    url: url,
    mimeType: "text/HTML",
    expectedContentLength: data.count,
    textEncodingName: "UTF-8")

webView.loadSimulatedRequest(request, response: response, responseData: data)
```

To load a file called `index.html` from your main bundle’s `resources` directory with user attribution, use the  method:
```
To load a file called `index.html` from your main bundle’s `resources` directory with user attribution, use the  method:
```swift
let fileURL = Bundle.main.url(
    forResource: "index",
    withExtension: "html",
    subdirectory: "resources")!

var fileRequest = URLRequest(url: fileURL)
fileRequest.attribution = .user

webView.loadFileRequest(
    fileRequest,
    allowingReadAccessTo: fileURL.deletingLastPathComponent())
```

#### 
To load link presentation metadata with attribution, use the  fetch method that takes a request. Specifically, use the  method — again, relying on the user-attributed `request` value that you defined earlier:
```swift
import LinkPresentation

let metadataProvider = LPMetadataProvider()
let metadata = try await metadataProvider.startFetchingMetadata(for: request)
```

#### 
To control attribution when using the  framework, set the  property of an  instance to , and use that to create a connection:
```swift
import Network

let parameters = NWParameters()
parameters.attribution = .user
let endpoint = NWEndpoint.url(url)
let connection = NWConnection(to: endpoint, using: parameters)
```

```
Alternatively, you can work with an  instance, and set the attribution to  with a call to the  function:
```swift
let parameters = nw_parameters_create()
nw_parameters_set_attribution(parameters, .user)
let endpoint = nw_endpoint_create_url("https://example.com")
let connection = nw_connection_create(endpoint, parameters)
```

#### 
To control attribution when working with sockets, import the `ne_socket.h` header file, and use the `ne_socket_set_attribution` function to set the value `NE_SOCKET_ATTRIBUTION_USER` on a socket:
```objc
#include <sys/socket.h>
#include <networkext/ne_socket.h>

int tcpSocket = socket(PF_INET, SOCK_STREAM, 0);
if (ne_socket_set_attribution(tcpSocket, NE_SOCKET_ATTRIBUTION_USER) != 0) {
    // Handle error.
}
```

```
If you use custom DNS resolution, also call `ne_socket_set_domains()` function to associate the resolved domain name (as well as any resolved `CNAME`) with the socket:
```objc
const char *domains[] = { "resolved.example.com" };
if (ne_socket_set_domains(tcpSocket, domains, 1) != 0) {
    // Handle error.
}
```

```
This gives the system an opportunity to evaluate whether the resolved domain has been identified as potentially collecting information across apps and sites. After performing any additional configuration, use the socket to create a connection:
```objc
const struct sockaddr *address = <#Some address#>;
int connectResult = connect(tcpSocket, address, address->sa_len);
```


## Inspecting app activity data
> https://developer.apple.com/documentation/network/inspecting-app-activity-data

### 
#### 
#### 
Save the report to a location where you can examine it. For example, you can use AirDrop to send it to a nearby Mac.
The report uses a newline-delimited JSON format (NDJSON), which you can open with any text editor, and contains a collection of JSON dictionaries separated by newlines. Dictionaries that have the `type` key with a value set to `access` provide information about resource accesses, while those that have the `type` key with a value set to `networkActivity` provide information about network activity:
```javascript
{..., "type":"access", ...}
{..., "type":"access", ...}
...
{..., "type":"networkActivity", ...}
{..., "type":"networkActivity", ...}
...
```

#### 
Each access dictionary in the file represents the start or end of an access made by a particular app. The following shows an example of this dictionary with whitespace, newlines, and comments added for readability:
```javascript
{
  "accessor" : { 
    "identifier" : "com.example.calendar", // The app accessing the resource.
    "identifierType" : "bundleID"
  },
  "broadcaster": { // Only present for screen recording.
    "identifier" : "com.apple.springboard", // The app broadcasting the screen.
    "identifierType" : "bundleID"
  },
  "category" : "screenRecording", // The accessed resource.
  "identifier" : "8A4054BB-1810-4F8B-8163-483409E2D35C", // A unique identifier.
  "kind" : "intervalBegin", // Whether this the beginning or end of an interval.
  "timeStamp" : "2021-08-06T15:46:13.532-07:00", // The time of the access.
  "type" : "access" // This is resource access data.
}
```

| `camera` | The device’s camera |
| `contacts` | The user’s contacts |
| `location` | Location data |
| `mediaLibrary` | The user’s media library |
| `microphone` | The device’s microphone |
| `photos` | The user’s photo library |
| `screenRecording` | Screen sharing |
- The start of the interval with the `kind` field set to `intervalBegin`, as shown in the example above.
- The end of the interval with the `kind` field set to `intervalEnd`.
The two dictionaries that bound an access interval have the same value for the `identifier` key.
#### 
A file exported from iOS or iPadOS contains another set of dictionaries that have the `type` key with a value set to `networkActivity` to report network accesses. Each dictionary describes a connection made by a specified app to a particular domain. The following shows an example of this dictionary, again with whitespace and newlines added for clarity:
```javascript
{
  "domain" : "api.example.com",
  "firstTimeStamp" : "2021-06-06T16:15:48Z",
  "context" : "",
  "timeStamp" : "2021-06-06T16:15:59Z",
  "domainType" : 2,
  "initiatedType" : "AppInitiated",
  "hits" : 10,
  "type" : "networkActivity",
  "domainOwner" : "",
  "bundleID" : "com.example.App1"
}
```

#### 

## Recording a Packet Trace
> https://developer.apple.com/documentation/network/recording-a-packet-trace

### 
#### 
The first step in recording a packet trace on the Mac is to choose the correct interface. If you choose the wrong interface, you may end up recording an empty packet trace. For example, if you use the `en0` interface on a Mac that has built-in Ethernet but is connected to the Internet over Wi-Fi, your packet trace will include all the traffic over the built-in Ethernet, that is, nothing.
Determine the correct interface name by running the `networksetup` command-line tool with the `-listallhardwareports` argument. This prints a list of network interfaces, including both the user-visible name and the short interface name needed by packet trace tools. For example:
```shell
$ networksetup -listallhardwareports

Hardware Port: Ethernet
Device: en0
Ethernet Address: 54:45:5b:01:ca:89

Hardware Port: Wi-Fi
Device: en1
Ethernet Address: 78:a1:3c:02:2b:da

… and so on …
```

#### 
Working with packet traces usually involves recording a packet trace to a file and analyzing that file. It’s possible to do both steps at once, and it’s a good idea to do that when you’re just getting started. The following Terminal command starts a packet trace and prints information about each packet as it’s transferred.
```shell
sudo tcpdump -i en0 -n
```

- `tcpdump` is the name of macOS’s built-in packet trace tool.
- The `sudo` command causes `tcpdump` to run with privileges, which is necessary in order to record packets.
When you run `tcpdump` in this way, you see something like this:
- The `-n` option tells tcpdump not to attempt to use reverse DNS to map IP addresses to names; such mapping is rarely useful on the modern Internet and it radically slows things down.
When you run `tcpdump` in this way, you see something like this:
```shell
17:49:26.500970 IP 192.168.1.187.64917 > 192.168.1.39.22: Flags [S], seq 3769365868, win 65535, options [mss 1460,nop,wscale 5,nop,nop,TS val 1478872373 ecr 0,sackOK,eol], length 0
17:49:26.503325 IP 192.168.1.39.22 > 192.168.1.187.64917: Flags [S.], seq 405178393, ack 3769365869, win 65535, options [mss 1460,nop,wscale 5,nop,nop,TS val 72353448 ecr 1478872373,sackOK,eol], length 0
17:49:26.503413 IP 192.168.1.187.64917 > 192.168.1.39.22: Flags [.], ack 1, win 4117, options [nop,nop,TS val 1478872375 ecr 72353448], length 0
17:49:26.504887 IP 192.168.1.39.22 > 192.168.1.187.64917: Flags [.], ack 1, win 4117, options [nop,nop,TS val 72353449 ecr 1478872375], length 0
17:49:26.526134 IP 192.168.1.39.22 > 192.168.1.187.64917: Flags [P.], seq 1:22, ack 1, win 4117, options [nop,nop,TS val 72353470 ecr 1478872375], length 21
17:49:26.526228 IP 192.168.1.187.64917 > 192.168.1.39.22: Flags [.], ack 22, win 4117, options [nop,nop,TS val 1478872396 ecr 72353470], length 0
```

There’s a line of output for each packet seen on the network. On each line there’s a timestamp and a lot of information about that packet. This specific example shows the start of a connection from an SSH client at 192.168.1.187 to an SSH server listening on port 22 of 192.168.1.39.
Packet traces can be quite overwhelming. Rather than trying to interpret the packet trace in real time, use the `-w` option to write the trace to a file and then do your analysis later on.
```shell
sudo tcpdump -i en0 -w trace.pcap
```

#### 
iOS doesn’t let you record a packet trace directly. However, you can use your Mac to record a packet trace on an attached iOS device using the Remote Virtual Interface (RVI) mechanism. To get started, first connect your iOS device to your Mac via USB. Next run the `rvictl` command in Terminal.
```shell
rvictl -s b0e8fe73db17d4993bd549418bfbdba70a4af2b1
```

- `rvictl` is the name of the command that manipulates RVIs.
- `-s` tells `rvictl` to set up a new RVI.
- `b0e8fe73db17d4993bd549418bfbdba70a4af2b1` is the UDID of the iOS device to target. This UDID is just an example; you can find your device’s UDID in the Devices and Simulators window in Xcode.
This command prints the following output.
```shell
$ rvictl -s b0e8fe73db17d4993bd549418bfbdba70a4af2b1

Starting device b0e8fe73db17d4993bd549418bfbdba70a4af2b1 [SUCCEEDED] with interface rvi0
```

```
This output includes the interface name of the newly-created RVI, `rvi0` in this example. Supply this interface name to your favorite packet trace tool to record a trace of the traffic on your iOS device. For example, use the following command to record a packet trace on `rvi0` and write it to `trace.pcap`.
```shell
sudo tcpdump -i rvi0 -w trace.pcap
```

#### 

## Testing and Debugging L4S in Your App
> https://developer.apple.com/documentation/network/testing-and-debugging-l4s-in-your-app

### 
#### 
On macOS, enable L4S by using the following command in Terminal:
```shell
defaults write -g network_enable_l4s -bool true
```

#### 
#### 
#### 
Below are the instructions to decrypt QUIC for quiche.
1. Add the following lines to your server application:
```objc
if let Some(keylog_path) = std::env::var_os("SSLKEYLOGFILE") {
    let file = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(keylog_path)
        .unwrap();

    keylog = Some(file);

    config.log_keys();
}
```

1. Configure the `SSLKEYLOGFILE` environment variable.
```
1. Configure the `SSLKEYLOGFILE` environment variable.
```shell
export SSLKEYLOGFILE=/tmp/keys.log
```

3. In Wireshark Preferences > Protocols > TLS, select the `SSLKEYLOGFILE` as the TLS secret log file in the (Pre)-Master-Secret log filename field.
#### 
#### 
- CE → CE
If you see any other transition, it means that network doesn’t support ECN correctly. To check which hop of your network doesn’t support ECN correctly, you can use Tracebox. Here is an example usage:
```shell
sudo tracebox -v -p "ip{ecn=1}/udp{dst=33451}" apple.com
```

```
Every line in the Tracebox output shows a hop and packet headers that were modified before they reached that hop. This helps you identify the hop that modified ECN bits on the packet. For example, in the output below, `IP::ExpCongestionNot (1 → 0)` on the third line means that hop 2 bleached the ECN bit (from 1→0) because hop 3 received a packet with modified ECN bits.
```None
1: a.b.c.d 0ms IP::CheckSum (0x45bf → 0x6d97)
2: e.f.h.g 1ms IP::TTL (2 → 1) IP::CheckSum (0x44bf → 0x6d97)
3: h.i.j.k 3ms IP::ExpCongestionNot (1 → 0) IP::TTL (3 → 1) IP::CheckSum (0x6ec0 → 0x9879)
```

#### 
If you’re a network operator, you can take a couple of actions to provide low latency and low loss to your users.
Check that your network configuration doesn’t bleach, alter, or block ECN traffic because doing any of these actions may harm the traffic. However, your network might be accidentally doing it while it’s trying to zero the Differentiated Services Codepoint (DSCP) because both the Diffserv and ECN fields are in the same IP header byte. You can fix this in your code or ask your equipment provider to provide a bug fix that zeros only the DSCP portion (bytes 8-13).
```None
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |   DSCP    |ECN|         Total Length          |
```


## Troubleshooting Packet Traces
> https://developer.apple.com/documentation/network/troubleshooting-packet-traces

### 
#### 
When you first launch Xcode, it installs the `rvictl` tool. If Terminal is unable to find the tool:
2. Make sure `/usr/bin/` is in your shell search path.
2. Make sure `/usr/bin/` is in your shell search path.
If `rvictl` fails with the message `bootstrap_look_up(): 1102`, make sure that the `com.apple.rpmuxd` daemon is installed and loaded. The following command should print information about the daemon:
```shell
sudo launchctl list com.apple.rpmuxd
```

```
If the daemon is installed correctly, you should see output like this:
```shell
$ sudo launchctl list com.apple.rpmuxd
{
    "Label" = "com.apple.rpmuxd";
    …
};
```

```
If the daemon isn’t installed correctly you’ll see this:
```shell
$ sudo launchctl list com.apple.rpmuxd
Could not find service "com.apple.rpmuxd" in domain for system
```

```
This message can indicate that the daemon is unloaded. You can force it to load as follows:
```shell
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.rpmuxd.plist
```

#### 
#### 
If you record all the bytes of each packet, it’s possible to overrun the kernel’s packet recording buffer. In this case, your packet trace tool should report a problem. For example, the `tcpdump` tool prints a summary of how many packets were recorded, filtered, and  when you stop the recording.
```shell
$ sudo tcpdump -i en0 -w trace.pcap
tcpdump: listening on en0, link-type EN10MB (Ethernet), capture size 65535 bytes
^C
94 packets captured
177 packets received by filter
0 packets dropped by kernel
```

If the dropped count is non-zero, increase the packet recording buffer size by passing the `-B` option to `tcpdump`.
> **note:**  For more information about this and other `tcpdump` options, see .
#### 
#### 

