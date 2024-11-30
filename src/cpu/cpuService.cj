package riscv.cpu

import riscv.util.Util
import riscv.ws.WebSocketService

import net.http.{WebSocket}
import std.collection.HashMap

public class CpuService {
    
    private static var computer: Computer = Computer()

    // getData
    public static func sendMsg(cmd: String, msg: String) {
        let result = '{"cmd": "${cmd}", "msg": "${msg}"}'
        return WebSocketService.sendMsg(result)
    }

    public static func registerChange(arg1: Int64, arg2: Int64) {
        //x0寄存器永远是0，不会改变
        if (arg1 != 0) {
            sendMsg('register', '${arg1},${Util.to8XString(arg2)}')
        }
    }

    public static func memoryChange(arg1: Int64, arg2: Int64) {
        sendMsg('memory', '${arg1},${Util.to2XString(arg2)}')
        if ((arg1 + 1) % 4 == 0) {
            let val = computer.cpu.disassembly(arg1)
            sendMsg("comment",  "${((arg1 + 1) / 4 - 1)};${val}")
        }
    }

    // postData
    public static func receiveMsg(ws: WebSocket) {
        let data = WebSocketService.receiverMsg(ws)
        let map = Util.toList(data)
        var cmd = map[0]
        var msg = map[1]
        if (cmd.equalsIgnoreAsciiCase("pc")) {
            computer.start()
            sendMsg("pc", "${computer.ram.getEnd()},${computer.rom.getEnd()}")
            registerChange(computer.cpu.pc.index, computer.cpu.pc.getValue())
            // let size = computer.rom.getSize()
            // for (i in 0..size) {
            //     memoryChange(i, Int64(computer.rom.read(i)))
            // }
        } else if(cmd.equalsIgnoreAsciiCase("run")) {
            computer.cpu.run()
        } else if(cmd.equalsIgnoreAsciiCase("runstep")) {
            computer.cpu.runStep()
        } else if(cmd.equalsIgnoreAsciiCase("pause")) {
            computer.cpu.pause()
        } else if(cmd.equalsIgnoreAsciiCase("reset")) {
            computer.reset()
        } else if(cmd.equalsIgnoreAsciiCase("debug")) {
            computer.cpu.debug(msg)
        } else if(cmd.equalsIgnoreAsciiCase("write")) {
            computer.cpu.write(msg)
        } else if(cmd.equalsIgnoreAsciiCase("book")) {
            var pa = msg.split(",")
            var result = computer.cpu.translateCmd(pa[0], pa[1], pa[2], pa[3], pa[4])
            sendMsg("translate", result)
        } else if(cmd.equalsIgnoreAsciiCase("batchtranslate")) {
            var result = computer.cpu.translateText(msg)
            sendMsg("translate", result)
        } else if(cmd.equalsIgnoreAsciiCase("export")) {
            let args = msg.split(",")
            var rv = computer.cpu.export(args[0], args[1])
            sendMsg("translate", rv)
        } else if(cmd.equalsIgnoreAsciiCase("setvalue")) {
            let args = msg.split(",")
            computer.cpu.setValue(args[0], args[1])
        }
    }
}