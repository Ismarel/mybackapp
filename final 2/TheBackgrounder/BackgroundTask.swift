//
//  BackgroundTask.swift
//  TheBackgrounder
//
//  Created by Ismarel on 12/05/18.
//  Copyright © 2018 Razeware, LLC. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import UserNotifications

class BackgroundTask: NSObject {
  
  var updateTimer: Timer?
  var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
  
  func startBackground(){
    NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(enterActiveapp), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(enterTerminateapp), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    
    print("initial background task")
    updateTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(backTask), userInfo: nil, repeats: true)
    
    listenVolumenButton()
    registerBackground()
  }
  
  
  @objc func enterBackground() {
    print("Enter background")
  }
  
  @objc func enterActiveapp(){
    print("Enter active app")
    if updateTimer != nil && backgroundTask == UIBackgroundTaskInvalid {
      registerBackground()
    }
  }
  
  @objc func enterForeground(){
    print("Enter Foreground")
  }
  
  @objc func enterTerminateapp() {
    print("Terminate app")
    if #available(iOS 10.0, *) {
      createNotification(title: "Precaución", info: "Es necesario que esta aplicacion este activa para poder funcionar.")
    } else {
      // Fallback on earlier versions
    }
  }
  
  @objc func backTask(){
    //print("is back task ...")
  }
  
  func registerBackground(){
    backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
      self?.endBackgroundTask()
    })
    assert(backgroundTask != UIBackgroundTaskInvalid)
  }
  
  func endBackgroundTask() {
    print("Background task ended.")
    UIApplication.shared.endBackgroundTask(backgroundTask)
    backgroundTask = UIBackgroundTaskInvalid
  }
  
  func listenVolumenButton(){
    let audioSession = AVAudioSession.sharedInstance()
    do{
      try audioSession.setActive(true)
    }catch{
      print("error into")
    }
    audioSession.addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions.new, context: nil)
  
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "outputVolume"{
      if let volulevel = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.floatValue {
         print("press button \(volulevel)")
        if volulevel == 0{
          if #available(iOS 10.0, *) {
            createNotification(title: "Volumen", info: "El volumen es cero!!")
          } else {
            // Fallback on earlier versions
          }
        }
      }
    }
  }
  
  func volumechange(){
    print("volumen")
  }
  
  @available(iOS 10.0, *)
  func createNotification(title: String, info: String){
    let content = UNMutableNotificationContent()
    content.title = NSString.localizedUserNotificationString(forKey: title, arguments: nil)
    content.body = NSString.localizedUserNotificationString(forKey: info, arguments: nil)
    content.sound = UNNotificationSound.default()
    content.categoryIdentifier = "notify-test"
    
    let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 0.2, repeats: false)
    let request = UNNotificationRequest.init(identifier: "notify-test", content: content, trigger: trigger)
    
    let center = UNUserNotificationCenter.current()
    center.add(request)
  }
}
