# Apple BACKGROUNDTASKS Skill


## Performing long-running tasks on iOS and iPadOS
> https://developer.apple.com/documentation/backgroundtasks/performing-long-running-tasks-on-ios-and-ipados

### 
### 
To begin a job that you want to complete even if a person backgrounds the app, start by creating a task request (). Choose a name the system can use to identify the specific job in the `taskIdentifier` parameter of the initializer and prefix it with your app’s bundle ID:
```swift
private let taskIdentifier = "<bundle-id><task-name>" // Use your app's bundle ID.   

// Create the task request. 
let request = BGContinuedProcessingTaskRequest(
    identifier: taskIdentifier,
    title: "A video export",
    subtitle: "About to start...",
)
```

### 
If your job includes API that can utilize the GPU, enable background GPU use for your task by setting  to . First, check whether the device supports background GPU use by seeing if  contains `.gpu`:
```swift
if BGTaskScheduler.supportedResources.contains(.gpu) {
    request.requiredResources = .gpu
}
```

### 
When the system is busy or resource constrained, it might queue your task request for later execution. The default submission strategy, , instructs the system to add your task request to a queue if there’s no immediately available room to run it.
If instead you want the task submission to fail if the system is unable to run the task immediately, set  to   .
```swift
request.strategy = .fail
```

### 
To run the job, register the task request with the shared  using the unique `taskIdentifier`:
To run the job, register the task request with the shared  using the unique `taskIdentifier`:
```swift
BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
    guard let task = task as? BGContinuedProcessingTask else { return }
    ... 
```

The  launch handler provides the  reference for you to control execution.
Inside the launch handler, define your task’s long-running code:
```swift
// App-defined function that registers a continuous background task and defines its long-running work.
private func register() {
    // Submission bookkeeping. 
    if submitted {
        return
    }
    submitted = true
    
    // Register the continuous background task. 
    scheduler.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
        guard let task = task as? BGContinuedProcessingTask else {
            return
        }
        /* Do long-running work here. */
    }
}

```

```
Next, submit the request by passing it to the shared scheduler’s  method:
```swift
// App-defined function that submits a video export job through a continuous background task.
private func submit() {
    // Create the task request. 
    let request = BGContinuedProcessingTaskRequest(identifier: taskIdentifier, title: "A video export", subtitle: "About to start...")

    // Submit the task request.
    do {
        try scheduler.submit(request)
    } catch {
        print("Failed to submit request: \(error)")
    }
}
```

### 
The system displays the job and other continuous background tasks in a Live Activity to inform people of background task progress. It’s important to display accurate progress, as a person can cancel a task through the Live Activity widget if the task appears to be stuck.
To set progress, use the  protocol that  conforms to:
```swift
// Create a progress instance.
let stepCount: Int64 = 100 // For example, percentage of completion.
let progress = Progress(totalUnitCount: stepCount)

for i in 1...stepCount {
    // Update progress.
    task.progress.completedUnitCount = Int64(i)
} 
```

### 
Prepare to handle task failure or success by checking the tasks :
```swift
/// App-defined function that exports a video through a continuous background task.
func export(_ task: BGContinuedProcessingTask) -> Result<(), PipelineError> {
    var wasExpired = false

    // Check the expiration handler to confirm job completion.
    task.expirationHandler = {
        wasExpired = true
    }

    // Update progress.
    let progress = task.progress
    progress.totalUnitCount = 100
    while !progress.isFinished && !wasExpired {
        progress.completedUnitCount += 1
        let formattedProgress = String(format: "%.2f", progress.fractionCompleted * 100)

        // Update task for displayed progress.
        task.updateTitle(task.title, subtitle: "Completed \(formattedProgress)%")
        sleep(1)
    }

    // Check progress to confirm job completion.
    if progress.isFinished {
        return .success(())
    } else {
        return .failure(.expired)
    }
}
```


## Starting and Terminating Tasks During Development
> https://developer.apple.com/documentation/backgroundtasks/starting-and-terminating-tasks-during-development

### 
#### 
3. In the debugger, execute the line shown below, substituting the identifier of the desired task for `TASK_IDENTIFIER`.
3. In the debugger, execute the line shown below, substituting the identifier of the desired task for `TASK_IDENTIFIER`.
4. Resume your app. The system calls the launch handler for the desired task.
```other
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"TASK_IDENTIFIER"]
```

#### 
4. In the debugger, execute the line shown below, substituting the identifier of the desired task for `TASK_IDENTIFIER`.
4. In the debugger, execute the line shown below, substituting the identifier of the desired task for `TASK_IDENTIFIER`.
5. Resume your app. The system calls the expiration handler for the desired task.
```other
e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateExpirationForTaskWithIdentifier:@"TASK_IDENTIFIER"]
```


