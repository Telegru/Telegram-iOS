import Foundation

struct ServiceIds {
    var users: [Int64]
    var bots: [Int64]
    var channels: [Int64]
    var chats: [Int64]
    
    public static let `default` = ServiceIds(
        users: [
            777000, 333000, 4240000, 4244000, 4245000, 4246000,
            410000, 420000, 431000, 431415000, 434000, 4243000,
            439000, 449000, 450000, 452000, 454000, 4254000,
            455000, 460000, 470000, 479000, 796000, 482000,
            490000, 496000, 497000, 498000, 4298000,
        ],
        bots: [8163923137, 7723572448, 7719436508],
        channels: [2555089412],
        chats: []
    )
    }
