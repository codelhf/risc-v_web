package riscv.cpu

// import riscv.cpu.instructions.*
import riscv.device.Device
import riscv.util.Util

import std.collection.{HashMap, ArrayList}
import std.sync.*
import std.regex.*

public class Cpu {

    public static let registerNames: Array<String> = [
        "zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7",
        "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
    ]

    public static let pcName: String = "pc"

    // 寄存器
    public var registers: ArrayList<Register>

    // PC寄存器
    public var pc: Register

    // 是否运行指令中
    public var _running: Bool

    public var addressMap: HashMap<String, Device>

    public var debugAddress: ArrayList<Int64>

    public init(addressMap: HashMap<String, Device>) {
        this.registers = ArrayList<Register>()
        for (i in 0..32) {
            var r = Register(i, "x${i}")
            r.name = registerNames[i]
            this.registers.append(r)
        }
        this.pc = Register(100, pcName)
        this._running = false
        this.addressMap = addressMap
        this.debugAddress = ArrayList<Int64>()
    }

    private func getMaxAddress(): Int64 {
        var maxAddress = 0
        for (device in addressMap.values()) {
            if (device.getEnd() > maxAddress) {
                maxAddress = device.getEnd()
            }
        }
        return maxAddress
    }

    // 模拟Cpu启动，清空寄存器，PC指向0
    public func start(pcStartValue: Int64) {
        for (register in registers) {
            register.clear()
        }
        pc.clear()
        pc.setValue(pcStartValue)
    }

    public func shutdown() {
        _running = false
    }

    public func pause() {
        _running = false
    }

    public func reset(pcStartValue: Int64) {
        _running = false
        //清空寄存器
        for (register in registers) {
            register.clear()
        }
        pc.clear() //PC寄存器指向0
        pc.setValue(pcStartValue)
    }

    // 运行
    public func run() {
        _running = true
        // 开启线程
        spawn { =>
            var count = 0
            var lastPC: Int64 = -1
            let maxAddress = getMaxAddress()
            while (_running && pc.getValue() < maxAddress) {
                if (debugAddress.contains(pc.getValue())) {
                    _running = false
                    break
                }
                //运行指令
                this.runInstruction()
                //通知前台寄存器发生了变化，只是为了前台显示
                CpuService.registerChange(pc.index, pc.getValue())
                if (pc.index == lastPC) {
                    sleep(1 * Duration.second)
                } else {
                    sleep(100 * Duration.millisecond)
                    count = count + 1
                    if (count > 200) {
                        count = 0
                        sleep(1 * Duration.second)
                    }
                }
                lastPC = pc.getValue()
            }
        }
    }

    // 单步运行
    public func runStep() {
        //运行指令
        this.runInstruction()
        //通知前台寄存器发生了变化，只是为了前台显示
        CpuService.registerChange(pc.index, pc.getValue())
    }

    private func runInstruction() {
        var insStr = fetchInstruction(pc.getValue()) //取指
        var ins = decodeInstruction(insStr) //译指
        ins.execute(this) //执行
        increatePC(ins)
    }

    public func disassembly(memPos: Int64): String {
        var insStr = fetchInstruction(memPos - 3) //取指
        var ins = decodeInstruction(insStr) //译指
        var comment = ins.toString()
        if (Util.isBlank(comment)) {
            comment += "${Rune(Util.binToInt(insStr[24..32]))}"
            comment += "${Rune(Util.binToInt(insStr[16..24]))}"
            comment += "${Rune(Util.binToInt(insStr[8..16]))}"
            comment += "${Rune(Util.binToInt(insStr[0..8]))}"
        }
        return comment
    }

    private func fetchInstruction(pos: Int64): String {
        var device = Device(0)
        var deviceStart = 0
        for (item in addressMap.values()) {
            if (pos >= item.getStart() && pos < item.getEnd()) {
                device = item
                deviceStart = pos - item.getStart()
            }
        }
        if (device.getSize() == 0) {
            return ""
        }
        let val1 = device.read(deviceStart)
        let val2 = device.read(deviceStart + 1)
        let val3 = device.read(deviceStart + 2)
        let val4 = device.read(deviceStart + 3)
        // 指令在内存中是大端序，所以倒序相加
        return Util.to8BString(val4) + Util.to8BString(val3) + Util.to8BString(val2) + Util.to8BString(val1)
    }

    private func decodeInstruction(binary: String): Instruction {
        return Instruction.parseIns(binary)
    }

    private func increatePC(lastIns: Instruction) {
        //B类型和J类型以及JARL命令都会修改PC，这种指令不需要再让PC+4
        if (InstructionType.B.contains(lastIns.insCmd)  || InstructionType.J.contains(lastIns.insCmd) || lastIns is JALR) {
        } else {
            //PC寄存器指向下一个指令
            pc.setValue(pc.getValue() + 4)
        }
    }

    public func debug(addr: String) {
        if (Util.isBlank(addr)) {
            return
        }
        this.debugAddress = ArrayList<Int64>()
        var ads = addr.split(',')
        for (item in ads) {
            var str = item.trimAscii()
            var pos = Util.strToInt(str)
            if (pos > -1) {
                debugAddress.append(pos)
            }
        }
    }

    public func write(msg: String) {
        var pair = msg.split(';')
        var posStr: String = pair[0]
        var isText: Bool = pair[1].equalsIgnoreAsciiCase("true")
        var lines: Array<String> = pair[2].split("\\n")
        // 默认从PC地址开始写入
        var pos = pc.getValue()
        if (Util.isNotBlank(posStr)) {
            posStr = posStr.trimAscii().toAsciiLower()
            pos = Util.strToInt(posStr)
        }
        var inputData = ArrayList<Byte>()
        for (l in lines) {
            var line = l.trimAscii().toAsciiLower()
            if (Util.isBlank(line) || line.startsWith("//")) {
                continue
            }
            if (line.contains("//")) {
                line = line.split('//')[0]
            }
            line = line.trimAscii()
            if (!isText) {
                line = line.replace("-", "")
                if (line.size < 8) {
                    // 8位以内按照16进制处理
                    line = line.padStart(8, padding: "0")
                    // 转为2进制
                    line = Util.hexToBinary(line)
                }
                if (line.size < 32) {
                    // 8到32按照2进制处理不足32位则补全
                    line = line.padStart(32, padding: "0")
                }
                if (line.size > 32) {
                    // 超过32位则截取
                    line = line[0..32]
                }
                inputData.appendAll(Util.binaryToBytes(line))
            } else {
                for (c in line) {
                    if (c > 255) {
                        continue
                    } else {
                        inputData.append(c)
                    }
                }
                inputData.append(UInt8(0x0A))
            }
        }
        writeToAddress(pos, inputData)
    }

    public func writeToAddress(pos: Int64, data: ArrayList<Byte>) {
        var device = Device(0)
        var deviceStart = 0
        var position = pos
        for (item in addressMap.values()) {
            if (position >= item.getStart() && pc.getValue() < item.getEnd()) {
                device = item
                deviceStart = position - item.getStart()
            }
        }
        for (item in data) {
            device.write(deviceStart, item)
            CpuService.memoryChange(position, Int64(item))
            deviceStart++
            position++
        }
    }

    public func translateCmd(cmd: String, rs1: String, rs2: String, rd: String, imm: String): String {
        return Instruction.translateCmd(cmd, rs1, rs2, rd, imm)
    }

    public func translateText(text: String): String {
        var lines = text.split("\\n")
        var rs1: String = ""
        var rs2: String = ""
        var rd: String = ""
        var imm: String = ""
        var rv = StringBuilder()

        for (l in lines) {
            var line = l.trimAscii().toAsciiLower()
            if (Util.isBlank(line) || line.startsWith("//")) {
                continue
            }
            if (line.contains("//")) {
                line = line.split('//')[0]
            }
            line = line.trimAscii()
            var index = 0
            for (i in 0..line.size) {
                if (' '.equalsIgnoreAsciiCase(line[i..i + 1])) {
                    index = i
                    break
                }
            }
            if (index <= 0) {
                continue
            }
            var cmd = line[0..index].trimAscii().toAsciiUpper()
            var para = line[index..].replace(" ", "")

            if (InstructionType.R.contains(cmd)) {
                let r = Regex("(\\w+?),(\\w+?),(\\w+)")
                let md = r.matcher(para).find()
                match (md) {
                    case Some(m) =>
                        rd = m.matchStr(1)
                        rs1 = m.matchStr(2)
                        rs2 = m.matchStr(3)
                        imm = ""
                    case None => println("not match")
                }
            } else if (InstructionType.I.contains(cmd)) {
                var r = Regex("(\\w+?),(\\w+?),(-?\\w+)")
                var md = r.matcher(para).find()
                match (md) {
                    case Some(m) =>
                        rd = m.matchStr(1)
                        rs1 = m.matchStr(2)
                        imm = m.matchStr(3)
                    case None =>
                        r = Regex("(\\w+?),([\\w\\-]+?)\\((\\w+?)\\)")
                        md = r.matcher(para).find()
                        match (md) {
                            case Some(m) =>
                                rd = m.matchStr(1)
                                rs1 = m.matchStr(3)
                                imm = m.matchStr(2)
                            case None => println("not match")
                        }
                }
            } else if (InstructionType.B.contains(cmd)) {
                let r = Regex("(\\w+?),(\\w+?),(-?\\w+)")
                let md = r.matcher(para).find()
                match (md) {
                    case Some(m) =>
                        rd = ""
                        rs1 = m.matchStr(1)
                        rs2 = m.matchStr(2)
                        imm = m.matchStr(3)
                    case None => println("not match")
                }
            } else if (InstructionType.S.contains(cmd)) {
                let r = Regex("(\\w+?),([\\w\\-]+?)\\((\\w+?)\\)")
                let md = r.matcher(para).find()
                match (md) {
                    case Some(m) =>
                        rd = ""
                        rs1 = m.matchStr(3)
                        rs2 = m.matchStr(1)
                        imm = m.matchStr(2)
                    case None => println("not match")
                }
            } else if (InstructionType.U.contains(cmd)) {
                let r = Regex("(\\w+?),(-?\\w+)")
                let md = r.matcher(para).find()
                match (md) {
                    case Some(m) =>
                        rd = m.matchStr(1)
                        rs1 = ""
                        rs2 = ""
                        imm = m.matchStr(2)
                    case None => println("not match")
                }
            } else if (InstructionType.J.contains(cmd)) {
                let r = Regex("(\\w+?),(-?\\w+)")
                let md = r.matcher(para).find()
                match (md) {
                    case Some(m) =>
                        rd = m.matchStr(1)
                        rs1 = ""
                        rs2 = ""
                        imm = m.matchStr(2)
                    case None => println("not match")
                }
            } else {
                println("unknown cmd: ${cmd}")
                continue
            }
            rv.append(translateCmd(cmd, rs1, rs2, rd, imm))
        }
        return rv.toString()
    }

    public func export(addr: String, length: String): String {
        var ii = Util.strToInt(addr)
        var ll = Util.strToInt(length)
        var sb = StringBuilder()
        for (i in 0..ll) {
            if (i % 4 == 0) {
                var insStr = fetchInstruction(ii) // 取指
                sb.append(insStr)
                var ins = decodeInstruction(insStr) //译指
                var comm = ins.toString()
                if (Util.isNotBlank(comm)) {
                    comm = "//" + comm
                }
                sb.append(comm)
                ii += 4
            }
        }
        return sb.toString()
    }

    public func setValue(registerNumber: String, registerValue: String) {
        let r: Register
        if (registerNumber.toAsciiLower() == pcName) {
            r = pc
        } else {
            var index = Instruction.parseReg(registerNumber)
            r = registers[index]
        }
        var value = Util.strToInt(registerValue)
        r.setValue(value)
        //通知前台寄存器发生了变化，只是为了前台显示
        CpuService.registerChange(r.index, r.getValue())
    }
}
