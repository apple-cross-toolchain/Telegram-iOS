// Generated intent type stubs for cross-compilation on Linux.
// On macOS, these are produced by intentbuilderc from Intents.intentdefinition.

import Foundation
import Intents

// MARK: - Friend (INObject subclass)

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(Friend)
public class Friend: INObject {
    @available(iOS 14.0, macOS 11.0, watchOS 7.0, *)
    @objc
    public convenience init(identifier: String, display: String, subtitle: String?, image: INImage?) {
        self.init(identifier: identifier, display: display)
        self.subtitleString = subtitle
        self.displayImage = image
    }

    @available(iOS 14.0, macOS 11.0, watchOS 7.0, *)
    @objc
    public convenience init(identifier: String, display: String, pronunciationHint: String?, subtitle: String?, image: INImage?) {
        self.init(identifier: identifier, display: display, pronunciationHint: pronunciationHint)
        self.subtitleString = subtitle
        self.displayImage = image
    }

    @objc public var subtitle: String? {
        if #available(iOS 14.0, watchOS 7.0, *) {
            return subtitleString
        }
        return nil
    }
}

// MARK: - SelectFriendsIntent

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectFriendsIntent)
public class SelectFriendsIntent: INIntent {
    @objc public var friends: [Friend]?
}

// MARK: - SelectFriendsIntentHandling

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectFriendsIntentHandling)
public protocol SelectFriendsIntentHandling: NSObjectProtocol {
    @available(iOS 14.0, macOS 11.0, watchOS 7.0, *)
    func provideFriendsOptionsCollection(for intent: SelectFriendsIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Friend>?, Error?) -> Void)
}

// MARK: - SelectFriendsIntentResponse

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectFriendsIntentResponseCode)
public enum SelectFriendsIntentResponseCode: Int {
    case unspecified = 0
    case ready = 1
    case continueInApp = 2
    case inProgress = 3
    case success = 4
    case failure = 5
    case failureRequiringAppLaunch = 6
}

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectFriendsIntentResponse)
public class SelectFriendsIntentResponse: INIntentResponse {
    @objc public var code: SelectFriendsIntentResponseCode = .unspecified

    @objc(initWithCode:userActivity:)
    public convenience init(code: SelectFriendsIntentResponseCode, userActivity: NSUserActivity?) {
        self.init()
        self.code = code
        self.userActivity = userActivity
    }
}

// MARK: - SelectAvatarFriendsIntent

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectAvatarFriendsIntent)
public class SelectAvatarFriendsIntent: INIntent {
    @objc public var friends: [Friend]?
}

// MARK: - SelectAvatarFriendsIntentHandling

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectAvatarFriendsIntentHandling)
public protocol SelectAvatarFriendsIntentHandling: NSObjectProtocol {
    @available(iOS 14.0, macOS 11.0, watchOS 7.0, *)
    func provideFriendsOptionsCollection(for intent: SelectAvatarFriendsIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<Friend>?, Error?) -> Void)

    @available(iOS 14.0, macOS 11.0, watchOS 7.0, *)
    @objc optional func defaultFriends(for intent: SelectAvatarFriendsIntent) -> [Friend]?
}

// MARK: - SelectAvatarFriendsIntentResponse

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectAvatarFriendsIntentResponseCode)
public enum SelectAvatarFriendsIntentResponseCode: Int {
    case unspecified = 0
    case ready = 1
    case continueInApp = 2
    case inProgress = 3
    case success = 4
    case failure = 5
    case failureRequiringAppLaunch = 6
}

@available(iOS 12.0, macOS 11.0, watchOS 5.0, *)
@objc(SelectAvatarFriendsIntentResponse)
public class SelectAvatarFriendsIntentResponse: INIntentResponse {
    @objc public var code: SelectAvatarFriendsIntentResponseCode = .unspecified

    @objc(initWithCode:userActivity:)
    public convenience init(code: SelectAvatarFriendsIntentResponseCode, userActivity: NSUserActivity?) {
        self.init()
        self.code = code
        self.userActivity = userActivity
    }
}
