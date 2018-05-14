
import UIKit

class WhateverViewController: UIViewController {
  
  @IBOutlet var resultsLabel: UILabel!
  
  var previous = NSDecimalNumber.one
  var current = NSDecimalNumber.one
  var position: UInt = 1
  var updateTimer: Timer?
  var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
  
  override func viewDidLoad() {
    super.viewDidLoad()
   //a NotificationCenter.default.addObserver(self, selector: #selector(reinstateBackgroundTask), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    
    let backgroundtask = BackgroundTask()
    backgroundtask.startBackground() 
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func reinstateBackgroundTask() {
    if updateTimer != nil && (backgroundTask == UIBackgroundTaskInvalid) {
      registerBackgroundTask()
    }
  }
  
  @IBAction func didTapPlayPause(_ sender: UIButton) {
    sender.isSelected = !sender.isSelected
    if sender.isSelected {
      resetCalculation()
      updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self,
        selector: #selector(calculateNextNumber), userInfo: nil, repeats: true)
      registerBackgroundTask()
    } else {
      updateTimer?.invalidate()
      updateTimer = nil
      if backgroundTask != UIBackgroundTaskInvalid {
        endBackgroundTask()
      }
    }
  }
  
  func resetCalculation() {
    previous = NSDecimalNumber.one
    current = NSDecimalNumber.one
    position = 1
  }
  
  func registerBackgroundTask() {
    backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
    assert(backgroundTask != UIBackgroundTaskInvalid)
  }

  func endBackgroundTask() {
    print("Background task ended.")
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = UIBackgroundTaskInvalid
  }
  
  func calculateNextNumber() {
    let result = current.adding(previous)
    
    let bigNumber = NSDecimalNumber(mantissa: 1, exponent: 40, isNegative: false)
    if result.compare(bigNumber) == .orderedAscending {
      previous = current
      current = result
      position += 1
    } else {
      // This is just too much.... Start over.
      resetCalculation()
    }
    
    let resultsMessage = "Position \(position) = \(current)"
    
    switch UIApplication.shared.applicationState {
    case .active:
      resultsLabel.text = resultsMessage
    case .background:
      print("App is backgrounded. Next number = \(resultsMessage)")
      print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
    case .inactive:
      break
    }
  }
}
