package riscv.ws

import net.http.*
import std.collection.*

public class WebSocketService {
    public static let wslist: ArrayList<WebSocket> = ArrayList<WebSocket>()

    public static func receiverMsg(ws: WebSocket): String {
        wslist.clear()
        wslist.add(ws)
        // 3 消息收发
        // 收 hello
        let data = ArrayList<UInt8>()
        var frame = ws.read()
        while(true) {
            match(frame.frameType) {
                case ContinuationWebFrame =>
                    data.add(all: frame.payload)
                    if (frame.fin) {
                        break
                    }
                case TextWebFrame | BinaryWebFrame =>
                    if (!data.isEmpty()) {
                        throw Exception("invalid frame")
                    }
                    data.add(all: frame.payload)
                    if (frame.fin) {
                        break
                    }
                case CloseWebFrame =>
                    ws.write(CloseWebFrame, frame.payload)
                    break
                case PingWebFrame =>
                    ws.writePongFrame(frame.payload)
                case _ => ()
            }
            frame = ws.read()
        }
        println("data: ${String.fromUtf8(data.toArray())}")
        // // 发 4097 个 a
        // websocketServer.write(TextWebFrame, Array<UInt8>(4097, item: 97))

        // // 4 关闭 websocket，
        // // 收发 CloseFrame
        // let websocketFrame = websocketServer.read()
        // println("close frame type: ${websocketFrame.frameType}")   // CloseWebFrame
        // println("close frame payload: ${websocketFrame.payload}")     // 3, 232
        // websocketServer.write(CloseWebFrame, websocketFrame.payload)
        // // 关闭底层连接
        // websocketServer.closeConn()
        return String.fromUtf8(data.toArray())
    }

    public static func sendMsg(msg: String): Unit {
        println("send msg: ${msg}")
        for (ws in wslist) {
            ws.write(TextWebFrame, msg.toArray())
        }
    }
}