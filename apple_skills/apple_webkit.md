# Apple WEBKIT Skill


## Adding Picture in Picture to your Safari media controls
> https://developer.apple.com/documentation/webkitjs/adding_picture_in_picture_to_your_safari_media_controls

### 
#### 
In this example, the custom controls for a video have only a Play button and a hidden Pause button: 
```other
<video id="video" src="my-video.mp4"></video>
<div id="controls">
    <button id="playButton">Play</button>
    <button id="pauseButton" hidden>Pause</button>
</div>
```

#### 
Add markup for a new Picture-in-Picture button, which is visible by default. 
```other
<video id="video" src="my-video.mp4"></video>
<div id="controls">
    <button id="playButton">Play</button>
    <button id="pauseButton" hidden>Pause</button>
    <button id="PiPButton">PiP</button>
</div> 
```

#### 
Add a function to toggle Picture in Picture using the  property from the presentation mode API.
```javascript
if (video.webkitSupportsPresentationMode && video.webkitSupportsPresentationMode("picture-in-picture") && typeof video.webkitSetPresentationMode === "function") {
    // Toggle PiP when the user clicks the button.
    pipButtonElement.addEventListener("click", function(event) {
        video.webkitSetPresentationMode(video.webkitPresentationMode === "picture-in-picture" ? "inline" : "picture-in-picture");
    });
} else {
    pipButtonElement.disabled = true;
}
```


## Adding an AirPlay button to your Safari media controls
> https://developer.apple.com/documentation/webkitjs/adding_an_airplay_button_to_your_safari_media_controls

### 
#### 
In this example, the custom controls for a video have only a Play button and a hidden Pause button: 
```other
<video id="video" src="my-video.mp4"></video>
<div id="controls">
    <button id="playButton">Play</button>
    <button id="pauseButton" hidden>Pause</button>
</div>
```

#### 
Add markup for the AirPlay button, setting it to hidden by default to mimic the behavior of the AirPlay button in default controls. The default button appears only when AirPlay is available.
```other
<video id="video" src="my-video.mp4"></video>
<div id="controls">
    <button id="playButton">Play</button>
    <button id="pauseButton" hidden>Pause</button>
    <button id="airPlayButton" hidden disabled>AirPlay</button>
</div> 
```

#### 
> **note:** To conserve battery power, listen for this event only for as long as needed, and then stop listening. If the button is not visible, controls are hidden, or the user is in fullscreen mode, stop listening. 
```javascript
if (window.WebKitPlaybackTargetAvailabilityEvent) {
    video.addEventListener('webkitplaybacktargetavailabilitychanged',
        function(event) {
            switch (event.availability) {
            case "available":
                airPlayButton.hidden = false;
                airPlayButton.disabled = false;
                break;
            case "not-available":
                airPlayButton.hidden = true;
                airPlayButton.disabled = true;
                break;
        } }); 
} 
```

#### 
Add this block of code to use the native AirPlay route picker in your controls. With this route picker, you can add and select an available AirPlay device:
```javascript
if (!window.WebKitPlaybackTargetAvailabilityEvent)
    return;
var airPlayButton = document.getElementById("airPlayButton");
var video = document.getElementById("video");
airPlayButton.addEventListener('click', function(event) {
    video.webkitShowPlaybackTargetPicker();
});
```

#### 
Use the code below to listen for the event `webkitcurrentplaybacktargetiswirelesschanged`. This event fires when a media element starts or stops AirPlay playback. Use this event to update styles.
```javascript
 if (!window.WebKitPlaybackTargetAvailabilityEvent)
     return;
 var video = document.getElementById("video");
 video.addEventListener('webkitcurrentplaybacktargetiswirelesschanged', 
     function(event) {
         updateAirPlayButtonWirelessStyle();
         updatePageDimmerForWirelessPlayback();
     });
```


## Delivering Video Content for Safari
> https://developer.apple.com/documentation/webkit/delivering-video-content-for-safari

### 
#### 
Using `<video>` elements in HTML5 markup allows you to embed video on your website.
#### 
GIFs can be up to 12 times as expensive in bandwidth and twice as expensive in energy use when compared to a modern video codec. Instead, use H.264-encoded MP4 files for animations; for example:
```javascript
<img src="explosion.mp4" alt="An explosion of colors.">

```

By placing your videos in `<img>` elements, the content loads faster, uses less battery power, and gets better performance.
By placing your videos in `<img>` elements, the content loads faster, uses less battery power, and gets better performance.
To maintain compatibility with other web browsers, also include a fallback image:
```javascript
<picture>
    <source srcset="explosion.mp4" type="video/mp4">
    <img src="explosion.jpg" alt="An image of an explosion.">
</picture>
```

#### 
When you want to display short-form content, it is more optimal to play your video inline. Use `<video playsinline>` to play videos inline.

## Promoting Apps with Smart App Banners
> https://developer.apple.com/documentation/webkit/promoting-apps-with-smart-app-banners

### 
#### 
To add a Smart App Banner to your website, include the following meta tag in the `head` element of each page where you’d like the banner to appear:
To add a Smart App Banner to your website, include the following meta tag in the `head` element of each page where you’d like the banner to appear:
```javascript
<meta name="apple-itunes-app" content="app-id=myAppStoreID, app-argument=myURL">
```

#### 
Implement the : method in your app delegate, which fires when your app is launched from a URL. Then provide logic that can interpret the URL you pass. The value you set for the `app-argument` parameter is available as the   object.
The code sample below is for a website that passes data to a native iOS app. It first detects whether the URL contains the string `/profile`. If so, it opens the profile view controller and passes the profile ID number that’s in the query string.
```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    // In this example, the URL from which the user came is http://example.com/profile/?12345.

    // Determine whether the user was viewing a profile.
    if ([[url path] isEqualToString:@"/profile"]) {

        // Switch to the profile view controller.
        [self.tabBarController setSelectedViewController:profileViewController];

        // Pull the profile ID number found in the query string.
        NSString *profileID = [url query];

        // Pass the profile ID number to the profile view controller.
        [profileViewController loadProfile:profileID];

    }
    return YES;
}
```


## Testing with WebDriver in Safari
> https://developer.apple.com/documentation/webkit/testing-with-webdriver-in-safari

### 
#### 
Safari and Safari Technology Preview each provide their own `safaridriver` executable. Make sure you already have the executable on your device:
- Safari’s executable is located at `/usr/bin/safaridriver`.
#### 
#### 
Run `safaridriver --enable` once. (If you’re upgrading from a previous macOS release, you may need to use `sudo`.)
#### 
> **note:**  In the Python WebDriver library, each method call synchronously blocks processes until the operation completes. Other WebDriver libraries may provide an asynchronous API.
```python
#coding: utf-8
from selenium.webdriver.common.by import By
from selenium import webdriver
import unittest
import time

def setup_module(module):
    WebKitFeatureStatusTest.driver = webdriver.Safari()

def teardown_module(module):
    WebKitFeatureStatusTest.driver.quit()

class WebKitFeatureStatusTest(unittest.TestCase):
    
    def test_feature_status_page_search(self):
        self.driver.get("https://webkit.org/status/")
            
        # Enter "CSS" into the search box.
        # Ensures that at least one result appears in search
        search_box = self.driver.find_element_by_id("search")
        search_box.send_keys("CSS")
        value = search_box.get_attribute("value")
        self.assertTrue(len(value) > 0)
        search_box.submit()
        time.sleep(1)
        # Count the visible results when filters are applied
        # so one result shows up in at most one filter
        feature_count = self.shown_feature_count()
        self.assertTrue(feature_count > 0)
        
    def test_feature_status_page_filters(self):
        self.driver.get("https://webkit.org/status/")
            
        time.sleep(1)
        filters = self.driver.execute_script("return document.querySelectorAll('.filter-toggle')")
        self.assertTrue(len(filters) is 7)
        
        # Make sure every filter is turned off.
        for checked_filter in filter(lambda f: f.is_selected(), filters):
            checked_filter.click()
        
        # Make sure you can select every filter.
        for filt in filters:
            filt.click()
            self.assertTrue(filt.is_selected())
            filt.click()
    
    def shown_feature_count(self):
                return len(self.driver.execute_script("return document.querySelectorAll('li.feature:not(.is-hidden)')"))

if __name__ == "__main__":
    unittest.main()
```

#### 
Copy and save the test code above as `test_webkit.py` and run the following:
Copy and save the test code above as `test_webkit.py` and run the following:
```bash
python test_webkit.py
```


