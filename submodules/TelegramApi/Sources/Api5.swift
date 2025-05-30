public extension Api {
    enum ChatInviteImporter: TypeConstructorDescription {
        case chatInviteImporter(flags: Int32, userId: Int64, date: Int32, about: String?, approvedBy: Int64?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .chatInviteImporter(let flags, let userId, let date, let about, let approvedBy):
                    if boxed {
                        buffer.appendInt32(-1940201511)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    serializeInt32(date, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 2) != 0 {serializeString(about!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 1) != 0 {serializeInt64(approvedBy!, buffer: buffer, boxed: false)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .chatInviteImporter(let flags, let userId, let date, let about, let approvedBy):
                return ("chatInviteImporter", [("flags", flags as Any), ("userId", userId as Any), ("date", date as Any), ("about", about as Any), ("approvedBy", approvedBy as Any)])
    }
    }
    
        public static func parse_chatInviteImporter(_ reader: BufferReader) -> ChatInviteImporter? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Int32?
            _3 = reader.readInt32()
            var _4: String?
            if Int(_1!) & Int(1 << 2) != 0 {_4 = parseString(reader) }
            var _5: Int64?
            if Int(_1!) & Int(1 << 1) != 0 {_5 = reader.readInt64() }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 2) == 0) || _4 != nil
            let _c5 = (Int(_1!) & Int(1 << 1) == 0) || _5 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 {
                return Api.ChatInviteImporter.chatInviteImporter(flags: _1!, userId: _2!, date: _3!, about: _4, approvedBy: _5)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ChatOnlines: TypeConstructorDescription {
        case chatOnlines(onlines: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .chatOnlines(let onlines):
                    if boxed {
                        buffer.appendInt32(-264117680)
                    }
                    serializeInt32(onlines, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .chatOnlines(let onlines):
                return ("chatOnlines", [("onlines", onlines as Any)])
    }
    }
    
        public static func parse_chatOnlines(_ reader: BufferReader) -> ChatOnlines? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.ChatOnlines.chatOnlines(onlines: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ChatParticipant: TypeConstructorDescription {
        case chatParticipant(userId: Int64, inviterId: Int64, date: Int32)
        case chatParticipantAdmin(userId: Int64, inviterId: Int64, date: Int32)
        case chatParticipantCreator(userId: Int64)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .chatParticipant(let userId, let inviterId, let date):
                    if boxed {
                        buffer.appendInt32(-1070776313)
                    }
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    serializeInt64(inviterId, buffer: buffer, boxed: false)
                    serializeInt32(date, buffer: buffer, boxed: false)
                    break
                case .chatParticipantAdmin(let userId, let inviterId, let date):
                    if boxed {
                        buffer.appendInt32(-1600962725)
                    }
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    serializeInt64(inviterId, buffer: buffer, boxed: false)
                    serializeInt32(date, buffer: buffer, boxed: false)
                    break
                case .chatParticipantCreator(let userId):
                    if boxed {
                        buffer.appendInt32(-462696732)
                    }
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .chatParticipant(let userId, let inviterId, let date):
                return ("chatParticipant", [("userId", userId as Any), ("inviterId", inviterId as Any), ("date", date as Any)])
                case .chatParticipantAdmin(let userId, let inviterId, let date):
                return ("chatParticipantAdmin", [("userId", userId as Any), ("inviterId", inviterId as Any), ("date", date as Any)])
                case .chatParticipantCreator(let userId):
                return ("chatParticipantCreator", [("userId", userId as Any)])
    }
    }
    
        public static func parse_chatParticipant(_ reader: BufferReader) -> ChatParticipant? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Int32?
            _3 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.ChatParticipant.chatParticipant(userId: _1!, inviterId: _2!, date: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_chatParticipantAdmin(_ reader: BufferReader) -> ChatParticipant? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Int32?
            _3 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.ChatParticipant.chatParticipantAdmin(userId: _1!, inviterId: _2!, date: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_chatParticipantCreator(_ reader: BufferReader) -> ChatParticipant? {
            var _1: Int64?
            _1 = reader.readInt64()
            let _c1 = _1 != nil
            if _c1 {
                return Api.ChatParticipant.chatParticipantCreator(userId: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ChatParticipants: TypeConstructorDescription {
        case chatParticipants(chatId: Int64, participants: [Api.ChatParticipant], version: Int32)
        case chatParticipantsForbidden(flags: Int32, chatId: Int64, selfParticipant: Api.ChatParticipant?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .chatParticipants(let chatId, let participants, let version):
                    if boxed {
                        buffer.appendInt32(1018991608)
                    }
                    serializeInt64(chatId, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(participants.count))
                    for item in participants {
                        item.serialize(buffer, true)
                    }
                    serializeInt32(version, buffer: buffer, boxed: false)
                    break
                case .chatParticipantsForbidden(let flags, let chatId, let selfParticipant):
                    if boxed {
                        buffer.appendInt32(-2023500831)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(chatId, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 0) != 0 {selfParticipant!.serialize(buffer, true)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .chatParticipants(let chatId, let participants, let version):
                return ("chatParticipants", [("chatId", chatId as Any), ("participants", participants as Any), ("version", version as Any)])
                case .chatParticipantsForbidden(let flags, let chatId, let selfParticipant):
                return ("chatParticipantsForbidden", [("flags", flags as Any), ("chatId", chatId as Any), ("selfParticipant", selfParticipant as Any)])
    }
    }
    
        public static func parse_chatParticipants(_ reader: BufferReader) -> ChatParticipants? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: [Api.ChatParticipant]?
            if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: 0, elementType: Api.ChatParticipant.self)
            }
            var _3: Int32?
            _3 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.ChatParticipants.chatParticipants(chatId: _1!, participants: _2!, version: _3!)
            }
            else {
                return nil
            }
        }
        public static func parse_chatParticipantsForbidden(_ reader: BufferReader) -> ChatParticipants? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Api.ChatParticipant?
            if Int(_1!) & Int(1 << 0) != 0 {if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.ChatParticipant
            } }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 0) == 0) || _3 != nil
            if _c1 && _c2 && _c3 {
                return Api.ChatParticipants.chatParticipantsForbidden(flags: _1!, chatId: _2!, selfParticipant: _3)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ChatPhoto: TypeConstructorDescription {
        case chatPhoto(flags: Int32, photoId: Int64, strippedThumb: Buffer?, dcId: Int32)
        case chatPhotoEmpty
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .chatPhoto(let flags, let photoId, let strippedThumb, let dcId):
                    if boxed {
                        buffer.appendInt32(476978193)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(photoId, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 1) != 0 {serializeBytes(strippedThumb!, buffer: buffer, boxed: false)}
                    serializeInt32(dcId, buffer: buffer, boxed: false)
                    break
                case .chatPhotoEmpty:
                    if boxed {
                        buffer.appendInt32(935395612)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .chatPhoto(let flags, let photoId, let strippedThumb, let dcId):
                return ("chatPhoto", [("flags", flags as Any), ("photoId", photoId as Any), ("strippedThumb", strippedThumb as Any), ("dcId", dcId as Any)])
                case .chatPhotoEmpty:
                return ("chatPhotoEmpty", [])
    }
    }
    
        public static func parse_chatPhoto(_ reader: BufferReader) -> ChatPhoto? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Buffer?
            if Int(_1!) & Int(1 << 1) != 0 {_3 = parseBytes(reader) }
            var _4: Int32?
            _4 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 1) == 0) || _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.ChatPhoto.chatPhoto(flags: _1!, photoId: _2!, strippedThumb: _3, dcId: _4!)
            }
            else {
                return nil
            }
        }
        public static func parse_chatPhotoEmpty(_ reader: BufferReader) -> ChatPhoto? {
            return Api.ChatPhoto.chatPhotoEmpty
        }
    
    }
}
public extension Api {
    enum ChatReactions: TypeConstructorDescription {
        case chatReactionsAll(flags: Int32)
        case chatReactionsNone
        case chatReactionsSome(reactions: [Api.Reaction])
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .chatReactionsAll(let flags):
                    if boxed {
                        buffer.appendInt32(1385335754)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    break
                case .chatReactionsNone:
                    if boxed {
                        buffer.appendInt32(-352570692)
                    }
                    
                    break
                case .chatReactionsSome(let reactions):
                    if boxed {
                        buffer.appendInt32(1713193015)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(reactions.count))
                    for item in reactions {
                        item.serialize(buffer, true)
                    }
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .chatReactionsAll(let flags):
                return ("chatReactionsAll", [("flags", flags as Any)])
                case .chatReactionsNone:
                return ("chatReactionsNone", [])
                case .chatReactionsSome(let reactions):
                return ("chatReactionsSome", [("reactions", reactions as Any)])
    }
    }
    
        public static func parse_chatReactionsAll(_ reader: BufferReader) -> ChatReactions? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.ChatReactions.chatReactionsAll(flags: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_chatReactionsNone(_ reader: BufferReader) -> ChatReactions? {
            return Api.ChatReactions.chatReactionsNone
        }
        public static func parse_chatReactionsSome(_ reader: BufferReader) -> ChatReactions? {
            var _1: [Api.Reaction]?
            if let _ = reader.readInt32() {
                _1 = Api.parseVector(reader, elementSignature: 0, elementType: Api.Reaction.self)
            }
            let _c1 = _1 != nil
            if _c1 {
                return Api.ChatReactions.chatReactionsSome(reactions: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum CodeSettings: TypeConstructorDescription {
        case codeSettings(flags: Int32, logoutTokens: [Buffer]?, token: String?, appSandbox: Api.Bool?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .codeSettings(let flags, let logoutTokens, let token, let appSandbox):
                    if boxed {
                        buffer.appendInt32(-1390068360)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 6) != 0 {buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(logoutTokens!.count))
                    for item in logoutTokens! {
                        serializeBytes(item, buffer: buffer, boxed: false)
                    }}
                    if Int(flags) & Int(1 << 8) != 0 {serializeString(token!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 8) != 0 {appSandbox!.serialize(buffer, true)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .codeSettings(let flags, let logoutTokens, let token, let appSandbox):
                return ("codeSettings", [("flags", flags as Any), ("logoutTokens", logoutTokens as Any), ("token", token as Any), ("appSandbox", appSandbox as Any)])
    }
    }
    
        public static func parse_codeSettings(_ reader: BufferReader) -> CodeSettings? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: [Buffer]?
            if Int(_1!) & Int(1 << 6) != 0 {if let _ = reader.readInt32() {
                _2 = Api.parseVector(reader, elementSignature: -1255641564, elementType: Buffer.self)
            } }
            var _3: String?
            if Int(_1!) & Int(1 << 8) != 0 {_3 = parseString(reader) }
            var _4: Api.Bool?
            if Int(_1!) & Int(1 << 8) != 0 {if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.Bool
            } }
            let _c1 = _1 != nil
            let _c2 = (Int(_1!) & Int(1 << 6) == 0) || _2 != nil
            let _c3 = (Int(_1!) & Int(1 << 8) == 0) || _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 8) == 0) || _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.CodeSettings.codeSettings(flags: _1!, logoutTokens: _2, token: _3, appSandbox: _4)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum Config: TypeConstructorDescription {
        case config(flags: Int32, date: Int32, expires: Int32, testMode: Api.Bool, thisDc: Int32, dcOptions: [Api.DcOption], dcTxtDomainName: String, chatSizeMax: Int32, megagroupSizeMax: Int32, forwardedCountMax: Int32, onlineUpdatePeriodMs: Int32, offlineBlurTimeoutMs: Int32, offlineIdleTimeoutMs: Int32, onlineCloudTimeoutMs: Int32, notifyCloudDelayMs: Int32, notifyDefaultDelayMs: Int32, pushChatPeriodMs: Int32, pushChatLimit: Int32, editTimeLimit: Int32, revokeTimeLimit: Int32, revokePmTimeLimit: Int32, ratingEDecay: Int32, stickersRecentLimit: Int32, channelsReadMediaPeriod: Int32, tmpSessions: Int32?, callReceiveTimeoutMs: Int32, callRingTimeoutMs: Int32, callConnectTimeoutMs: Int32, callPacketTimeoutMs: Int32, meUrlPrefix: String, autoupdateUrlPrefix: String?, gifSearchUsername: String?, venueSearchUsername: String?, imgSearchUsername: String?, staticMapsProvider: String?, captionLengthMax: Int32, messageLengthMax: Int32, webfileDcId: Int32, suggestedLangCode: String?, langPackVersion: Int32?, baseLangPackVersion: Int32?, reactionsDefault: Api.Reaction?, autologinToken: String?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .config(let flags, let date, let expires, let testMode, let thisDc, let dcOptions, let dcTxtDomainName, let chatSizeMax, let megagroupSizeMax, let forwardedCountMax, let onlineUpdatePeriodMs, let offlineBlurTimeoutMs, let offlineIdleTimeoutMs, let onlineCloudTimeoutMs, let notifyCloudDelayMs, let notifyDefaultDelayMs, let pushChatPeriodMs, let pushChatLimit, let editTimeLimit, let revokeTimeLimit, let revokePmTimeLimit, let ratingEDecay, let stickersRecentLimit, let channelsReadMediaPeriod, let tmpSessions, let callReceiveTimeoutMs, let callRingTimeoutMs, let callConnectTimeoutMs, let callPacketTimeoutMs, let meUrlPrefix, let autoupdateUrlPrefix, let gifSearchUsername, let venueSearchUsername, let imgSearchUsername, let staticMapsProvider, let captionLengthMax, let messageLengthMax, let webfileDcId, let suggestedLangCode, let langPackVersion, let baseLangPackVersion, let reactionsDefault, let autologinToken):
                    if boxed {
                        buffer.appendInt32(-870702050)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt32(date, buffer: buffer, boxed: false)
                    serializeInt32(expires, buffer: buffer, boxed: false)
                    testMode.serialize(buffer, true)
                    serializeInt32(thisDc, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(dcOptions.count))
                    for item in dcOptions {
                        item.serialize(buffer, true)
                    }
                    serializeString(dcTxtDomainName, buffer: buffer, boxed: false)
                    serializeInt32(chatSizeMax, buffer: buffer, boxed: false)
                    serializeInt32(megagroupSizeMax, buffer: buffer, boxed: false)
                    serializeInt32(forwardedCountMax, buffer: buffer, boxed: false)
                    serializeInt32(onlineUpdatePeriodMs, buffer: buffer, boxed: false)
                    serializeInt32(offlineBlurTimeoutMs, buffer: buffer, boxed: false)
                    serializeInt32(offlineIdleTimeoutMs, buffer: buffer, boxed: false)
                    serializeInt32(onlineCloudTimeoutMs, buffer: buffer, boxed: false)
                    serializeInt32(notifyCloudDelayMs, buffer: buffer, boxed: false)
                    serializeInt32(notifyDefaultDelayMs, buffer: buffer, boxed: false)
                    serializeInt32(pushChatPeriodMs, buffer: buffer, boxed: false)
                    serializeInt32(pushChatLimit, buffer: buffer, boxed: false)
                    serializeInt32(editTimeLimit, buffer: buffer, boxed: false)
                    serializeInt32(revokeTimeLimit, buffer: buffer, boxed: false)
                    serializeInt32(revokePmTimeLimit, buffer: buffer, boxed: false)
                    serializeInt32(ratingEDecay, buffer: buffer, boxed: false)
                    serializeInt32(stickersRecentLimit, buffer: buffer, boxed: false)
                    serializeInt32(channelsReadMediaPeriod, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 0) != 0 {serializeInt32(tmpSessions!, buffer: buffer, boxed: false)}
                    serializeInt32(callReceiveTimeoutMs, buffer: buffer, boxed: false)
                    serializeInt32(callRingTimeoutMs, buffer: buffer, boxed: false)
                    serializeInt32(callConnectTimeoutMs, buffer: buffer, boxed: false)
                    serializeInt32(callPacketTimeoutMs, buffer: buffer, boxed: false)
                    serializeString(meUrlPrefix, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 7) != 0 {serializeString(autoupdateUrlPrefix!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 9) != 0 {serializeString(gifSearchUsername!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 10) != 0 {serializeString(venueSearchUsername!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 11) != 0 {serializeString(imgSearchUsername!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 12) != 0 {serializeString(staticMapsProvider!, buffer: buffer, boxed: false)}
                    serializeInt32(captionLengthMax, buffer: buffer, boxed: false)
                    serializeInt32(messageLengthMax, buffer: buffer, boxed: false)
                    serializeInt32(webfileDcId, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 2) != 0 {serializeString(suggestedLangCode!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 2) != 0 {serializeInt32(langPackVersion!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 2) != 0 {serializeInt32(baseLangPackVersion!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 15) != 0 {reactionsDefault!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 16) != 0 {serializeString(autologinToken!, buffer: buffer, boxed: false)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .config(let flags, let date, let expires, let testMode, let thisDc, let dcOptions, let dcTxtDomainName, let chatSizeMax, let megagroupSizeMax, let forwardedCountMax, let onlineUpdatePeriodMs, let offlineBlurTimeoutMs, let offlineIdleTimeoutMs, let onlineCloudTimeoutMs, let notifyCloudDelayMs, let notifyDefaultDelayMs, let pushChatPeriodMs, let pushChatLimit, let editTimeLimit, let revokeTimeLimit, let revokePmTimeLimit, let ratingEDecay, let stickersRecentLimit, let channelsReadMediaPeriod, let tmpSessions, let callReceiveTimeoutMs, let callRingTimeoutMs, let callConnectTimeoutMs, let callPacketTimeoutMs, let meUrlPrefix, let autoupdateUrlPrefix, let gifSearchUsername, let venueSearchUsername, let imgSearchUsername, let staticMapsProvider, let captionLengthMax, let messageLengthMax, let webfileDcId, let suggestedLangCode, let langPackVersion, let baseLangPackVersion, let reactionsDefault, let autologinToken):
                return ("config", [("flags", flags as Any), ("date", date as Any), ("expires", expires as Any), ("testMode", testMode as Any), ("thisDc", thisDc as Any), ("dcOptions", dcOptions as Any), ("dcTxtDomainName", dcTxtDomainName as Any), ("chatSizeMax", chatSizeMax as Any), ("megagroupSizeMax", megagroupSizeMax as Any), ("forwardedCountMax", forwardedCountMax as Any), ("onlineUpdatePeriodMs", onlineUpdatePeriodMs as Any), ("offlineBlurTimeoutMs", offlineBlurTimeoutMs as Any), ("offlineIdleTimeoutMs", offlineIdleTimeoutMs as Any), ("onlineCloudTimeoutMs", onlineCloudTimeoutMs as Any), ("notifyCloudDelayMs", notifyCloudDelayMs as Any), ("notifyDefaultDelayMs", notifyDefaultDelayMs as Any), ("pushChatPeriodMs", pushChatPeriodMs as Any), ("pushChatLimit", pushChatLimit as Any), ("editTimeLimit", editTimeLimit as Any), ("revokeTimeLimit", revokeTimeLimit as Any), ("revokePmTimeLimit", revokePmTimeLimit as Any), ("ratingEDecay", ratingEDecay as Any), ("stickersRecentLimit", stickersRecentLimit as Any), ("channelsReadMediaPeriod", channelsReadMediaPeriod as Any), ("tmpSessions", tmpSessions as Any), ("callReceiveTimeoutMs", callReceiveTimeoutMs as Any), ("callRingTimeoutMs", callRingTimeoutMs as Any), ("callConnectTimeoutMs", callConnectTimeoutMs as Any), ("callPacketTimeoutMs", callPacketTimeoutMs as Any), ("meUrlPrefix", meUrlPrefix as Any), ("autoupdateUrlPrefix", autoupdateUrlPrefix as Any), ("gifSearchUsername", gifSearchUsername as Any), ("venueSearchUsername", venueSearchUsername as Any), ("imgSearchUsername", imgSearchUsername as Any), ("staticMapsProvider", staticMapsProvider as Any), ("captionLengthMax", captionLengthMax as Any), ("messageLengthMax", messageLengthMax as Any), ("webfileDcId", webfileDcId as Any), ("suggestedLangCode", suggestedLangCode as Any), ("langPackVersion", langPackVersion as Any), ("baseLangPackVersion", baseLangPackVersion as Any), ("reactionsDefault", reactionsDefault as Any), ("autologinToken", autologinToken as Any)])
    }
    }
    
        public static func parse_config(_ reader: BufferReader) -> Config? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: Int32?
            _3 = reader.readInt32()
            var _4: Api.Bool?
            if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.Bool
            }
            var _5: Int32?
            _5 = reader.readInt32()
            var _6: [Api.DcOption]?
            if let _ = reader.readInt32() {
                _6 = Api.parseVector(reader, elementSignature: 0, elementType: Api.DcOption.self)
            }
            var _7: String?
            _7 = parseString(reader)
            var _8: Int32?
            _8 = reader.readInt32()
            var _9: Int32?
            _9 = reader.readInt32()
            var _10: Int32?
            _10 = reader.readInt32()
            var _11: Int32?
            _11 = reader.readInt32()
            var _12: Int32?
            _12 = reader.readInt32()
            var _13: Int32?
            _13 = reader.readInt32()
            var _14: Int32?
            _14 = reader.readInt32()
            var _15: Int32?
            _15 = reader.readInt32()
            var _16: Int32?
            _16 = reader.readInt32()
            var _17: Int32?
            _17 = reader.readInt32()
            var _18: Int32?
            _18 = reader.readInt32()
            var _19: Int32?
            _19 = reader.readInt32()
            var _20: Int32?
            _20 = reader.readInt32()
            var _21: Int32?
            _21 = reader.readInt32()
            var _22: Int32?
            _22 = reader.readInt32()
            var _23: Int32?
            _23 = reader.readInt32()
            var _24: Int32?
            _24 = reader.readInt32()
            var _25: Int32?
            if Int(_1!) & Int(1 << 0) != 0 {_25 = reader.readInt32() }
            var _26: Int32?
            _26 = reader.readInt32()
            var _27: Int32?
            _27 = reader.readInt32()
            var _28: Int32?
            _28 = reader.readInt32()
            var _29: Int32?
            _29 = reader.readInt32()
            var _30: String?
            _30 = parseString(reader)
            var _31: String?
            if Int(_1!) & Int(1 << 7) != 0 {_31 = parseString(reader) }
            var _32: String?
            if Int(_1!) & Int(1 << 9) != 0 {_32 = parseString(reader) }
            var _33: String?
            if Int(_1!) & Int(1 << 10) != 0 {_33 = parseString(reader) }
            var _34: String?
            if Int(_1!) & Int(1 << 11) != 0 {_34 = parseString(reader) }
            var _35: String?
            if Int(_1!) & Int(1 << 12) != 0 {_35 = parseString(reader) }
            var _36: Int32?
            _36 = reader.readInt32()
            var _37: Int32?
            _37 = reader.readInt32()
            var _38: Int32?
            _38 = reader.readInt32()
            var _39: String?
            if Int(_1!) & Int(1 << 2) != 0 {_39 = parseString(reader) }
            var _40: Int32?
            if Int(_1!) & Int(1 << 2) != 0 {_40 = reader.readInt32() }
            var _41: Int32?
            if Int(_1!) & Int(1 << 2) != 0 {_41 = reader.readInt32() }
            var _42: Api.Reaction?
            if Int(_1!) & Int(1 << 15) != 0 {if let signature = reader.readInt32() {
                _42 = Api.parse(reader, signature: signature) as? Api.Reaction
            } }
            var _43: String?
            if Int(_1!) & Int(1 << 16) != 0 {_43 = parseString(reader) }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            let _c9 = _9 != nil
            let _c10 = _10 != nil
            let _c11 = _11 != nil
            let _c12 = _12 != nil
            let _c13 = _13 != nil
            let _c14 = _14 != nil
            let _c15 = _15 != nil
            let _c16 = _16 != nil
            let _c17 = _17 != nil
            let _c18 = _18 != nil
            let _c19 = _19 != nil
            let _c20 = _20 != nil
            let _c21 = _21 != nil
            let _c22 = _22 != nil
            let _c23 = _23 != nil
            let _c24 = _24 != nil
            let _c25 = (Int(_1!) & Int(1 << 0) == 0) || _25 != nil
            let _c26 = _26 != nil
            let _c27 = _27 != nil
            let _c28 = _28 != nil
            let _c29 = _29 != nil
            let _c30 = _30 != nil
            let _c31 = (Int(_1!) & Int(1 << 7) == 0) || _31 != nil
            let _c32 = (Int(_1!) & Int(1 << 9) == 0) || _32 != nil
            let _c33 = (Int(_1!) & Int(1 << 10) == 0) || _33 != nil
            let _c34 = (Int(_1!) & Int(1 << 11) == 0) || _34 != nil
            let _c35 = (Int(_1!) & Int(1 << 12) == 0) || _35 != nil
            let _c36 = _36 != nil
            let _c37 = _37 != nil
            let _c38 = _38 != nil
            let _c39 = (Int(_1!) & Int(1 << 2) == 0) || _39 != nil
            let _c40 = (Int(_1!) & Int(1 << 2) == 0) || _40 != nil
            let _c41 = (Int(_1!) & Int(1 << 2) == 0) || _41 != nil
            let _c42 = (Int(_1!) & Int(1 << 15) == 0) || _42 != nil
            let _c43 = (Int(_1!) & Int(1 << 16) == 0) || _43 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 && _c11 && _c12 && _c13 && _c14 && _c15 && _c16 && _c17 && _c18 && _c19 && _c20 && _c21 && _c22 && _c23 && _c24 && _c25 && _c26 && _c27 && _c28 && _c29 && _c30 && _c31 && _c32 && _c33 && _c34 && _c35 && _c36 && _c37 && _c38 && _c39 && _c40 && _c41 && _c42 && _c43 {
                return Api.Config.config(flags: _1!, date: _2!, expires: _3!, testMode: _4!, thisDc: _5!, dcOptions: _6!, dcTxtDomainName: _7!, chatSizeMax: _8!, megagroupSizeMax: _9!, forwardedCountMax: _10!, onlineUpdatePeriodMs: _11!, offlineBlurTimeoutMs: _12!, offlineIdleTimeoutMs: _13!, onlineCloudTimeoutMs: _14!, notifyCloudDelayMs: _15!, notifyDefaultDelayMs: _16!, pushChatPeriodMs: _17!, pushChatLimit: _18!, editTimeLimit: _19!, revokeTimeLimit: _20!, revokePmTimeLimit: _21!, ratingEDecay: _22!, stickersRecentLimit: _23!, channelsReadMediaPeriod: _24!, tmpSessions: _25, callReceiveTimeoutMs: _26!, callRingTimeoutMs: _27!, callConnectTimeoutMs: _28!, callPacketTimeoutMs: _29!, meUrlPrefix: _30!, autoupdateUrlPrefix: _31, gifSearchUsername: _32, venueSearchUsername: _33, imgSearchUsername: _34, staticMapsProvider: _35, captionLengthMax: _36!, messageLengthMax: _37!, webfileDcId: _38!, suggestedLangCode: _39, langPackVersion: _40, baseLangPackVersion: _41, reactionsDefault: _42, autologinToken: _43)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ConnectedBot: TypeConstructorDescription {
        case connectedBot(flags: Int32, botId: Int64, recipients: Api.BusinessBotRecipients, rights: Api.BusinessBotRights)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .connectedBot(let flags, let botId, let recipients, let rights):
                    if boxed {
                        buffer.appendInt32(-849058964)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(botId, buffer: buffer, boxed: false)
                    recipients.serialize(buffer, true)
                    rights.serialize(buffer, true)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .connectedBot(let flags, let botId, let recipients, let rights):
                return ("connectedBot", [("flags", flags as Any), ("botId", botId as Any), ("recipients", recipients as Any), ("rights", rights as Any)])
    }
    }
    
        public static func parse_connectedBot(_ reader: BufferReader) -> ConnectedBot? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Api.BusinessBotRecipients?
            if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.BusinessBotRecipients
            }
            var _4: Api.BusinessBotRights?
            if let signature = reader.readInt32() {
                _4 = Api.parse(reader, signature: signature) as? Api.BusinessBotRights
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            if _c1 && _c2 && _c3 && _c4 {
                return Api.ConnectedBot.connectedBot(flags: _1!, botId: _2!, recipients: _3!, rights: _4!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ConnectedBotStarRef: TypeConstructorDescription {
        case connectedBotStarRef(flags: Int32, url: String, date: Int32, botId: Int64, commissionPermille: Int32, durationMonths: Int32?, participants: Int64, revenue: Int64)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .connectedBotStarRef(let flags, let url, let date, let botId, let commissionPermille, let durationMonths, let participants, let revenue):
                    if boxed {
                        buffer.appendInt32(429997937)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeString(url, buffer: buffer, boxed: false)
                    serializeInt32(date, buffer: buffer, boxed: false)
                    serializeInt64(botId, buffer: buffer, boxed: false)
                    serializeInt32(commissionPermille, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 0) != 0 {serializeInt32(durationMonths!, buffer: buffer, boxed: false)}
                    serializeInt64(participants, buffer: buffer, boxed: false)
                    serializeInt64(revenue, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .connectedBotStarRef(let flags, let url, let date, let botId, let commissionPermille, let durationMonths, let participants, let revenue):
                return ("connectedBotStarRef", [("flags", flags as Any), ("url", url as Any), ("date", date as Any), ("botId", botId as Any), ("commissionPermille", commissionPermille as Any), ("durationMonths", durationMonths as Any), ("participants", participants as Any), ("revenue", revenue as Any)])
    }
    }
    
        public static func parse_connectedBotStarRef(_ reader: BufferReader) -> ConnectedBotStarRef? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: String?
            _2 = parseString(reader)
            var _3: Int32?
            _3 = reader.readInt32()
            var _4: Int64?
            _4 = reader.readInt64()
            var _5: Int32?
            _5 = reader.readInt32()
            var _6: Int32?
            if Int(_1!) & Int(1 << 0) != 0 {_6 = reader.readInt32() }
            var _7: Int64?
            _7 = reader.readInt64()
            var _8: Int64?
            _8 = reader.readInt64()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = (Int(_1!) & Int(1 << 0) == 0) || _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 {
                return Api.ConnectedBotStarRef.connectedBotStarRef(flags: _1!, url: _2!, date: _3!, botId: _4!, commissionPermille: _5!, durationMonths: _6, participants: _7!, revenue: _8!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum Contact: TypeConstructorDescription {
        case contact(userId: Int64, mutual: Api.Bool)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .contact(let userId, let mutual):
                    if boxed {
                        buffer.appendInt32(341499403)
                    }
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    mutual.serialize(buffer, true)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .contact(let userId, let mutual):
                return ("contact", [("userId", userId as Any), ("mutual", mutual as Any)])
    }
    }
    
        public static func parse_contact(_ reader: BufferReader) -> Contact? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: Api.Bool?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.Bool
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.Contact.contact(userId: _1!, mutual: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ContactBirthday: TypeConstructorDescription {
        case contactBirthday(contactId: Int64, birthday: Api.Birthday)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .contactBirthday(let contactId, let birthday):
                    if boxed {
                        buffer.appendInt32(496600883)
                    }
                    serializeInt64(contactId, buffer: buffer, boxed: false)
                    birthday.serialize(buffer, true)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .contactBirthday(let contactId, let birthday):
                return ("contactBirthday", [("contactId", contactId as Any), ("birthday", birthday as Any)])
    }
    }
    
        public static func parse_contactBirthday(_ reader: BufferReader) -> ContactBirthday? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: Api.Birthday?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.Birthday
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.ContactBirthday.contactBirthday(contactId: _1!, birthday: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum ContactStatus: TypeConstructorDescription {
        case contactStatus(userId: Int64, status: Api.UserStatus)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .contactStatus(let userId, let status):
                    if boxed {
                        buffer.appendInt32(383348795)
                    }
                    serializeInt64(userId, buffer: buffer, boxed: false)
                    status.serialize(buffer, true)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .contactStatus(let userId, let status):
                return ("contactStatus", [("userId", userId as Any), ("status", status as Any)])
    }
    }
    
        public static func parse_contactStatus(_ reader: BufferReader) -> ContactStatus? {
            var _1: Int64?
            _1 = reader.readInt64()
            var _2: Api.UserStatus?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.UserStatus
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.ContactStatus.contactStatus(userId: _1!, status: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum DataJSON: TypeConstructorDescription {
        case dataJSON(data: String)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .dataJSON(let data):
                    if boxed {
                        buffer.appendInt32(2104790276)
                    }
                    serializeString(data, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .dataJSON(let data):
                return ("dataJSON", [("data", data as Any)])
    }
    }
    
        public static func parse_dataJSON(_ reader: BufferReader) -> DataJSON? {
            var _1: String?
            _1 = parseString(reader)
            let _c1 = _1 != nil
            if _c1 {
                return Api.DataJSON.dataJSON(data: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum DcOption: TypeConstructorDescription {
        case dcOption(flags: Int32, id: Int32, ipAddress: String, port: Int32, secret: Buffer?)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .dcOption(let flags, let id, let ipAddress, let port, let secret):
                    if boxed {
                        buffer.appendInt32(414687501)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt32(id, buffer: buffer, boxed: false)
                    serializeString(ipAddress, buffer: buffer, boxed: false)
                    serializeInt32(port, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 10) != 0 {serializeBytes(secret!, buffer: buffer, boxed: false)}
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .dcOption(let flags, let id, let ipAddress, let port, let secret):
                return ("dcOption", [("flags", flags as Any), ("id", id as Any), ("ipAddress", ipAddress as Any), ("port", port as Any), ("secret", secret as Any)])
    }
    }
    
        public static func parse_dcOption(_ reader: BufferReader) -> DcOption? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: String?
            _3 = parseString(reader)
            var _4: Int32?
            _4 = reader.readInt32()
            var _5: Buffer?
            if Int(_1!) & Int(1 << 10) != 0 {_5 = parseBytes(reader) }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = (Int(_1!) & Int(1 << 10) == 0) || _5 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 {
                return Api.DcOption.dcOption(flags: _1!, id: _2!, ipAddress: _3!, port: _4!, secret: _5)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum DefaultHistoryTTL: TypeConstructorDescription {
        case defaultHistoryTTL(period: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .defaultHistoryTTL(let period):
                    if boxed {
                        buffer.appendInt32(1135897376)
                    }
                    serializeInt32(period, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .defaultHistoryTTL(let period):
                return ("defaultHistoryTTL", [("period", period as Any)])
    }
    }
    
        public static func parse_defaultHistoryTTL(_ reader: BufferReader) -> DefaultHistoryTTL? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.DefaultHistoryTTL.defaultHistoryTTL(period: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    indirect enum Dialog: TypeConstructorDescription {
        case dialog(flags: Int32, peer: Api.Peer, topMessage: Int32, readInboxMaxId: Int32, readOutboxMaxId: Int32, unreadCount: Int32, unreadMentionsCount: Int32, unreadReactionsCount: Int32, notifySettings: Api.PeerNotifySettings, pts: Int32?, draft: Api.DraftMessage?, folderId: Int32?, ttlPeriod: Int32?)
        case dialogFolder(flags: Int32, folder: Api.Folder, peer: Api.Peer, topMessage: Int32, unreadMutedPeersCount: Int32, unreadUnmutedPeersCount: Int32, unreadMutedMessagesCount: Int32, unreadUnmutedMessagesCount: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .dialog(let flags, let peer, let topMessage, let readInboxMaxId, let readOutboxMaxId, let unreadCount, let unreadMentionsCount, let unreadReactionsCount, let notifySettings, let pts, let draft, let folderId, let ttlPeriod):
                    if boxed {
                        buffer.appendInt32(-712374074)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    peer.serialize(buffer, true)
                    serializeInt32(topMessage, buffer: buffer, boxed: false)
                    serializeInt32(readInboxMaxId, buffer: buffer, boxed: false)
                    serializeInt32(readOutboxMaxId, buffer: buffer, boxed: false)
                    serializeInt32(unreadCount, buffer: buffer, boxed: false)
                    serializeInt32(unreadMentionsCount, buffer: buffer, boxed: false)
                    serializeInt32(unreadReactionsCount, buffer: buffer, boxed: false)
                    notifySettings.serialize(buffer, true)
                    if Int(flags) & Int(1 << 0) != 0 {serializeInt32(pts!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 1) != 0 {draft!.serialize(buffer, true)}
                    if Int(flags) & Int(1 << 4) != 0 {serializeInt32(folderId!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 5) != 0 {serializeInt32(ttlPeriod!, buffer: buffer, boxed: false)}
                    break
                case .dialogFolder(let flags, let folder, let peer, let topMessage, let unreadMutedPeersCount, let unreadUnmutedPeersCount, let unreadMutedMessagesCount, let unreadUnmutedMessagesCount):
                    if boxed {
                        buffer.appendInt32(1908216652)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    folder.serialize(buffer, true)
                    peer.serialize(buffer, true)
                    serializeInt32(topMessage, buffer: buffer, boxed: false)
                    serializeInt32(unreadMutedPeersCount, buffer: buffer, boxed: false)
                    serializeInt32(unreadUnmutedPeersCount, buffer: buffer, boxed: false)
                    serializeInt32(unreadMutedMessagesCount, buffer: buffer, boxed: false)
                    serializeInt32(unreadUnmutedMessagesCount, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .dialog(let flags, let peer, let topMessage, let readInboxMaxId, let readOutboxMaxId, let unreadCount, let unreadMentionsCount, let unreadReactionsCount, let notifySettings, let pts, let draft, let folderId, let ttlPeriod):
                return ("dialog", [("flags", flags as Any), ("peer", peer as Any), ("topMessage", topMessage as Any), ("readInboxMaxId", readInboxMaxId as Any), ("readOutboxMaxId", readOutboxMaxId as Any), ("unreadCount", unreadCount as Any), ("unreadMentionsCount", unreadMentionsCount as Any), ("unreadReactionsCount", unreadReactionsCount as Any), ("notifySettings", notifySettings as Any), ("pts", pts as Any), ("draft", draft as Any), ("folderId", folderId as Any), ("ttlPeriod", ttlPeriod as Any)])
                case .dialogFolder(let flags, let folder, let peer, let topMessage, let unreadMutedPeersCount, let unreadUnmutedPeersCount, let unreadMutedMessagesCount, let unreadUnmutedMessagesCount):
                return ("dialogFolder", [("flags", flags as Any), ("folder", folder as Any), ("peer", peer as Any), ("topMessage", topMessage as Any), ("unreadMutedPeersCount", unreadMutedPeersCount as Any), ("unreadUnmutedPeersCount", unreadUnmutedPeersCount as Any), ("unreadMutedMessagesCount", unreadMutedMessagesCount as Any), ("unreadUnmutedMessagesCount", unreadUnmutedMessagesCount as Any)])
    }
    }
    
        public static func parse_dialog(_ reader: BufferReader) -> Dialog? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Api.Peer?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.Peer
            }
            var _3: Int32?
            _3 = reader.readInt32()
            var _4: Int32?
            _4 = reader.readInt32()
            var _5: Int32?
            _5 = reader.readInt32()
            var _6: Int32?
            _6 = reader.readInt32()
            var _7: Int32?
            _7 = reader.readInt32()
            var _8: Int32?
            _8 = reader.readInt32()
            var _9: Api.PeerNotifySettings?
            if let signature = reader.readInt32() {
                _9 = Api.parse(reader, signature: signature) as? Api.PeerNotifySettings
            }
            var _10: Int32?
            if Int(_1!) & Int(1 << 0) != 0 {_10 = reader.readInt32() }
            var _11: Api.DraftMessage?
            if Int(_1!) & Int(1 << 1) != 0 {if let signature = reader.readInt32() {
                _11 = Api.parse(reader, signature: signature) as? Api.DraftMessage
            } }
            var _12: Int32?
            if Int(_1!) & Int(1 << 4) != 0 {_12 = reader.readInt32() }
            var _13: Int32?
            if Int(_1!) & Int(1 << 5) != 0 {_13 = reader.readInt32() }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            let _c9 = _9 != nil
            let _c10 = (Int(_1!) & Int(1 << 0) == 0) || _10 != nil
            let _c11 = (Int(_1!) & Int(1 << 1) == 0) || _11 != nil
            let _c12 = (Int(_1!) & Int(1 << 4) == 0) || _12 != nil
            let _c13 = (Int(_1!) & Int(1 << 5) == 0) || _13 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 && _c11 && _c12 && _c13 {
                return Api.Dialog.dialog(flags: _1!, peer: _2!, topMessage: _3!, readInboxMaxId: _4!, readOutboxMaxId: _5!, unreadCount: _6!, unreadMentionsCount: _7!, unreadReactionsCount: _8!, notifySettings: _9!, pts: _10, draft: _11, folderId: _12, ttlPeriod: _13)
            }
            else {
                return nil
            }
        }
        public static func parse_dialogFolder(_ reader: BufferReader) -> Dialog? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Api.Folder?
            if let signature = reader.readInt32() {
                _2 = Api.parse(reader, signature: signature) as? Api.Folder
            }
            var _3: Api.Peer?
            if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.Peer
            }
            var _4: Int32?
            _4 = reader.readInt32()
            var _5: Int32?
            _5 = reader.readInt32()
            var _6: Int32?
            _6 = reader.readInt32()
            var _7: Int32?
            _7 = reader.readInt32()
            var _8: Int32?
            _8 = reader.readInt32()
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 {
                return Api.Dialog.dialogFolder(flags: _1!, folder: _2!, peer: _3!, topMessage: _4!, unreadMutedPeersCount: _5!, unreadUnmutedPeersCount: _6!, unreadMutedMessagesCount: _7!, unreadUnmutedMessagesCount: _8!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum DialogFilter: TypeConstructorDescription {
        case dialogFilter(flags: Int32, id: Int32, title: Api.TextWithEntities, emoticon: String?, color: Int32?, pinnedPeers: [Api.InputPeer], includePeers: [Api.InputPeer], excludePeers: [Api.InputPeer])
        case dialogFilterChatlist(flags: Int32, id: Int32, title: Api.TextWithEntities, emoticon: String?, color: Int32?, pinnedPeers: [Api.InputPeer], includePeers: [Api.InputPeer])
        case dialogFilterDefault
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .dialogFilter(let flags, let id, let title, let emoticon, let color, let pinnedPeers, let includePeers, let excludePeers):
                    if boxed {
                        buffer.appendInt32(-1438177711)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt32(id, buffer: buffer, boxed: false)
                    title.serialize(buffer, true)
                    if Int(flags) & Int(1 << 25) != 0 {serializeString(emoticon!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 27) != 0 {serializeInt32(color!, buffer: buffer, boxed: false)}
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(pinnedPeers.count))
                    for item in pinnedPeers {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(includePeers.count))
                    for item in includePeers {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(excludePeers.count))
                    for item in excludePeers {
                        item.serialize(buffer, true)
                    }
                    break
                case .dialogFilterChatlist(let flags, let id, let title, let emoticon, let color, let pinnedPeers, let includePeers):
                    if boxed {
                        buffer.appendInt32(-1772913705)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt32(id, buffer: buffer, boxed: false)
                    title.serialize(buffer, true)
                    if Int(flags) & Int(1 << 25) != 0 {serializeString(emoticon!, buffer: buffer, boxed: false)}
                    if Int(flags) & Int(1 << 27) != 0 {serializeInt32(color!, buffer: buffer, boxed: false)}
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(pinnedPeers.count))
                    for item in pinnedPeers {
                        item.serialize(buffer, true)
                    }
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(includePeers.count))
                    for item in includePeers {
                        item.serialize(buffer, true)
                    }
                    break
                case .dialogFilterDefault:
                    if boxed {
                        buffer.appendInt32(909284270)
                    }
                    
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .dialogFilter(let flags, let id, let title, let emoticon, let color, let pinnedPeers, let includePeers, let excludePeers):
                return ("dialogFilter", [("flags", flags as Any), ("id", id as Any), ("title", title as Any), ("emoticon", emoticon as Any), ("color", color as Any), ("pinnedPeers", pinnedPeers as Any), ("includePeers", includePeers as Any), ("excludePeers", excludePeers as Any)])
                case .dialogFilterChatlist(let flags, let id, let title, let emoticon, let color, let pinnedPeers, let includePeers):
                return ("dialogFilterChatlist", [("flags", flags as Any), ("id", id as Any), ("title", title as Any), ("emoticon", emoticon as Any), ("color", color as Any), ("pinnedPeers", pinnedPeers as Any), ("includePeers", includePeers as Any)])
                case .dialogFilterDefault:
                return ("dialogFilterDefault", [])
    }
    }
    
        public static func parse_dialogFilter(_ reader: BufferReader) -> DialogFilter? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: Api.TextWithEntities?
            if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.TextWithEntities
            }
            var _4: String?
            if Int(_1!) & Int(1 << 25) != 0 {_4 = parseString(reader) }
            var _5: Int32?
            if Int(_1!) & Int(1 << 27) != 0 {_5 = reader.readInt32() }
            var _6: [Api.InputPeer]?
            if let _ = reader.readInt32() {
                _6 = Api.parseVector(reader, elementSignature: 0, elementType: Api.InputPeer.self)
            }
            var _7: [Api.InputPeer]?
            if let _ = reader.readInt32() {
                _7 = Api.parseVector(reader, elementSignature: 0, elementType: Api.InputPeer.self)
            }
            var _8: [Api.InputPeer]?
            if let _ = reader.readInt32() {
                _8 = Api.parseVector(reader, elementSignature: 0, elementType: Api.InputPeer.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 25) == 0) || _4 != nil
            let _c5 = (Int(_1!) & Int(1 << 27) == 0) || _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = _8 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 {
                return Api.DialogFilter.dialogFilter(flags: _1!, id: _2!, title: _3!, emoticon: _4, color: _5, pinnedPeers: _6!, includePeers: _7!, excludePeers: _8!)
            }
            else {
                return nil
            }
        }
        public static func parse_dialogFilterChatlist(_ reader: BufferReader) -> DialogFilter? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int32?
            _2 = reader.readInt32()
            var _3: Api.TextWithEntities?
            if let signature = reader.readInt32() {
                _3 = Api.parse(reader, signature: signature) as? Api.TextWithEntities
            }
            var _4: String?
            if Int(_1!) & Int(1 << 25) != 0 {_4 = parseString(reader) }
            var _5: Int32?
            if Int(_1!) & Int(1 << 27) != 0 {_5 = reader.readInt32() }
            var _6: [Api.InputPeer]?
            if let _ = reader.readInt32() {
                _6 = Api.parseVector(reader, elementSignature: 0, elementType: Api.InputPeer.self)
            }
            var _7: [Api.InputPeer]?
            if let _ = reader.readInt32() {
                _7 = Api.parseVector(reader, elementSignature: 0, elementType: Api.InputPeer.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = (Int(_1!) & Int(1 << 25) == 0) || _4 != nil
            let _c5 = (Int(_1!) & Int(1 << 27) == 0) || _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 {
                return Api.DialogFilter.dialogFilterChatlist(flags: _1!, id: _2!, title: _3!, emoticon: _4, color: _5, pinnedPeers: _6!, includePeers: _7!)
            }
            else {
                return nil
            }
        }
        public static func parse_dialogFilterDefault(_ reader: BufferReader) -> DialogFilter? {
            return Api.DialogFilter.dialogFilterDefault
        }
    
    }
}
public extension Api {
    enum DialogFilterSuggested: TypeConstructorDescription {
        case dialogFilterSuggested(filter: Api.DialogFilter, description: String)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .dialogFilterSuggested(let filter, let description):
                    if boxed {
                        buffer.appendInt32(2004110666)
                    }
                    filter.serialize(buffer, true)
                    serializeString(description, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .dialogFilterSuggested(let filter, let description):
                return ("dialogFilterSuggested", [("filter", filter as Any), ("description", description as Any)])
    }
    }
    
        public static func parse_dialogFilterSuggested(_ reader: BufferReader) -> DialogFilterSuggested? {
            var _1: Api.DialogFilter?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.DialogFilter
            }
            var _2: String?
            _2 = parseString(reader)
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            if _c1 && _c2 {
                return Api.DialogFilterSuggested.dialogFilterSuggested(filter: _1!, description: _2!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum DialogPeer: TypeConstructorDescription {
        case dialogPeer(peer: Api.Peer)
        case dialogPeerFolder(folderId: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .dialogPeer(let peer):
                    if boxed {
                        buffer.appendInt32(-445792507)
                    }
                    peer.serialize(buffer, true)
                    break
                case .dialogPeerFolder(let folderId):
                    if boxed {
                        buffer.appendInt32(1363483106)
                    }
                    serializeInt32(folderId, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .dialogPeer(let peer):
                return ("dialogPeer", [("peer", peer as Any)])
                case .dialogPeerFolder(let folderId):
                return ("dialogPeerFolder", [("folderId", folderId as Any)])
    }
    }
    
        public static func parse_dialogPeer(_ reader: BufferReader) -> DialogPeer? {
            var _1: Api.Peer?
            if let signature = reader.readInt32() {
                _1 = Api.parse(reader, signature: signature) as? Api.Peer
            }
            let _c1 = _1 != nil
            if _c1 {
                return Api.DialogPeer.dialogPeer(peer: _1!)
            }
            else {
                return nil
            }
        }
        public static func parse_dialogPeerFolder(_ reader: BufferReader) -> DialogPeer? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.DialogPeer.dialogPeerFolder(folderId: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum DisallowedGiftsSettings: TypeConstructorDescription {
        case disallowedGiftsSettings(flags: Int32)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .disallowedGiftsSettings(let flags):
                    if boxed {
                        buffer.appendInt32(1911715524)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .disallowedGiftsSettings(let flags):
                return ("disallowedGiftsSettings", [("flags", flags as Any)])
    }
    }
    
        public static func parse_disallowedGiftsSettings(_ reader: BufferReader) -> DisallowedGiftsSettings? {
            var _1: Int32?
            _1 = reader.readInt32()
            let _c1 = _1 != nil
            if _c1 {
                return Api.DisallowedGiftsSettings.disallowedGiftsSettings(flags: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
public extension Api {
    enum Document: TypeConstructorDescription {
        case document(flags: Int32, id: Int64, accessHash: Int64, fileReference: Buffer, date: Int32, mimeType: String, size: Int64, thumbs: [Api.PhotoSize]?, videoThumbs: [Api.VideoSize]?, dcId: Int32, attributes: [Api.DocumentAttribute])
        case documentEmpty(id: Int64)
    
    public func serialize(_ buffer: Buffer, _ boxed: Swift.Bool) {
    switch self {
                case .document(let flags, let id, let accessHash, let fileReference, let date, let mimeType, let size, let thumbs, let videoThumbs, let dcId, let attributes):
                    if boxed {
                        buffer.appendInt32(-1881881384)
                    }
                    serializeInt32(flags, buffer: buffer, boxed: false)
                    serializeInt64(id, buffer: buffer, boxed: false)
                    serializeInt64(accessHash, buffer: buffer, boxed: false)
                    serializeBytes(fileReference, buffer: buffer, boxed: false)
                    serializeInt32(date, buffer: buffer, boxed: false)
                    serializeString(mimeType, buffer: buffer, boxed: false)
                    serializeInt64(size, buffer: buffer, boxed: false)
                    if Int(flags) & Int(1 << 0) != 0 {buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(thumbs!.count))
                    for item in thumbs! {
                        item.serialize(buffer, true)
                    }}
                    if Int(flags) & Int(1 << 1) != 0 {buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(videoThumbs!.count))
                    for item in videoThumbs! {
                        item.serialize(buffer, true)
                    }}
                    serializeInt32(dcId, buffer: buffer, boxed: false)
                    buffer.appendInt32(481674261)
                    buffer.appendInt32(Int32(attributes.count))
                    for item in attributes {
                        item.serialize(buffer, true)
                    }
                    break
                case .documentEmpty(let id):
                    if boxed {
                        buffer.appendInt32(922273905)
                    }
                    serializeInt64(id, buffer: buffer, boxed: false)
                    break
    }
    }
    
    public func descriptionFields() -> (String, [(String, Any)]) {
        switch self {
                case .document(let flags, let id, let accessHash, let fileReference, let date, let mimeType, let size, let thumbs, let videoThumbs, let dcId, let attributes):
                return ("document", [("flags", flags as Any), ("id", id as Any), ("accessHash", accessHash as Any), ("fileReference", fileReference as Any), ("date", date as Any), ("mimeType", mimeType as Any), ("size", size as Any), ("thumbs", thumbs as Any), ("videoThumbs", videoThumbs as Any), ("dcId", dcId as Any), ("attributes", attributes as Any)])
                case .documentEmpty(let id):
                return ("documentEmpty", [("id", id as Any)])
    }
    }
    
        public static func parse_document(_ reader: BufferReader) -> Document? {
            var _1: Int32?
            _1 = reader.readInt32()
            var _2: Int64?
            _2 = reader.readInt64()
            var _3: Int64?
            _3 = reader.readInt64()
            var _4: Buffer?
            _4 = parseBytes(reader)
            var _5: Int32?
            _5 = reader.readInt32()
            var _6: String?
            _6 = parseString(reader)
            var _7: Int64?
            _7 = reader.readInt64()
            var _8: [Api.PhotoSize]?
            if Int(_1!) & Int(1 << 0) != 0 {if let _ = reader.readInt32() {
                _8 = Api.parseVector(reader, elementSignature: 0, elementType: Api.PhotoSize.self)
            } }
            var _9: [Api.VideoSize]?
            if Int(_1!) & Int(1 << 1) != 0 {if let _ = reader.readInt32() {
                _9 = Api.parseVector(reader, elementSignature: 0, elementType: Api.VideoSize.self)
            } }
            var _10: Int32?
            _10 = reader.readInt32()
            var _11: [Api.DocumentAttribute]?
            if let _ = reader.readInt32() {
                _11 = Api.parseVector(reader, elementSignature: 0, elementType: Api.DocumentAttribute.self)
            }
            let _c1 = _1 != nil
            let _c2 = _2 != nil
            let _c3 = _3 != nil
            let _c4 = _4 != nil
            let _c5 = _5 != nil
            let _c6 = _6 != nil
            let _c7 = _7 != nil
            let _c8 = (Int(_1!) & Int(1 << 0) == 0) || _8 != nil
            let _c9 = (Int(_1!) & Int(1 << 1) == 0) || _9 != nil
            let _c10 = _10 != nil
            let _c11 = _11 != nil
            if _c1 && _c2 && _c3 && _c4 && _c5 && _c6 && _c7 && _c8 && _c9 && _c10 && _c11 {
                return Api.Document.document(flags: _1!, id: _2!, accessHash: _3!, fileReference: _4!, date: _5!, mimeType: _6!, size: _7!, thumbs: _8, videoThumbs: _9, dcId: _10!, attributes: _11!)
            }
            else {
                return nil
            }
        }
        public static func parse_documentEmpty(_ reader: BufferReader) -> Document? {
            var _1: Int64?
            _1 = reader.readInt64()
            let _c1 = _1 != nil
            if _c1 {
                return Api.Document.documentEmpty(id: _1!)
            }
            else {
                return nil
            }
        }
    
    }
}
