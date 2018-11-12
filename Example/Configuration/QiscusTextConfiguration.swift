//
//  TextConfiguration.swift
//  QiscusSDK
//
//  Created by Ahmad Athaullah on 9/7/16.
//  Copyright © 2016 Ahmad Athaullah. All rights reserved.
//

import UIKit

open class TextConfiguration: NSObject {
    static var sharedInstance = TextConfiguration()
    
    /// Your text to show as subtitle if there isn't any message, Default value : "Let's write message to start conversation"
    open var emptyMessage = "EMPTY_MESSAGE"//.getLocalize()
    
    /// Your text to show as title if there isn't any message, Default value : "Welcome"
    open var emptyTitle = "WELCOME"//.getLocalize()
    
    /// Your text to show as title chat, Default value : "Title"
    open var chatTitle = ""
    
    /// Your text to show as subtitle chat, Default value : "Sub Title"
    open var chatSubtitle = ""
    
    /// Your text if you set chat read only, Default value : "Archieved message: This message was locked. Click the key to open the conversation."
    open var readOnlyText = "Archieved message: This message was locked. Click the key to open the conversation."
    
    /// Your text placeholder if you want to send any message, Default value : "Text a message here ..."
    open var textPlaceholder = "Text Message"
    
    public var captionPlaceholder = "Caption here..."
    /// Your text to show as title alert when you access gallery but you not allow gallery access, Default value : "Important"
    open var galeryAccessAlertTitle = "Important"
    
    /// Your text to show as content alert when you access gallery but you not allow gallery access, Default value : "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    open var galeryAccessAlertText = "We need photos access to upload image.\nPlease allow photos access in your iPhone Setting"
    open var locationAccessAlertText = "We need location access to share your current location.\nPlease allow location access in your iPhone Setting"
    open var cameraAccessAlertText = "We need camera access to upload image from camera.\nPlease allow camera access in your iPhone Setting"
    open var microphoneAccessAlertText = "We need microphone access to upload recorded audio.\nPlease allow mictophone access in your iPhone Setting"
    
    /// Your text to show as title confirmation when you want to upload image/file, Default value : "CONFIRMATION"
    open var confirmationTitle = "CONFIRMATION"//.getLocalize()
    
    /// Your text to show as content confirmation when you want to upload image, Default value : "Are you sure to send this image?"
    open var confirmationImageUploadText = "UPLOAD_IMAGE_CONFIRMATION"//.getLocalize()
    
    /// Your text to show as content confirmation when you want to upload file, Default value : "Are you sure to send"
    open var confirmationFileUploadText = "UPLOAD_FILE_CONFIRMATION"//.getLocalize()
    
    /// Your text in back action, Default value : ""
    open var backText = ""
    
    /// Your question mark, Default value : "?"
    open var questionMark = "?"
    
    /// Your text in alert OK button, Default value : "OK"
    open var alertOkText = "OK"
    
    /// Your text in alert Cancel button, Default value : "CANCEL"
    open var alertCancelText = "CANCEL"//.getLocalize()
    
    /// Your text in alert Setting button, Default value : "SETTING"
    open var alertSettingText = "SETTING"//.getLocalize()
    
    /// Your text if the day is "today", Default value : "Today"
    open var todayText = "Today"
    
    /// Your text if it is the process of uploading file, Default value : "Uploading"
    open var uploadingText = "UPLOADING"//.getLocalize()
    /// Your text if it is the process of uploading file, Default value : "Uploading"
    open var downloadingText = "DOWNLOADING"//.getLocalize()
    
    /// Your text if it is the process of uploading image, Default value : "Sending"
    open var sendingText = "SENDING"//.getLocalize()
    
    /// Your text if the process of uploading fail, Default value : "Sending Failed"
    open var failedText = "FAILED"//.getLocalize()
    
    open var deletingText = "DELETING"//.getLocalize()
    
    /// Your text if there isn't connection internet, Default value :  "can't connect to internet, please check your connection"
    open var noConnectionText = "NO_CONNECTION"//.getLocalize()
    
    open var defaultRoomSubtitle = "not Available"
    
    fileprivate override init(){}
}
