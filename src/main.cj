package riscv

import net.http.*
import std.log.*
import std.collection.*
import std.convert.*
import encoding.json.*
import std.format.*
import std.fs.*
import std.process.*
import riscv.cpu.CpuService
import riscv.util.Util

main() {
    // println("hello world")
    println("http://localhost:8888")

    let server = ServerBuilder()
                    .addr("127.0.0.1")
                    .port(8888)
                    .distributor(RequestDistributor())
                    .build()
    // 1 注册 handler
    // server.distributor.register("/ws", WebSocketHandler())
    // server.distributor.register("/**", PageHandler())
    // server.logger.level = OFF
    server.serve()
}

// distributor
public class RequestDistributor <: HttpRequestDistributor {
    let map = HashMap<String, HttpRequestHandler>()
    public func register(path: String, handler: HttpRequestHandler): Unit {
        map.put(path, handler)
    }

    public func distribute(path: String): HttpRequestHandler {
        println("path: ${path}")
        if (path == "/ws") {
            return WebSocketHandler()
        }
        let file = Path("${Process.current.workingDirectory}/web/${path}")
        if (exists(file)) {
            return PageHandler()
        }
        return NotFoundHandler()
    }
}
// http请求
public class HttpHandler <: HttpRequestHandler {
    public func handle(ctx: HttpContext): Unit {
        let url = ctx.request.url
        if (url.path.contains(".")) {
            ctx.responseBuilder.body('its not http request!')
            return
        }
        ctx.responseBuilder.body('request success')
    }
}
// websocket请求
public class WebSocketHandler <: HttpRequestHandler {
    public func handle(ctx: HttpContext): Unit {
        let url = ctx.request.url
        if (url.path.contains(".")) {
            ctx.responseBuilder.body('its not http request!')
            return
        }
        ctx.request.headers.del('sec-websocket-extensions')
        // 完成 websocket 握手，获取 websocket 实例
        let websocketServer = WebSocket.upgradeFromServer(ctx)
        while (true) {
            CpuService.receiveMsg(websocketServer)
        }
    }
}
// 返回一个简单的 HTML 页面
public class PageHandler <: HttpRequestHandler {
    public func handle(ctx: HttpContext): Unit {
        let url = ctx.request.url
        if (!url.path.contains(".")) {
            ctx.responseBuilder.body('its not file request!')
        }
        let fileStr = File.readFrom("${Process.current.workingDirectory}/web/${url.path}")
        ctx.responseBuilder.body(fileStr)
    }
}
