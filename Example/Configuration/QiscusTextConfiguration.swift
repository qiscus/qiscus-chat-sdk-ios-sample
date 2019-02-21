//
//  TextConfiguration.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 9/7/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

class TextConfiguration: NSObject {
    static var sharedInstance = TextConfiguration()
    
    /// Your text to show as subtitle if there isn't any message, Default value : "Let's write message to start conversation"
    var emptyMessage = "EMPTY_MESSAGE"//.getLocalize()
    
    /// Your text to show as title if there isn't any message, Default value : "Welcome"
    var emptyTitle = "WELCOME"//.getLocalize()
    
    /// Your text to show as title chat, Default value : "Title"
    var chatTitle = ""
    
    /// Your text to show as subtitle chat, Default value : "Sub Title"
    var chatSubtitle = ""
    
    /// Your text if you set chat read only, Default value : "Archieved message: This message was locked. Click the key to the conversation."
    var readOnlyText = "Archieved message: This message was locked. Click the key to the conversation."
    
    /// Your text placeholder if you want to send any message, Default value : "Text a message here ..."
    var textPlaceholder = "Type your message"
    
    var captionPlaceholder = "Add caption to your image"
    /// Your text to show as title alert when you access gallery but you not allow gallery access, Default value : "Important"
    var galeryAccessAlertTitle = "Important"
    
    /// Your text to show as content alert when you access gallery but you not allow gallery access, Default value : "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    var galeryAccessAlertText = "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    var locationAccessAlertText = "We need location access to share your current location.\nPlease allow location access in your iPhone Setting"
    var cameraAccessAlertText = "We need camera access to upload image from camera.\nPlease allow camera access in your iPhone Setting"
    var microphoneAccessAlertText = "We need microphone access to upload recorded audio.\nPlease allow mictophone access in your iPhone Setting"
    
    /// Your text to show as title confirmation when you want to upload image/file, Default value : "CONFIRMATION"
    var confirmationTitle = "CONFIRMATION"//.getLocalize()
    
    /// Your text to show as content confirmation when you want to upload image, Default value : "Are you sure to send this image?"
    var confirmationImageUploadText = "UPLOAD_IMAGE_CONFIRMATION"//.getLocalize()
    
    /// Your text to show as content confirmation when you want to upload file, Default value : "Are you sure to send"
    var confirmationFileUploadText = "UPLOAD_FILE_CONFIRMATION"//.getLocalize()
    
    /// Your text in back action, Default value : ""
    var backText = ""
    
    /// Your question mark, Default value : "?"
    var questionMark = "?"
    
    /// Your text in alert OK button, Default value : "OK"
    var alertOkText = "OK"
    
    /// Your text in alert Cancel button, Default value : "CANCEL"
    var alertCancelText = "CANCEL"//.getLocalize()
    
    /// Your text in alert Setting button, Default value : "SETTING"
    var alertSettingText = "SETTING"//.getLocalize()
    
    /// Your text if the day is "today", Default value : "Today"
    var todayText = "Today"
    
    /// Your text if it is the process of uploading file, Default value : "Uploading"
    var uploadingText = "UPLOADING"//.getLocalize()
    /// Your text if it is the process of uploading file, Default value : "Uploading"
    var downloadingText = "DOWNLOADING"//.getLocalize()
    
    /// Your text if it is the process of uploading image, Default value : "Sending"
    var sendingText = "SENDING"//.getLocalize()
    
    /// Your text if the process of uploading fail, Default value : "Sending Failed"
    var failedText = "FAILED"//.getLocalize()
    
    var deletingText = "DELETING"//.getLocalize()
    
    /// Your text if there isn't connection internet, Default value :  "can't connect to internet, please check your connection"
    var noConnectionText = "NO_CONNECTION"//.getLocalize()
    
    var defaultRoomSubtitle = "not Available"
    
    fileprivate override init(){}
}
