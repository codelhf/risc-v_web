package riscv.cpu

import riscv.util.Util

public open class Instruction {
    public var insCmd: String = "" //指令名称
    public var opCode: Int64 = 0 //OpCode
    public var rd: Int64 = 0     //目标寄存器
    public var rs1: Int64 = 0    //第一个源寄存器
    public var rs2: Int64 = 0    //第二个源寄存器
    public var imm: Int64 = 0    //立即数，常量
    public var func3: Int64 = 0   //三个字节的编码
    public var func7: Int64 = 0   //七个字节的编码

    public open func execute(cpuInfo: Cpu) {
        cpuInfo._running = true
    }

    public func toString(): String {
        var cmd = this.insCmd.toAsciiLower()
        if (cmd.equalsIgnoreAsciiCase("")) {
            return ""
        }
        var rv = ""
        if (InstructionType.R.contains(this.insCmd)) {
            rv = "${cmd} x${rd},x${rs1},x${rs2}"
        } else if (InstructionType.I.contains(this.insCmd)) {
            if (cmd.startsWith("l") || cmd.equalsIgnoreAsciiCase("jalr")) {
                rv = "${cmd} x${rd},${imm}(x${rs1})"
            } else {
                rv = "${cmd} x${rd},x${rs1},${imm}"
            }
        } else if (InstructionType.S.contains(this.insCmd)) {
            rv = "${cmd} x${rs2},${imm}(x${rs1})"
        } else if (InstructionType.B.contains(this.insCmd)) {
            rv = "${cmd} x${rs1},x${rs2},${imm}"
        } else if (InstructionType.U.contains(this.insCmd)) {
            rv = "${cmd} x${rd},${imm}"
        } else if (InstructionType.J.contains(this.insCmd)) {
            rv = "${cmd} x${rd},${imm}"
        }
        return rv
    }
    
    public static func parseIns(binStr: String): Instruction {
        // var data = Util.strToUInt("0b" + binStr)
        
        let ins = Instruction()
        // ins.opCode = Int64(data & 0x7f)
        // ins.rd = Int64((data >> 7) & 0x1f)
        // ins.rs1 = Int64((data >> 15) & 0x1f)
        // ins.rs2 = Int64((data >> 20) & 0x1f)
        // ins.fun3 = Int64((data >> 12) & 0x7)
        // ins.fun7 = Int64((data >> 25) & 0x7f)
        ins.opCode = Util.binToUInt(binStr[25..32])
        ins.rd = Util.binToUInt(binStr[20..25])
        ins.rs1 = Util.binToUInt(binStr[12..17])
        ins.rs2 = Util.binToUInt(binStr[7..12])
        ins.func3 = Util.binToUInt(binStr[17..20])
        ins.func7 = Util.binToUInt(binStr[0..7])

        var imm: Int64 = 0
        if (ins.opCode == Const.OP0000011 || ins.opCode == Const.OP0010011 || ins.opCode == Const.OP1100111) {
            // imm[11:0]
            imm = Util.binToInt(binStr[0..12])
        } else if (ins.opCode == Const.OP1100011) {
            // imm[12|10:5] | imm[4:1|11]
            imm = Util.binToInt(binStr[0..1] + binStr[24..25] + binStr[1..7] + binStr[20..24] )
        } else if (ins.opCode == Const.OP0100011) {
            // imm[11:5] | imm[4:0]
            imm = Util.binToInt(binStr[0..8] + binStr[20..25])
        } else if (ins.opCode == Const.OP0110111 || ins.opCode == Const.OP0010111) {
            // imm[31:12]
            imm = Util.binToInt(binStr[0..20])
        } else if (ins.opCode == Const.OP1101111) {
            // imm[20|10:1|11|19:12]
            imm = Util.binToInt(binStr[0..1] + binStr[12..20] + binStr[11..12] + binStr[1..11])
        }
        ins.imm = imm

        let opCode = ins.opCode
        let func3 = ins.func3
        let func7 = ins.func7

        var rv = Instruction()
        // R-type
        if (opCode == Const.OP0110011) {
            if (func3 == Const.F000) {
                if (func7 == Const.F0000000) {
                    rv = ADD()
                    rv.insCmd = InstructionType.ADD
                } else if (func7 == Const.F0100000) {
                    rv = SUB()
                    rv.insCmd = InstructionType.SUB
                } else if (func7 == Const.F0000001) {
                    rv = MUL()
                    rv.insCmd = InstructionType.MUL
                }
            } else if (func3 == Const.F111) {
                rv = AND()
                rv.insCmd = InstructionType.AND
            } else if (func3 == Const.F110) {
                rv = OR()
                rv.insCmd = InstructionType.OR
            } else if (func3 == Const.F100) {
                rv = XOR()
                rv.insCmd = InstructionType.XOR
            } else if (func3 == Const.F001) {
                rv = SLL()
                rv.insCmd = InstructionType.SLL
            } else if (func3 == Const.F010) {
                rv = SLT()
                rv.insCmd = InstructionType.SLT
            } else if (func3 == Const.F011) {
                rv = SLTU()
                rv.insCmd = InstructionType.SLTU
            } else if (func3 == Const.F101) {
                if (func7 == Const.F0000000) {
                    rv = SRL()
                    rv.insCmd = InstructionType.SRL
                } else if (func7 ==Const.F0100000) {
                    rv = SRA()
                    rv.insCmd = InstructionType.SRA
                }
            }
        // I-type
        } else if (opCode == Const.OP0010011) {
            if (func3 == Const.F000) {
                rv = ADDI()
                rv.insCmd = InstructionType.ADDI
            } else if (func3 == Const.F111) {
                rv = ANDI()
                rv.insCmd = InstructionType.ANDI
            } else if (func3 == Const.F110) {
                rv = ORI()
                rv.insCmd = InstructionType.ORI
            } else if (func3 == Const.F100) {
                rv = XORI()
                rv.insCmd = InstructionType.XORI
            } else if (func3 == Const.F010) {
                rv = SLTI()
                rv.insCmd = InstructionType.SLTI
            } else if (func3 == Const.F011) {
                rv = SLTIU()
                rv.insCmd = InstructionType.SLTIU
            } else if (func3 == Const.F001) {
                rv = SLLI()
                rv.insCmd = InstructionType.SLLI
            } else if (func3 == Const.F101) {
                if (func7 == Const.F0000000) {
                    rv = SRLI()
                    rv.insCmd = InstructionType.SRLI
                } else if (func7 == Const.F0100000) {
                    rv = SRAI()
                    rv.insCmd = InstructionType.SRAI
                }
            }
        } else if (opCode == Const.OP0000011) {
            if (func3 == Const.F000) {
                rv = LB()
                rv.insCmd = InstructionType.LB
            } else if (func3 == Const.F001) {
                rv = LH()
                rv.insCmd = InstructionType.LH
            } else if (func3 == Const.F010) {
                rv = LW()
                rv.insCmd = InstructionType.LW
            } else if (func3 == Const.F100) {
                rv = LBU()
                rv.insCmd = InstructionType.LBU
            } else if (func3 == Const.F101) {
                rv = LHU()
                rv.insCmd = InstructionType.LHU
            }
        } else if (opCode == Const.OP1100111 && func3 == Const.F000) {
            rv = JALR()
            rv.insCmd = InstructionType.JALR
        // B-type
        } else if (opCode == Const.OP1100011) {
            if (func3 == Const.F000) {
                rv = BEQ()
                rv.insCmd = InstructionType.BEQ
            } else if (func3 == Const.F001) {
                rv = BNE()
                rv.insCmd = InstructionType.BNE
            } else if (func3 == Const.F100) {
                rv = BLT()
                rv.insCmd = InstructionType.BLT
            } else if (func3 == Const.F101) {
                rv = BGE()
                rv.insCmd = InstructionType.BGE
            } else if (func3 == Const.F110) {
                rv = BLTU()
                rv.insCmd = InstructionType.BLTU
            } else if (func3 == Const.F111) {
                rv = BGEU()
                rv.insCmd = InstructionType.BGEU
            }
        // S-type
        } else if (opCode == Const.OP0100011) {
            if (func3 == Const.F000) {
                rv = SB()
                rv.insCmd = InstructionType.SB
            } else if (func3 == Const.F001) {
                rv = SH()
                rv.insCmd = InstructionType.SH
            } else if (func3 == Const.F010) {
                rv = SW()
                rv.insCmd = InstructionType.SW
            }
        // U-type
        } else if (opCode == Const.OP0010111) {
            rv = AUIPC()
            rv.insCmd = InstructionType.AUIPC
        } else if (opCode == Const.OP0110111) {
            rv = LUI()
            rv.insCmd = InstructionType.LUI
        // J-type
        } else if (opCode == Const.OP1101111) {
            rv = JAL()
            rv.insCmd = InstructionType.JAL
        } else {
            return ins
        }
        rv.opCode = ins.opCode
        rv.rd = ins.rd
        rv.rs1 = ins.rs1
        rv.rs2 = ins.rs2
        rv.func3 = ins.func3
        rv.func7 = ins.func7
        rv.imm = ins.imm

        return rv
    }
    
    public static func translateCmd(cmd: String, rs1: String, rs2: String, rd: String, imm: String) {

        var func7 = Const.F0000000Str
        var func3 = ""
        var op = ""
        var rv = ""
        var rs1value = parseReg(rs1)
        var rs2value = parseReg(rs2)
        var rdvalue = parseReg(rd)
        var immvalue = parseImm(imm)

        if (InstructionType.R.contains(cmd)) {
            op = Const.OP0110011Str
            if (cmd == InstructionType.ADD || cmd == InstructionType.SUB || cmd == InstructionType.MUL) {
                func3 = Const.F000Str
                if (cmd == InstructionType.SUB) {
                    func7 = Const.F0100000Str
                } else if (cmd == InstructionType.MUL) {
                    func7 = Const.F0000001Str
                }
            } else if (cmd == InstructionType.SLL) {
                func3 = Const.F001Str
            } else if (cmd == InstructionType.SLT) {
                func3 = Const.F010Str
            } else if (cmd == InstructionType.SLTU) {
                func3 = Const.F011Str
            } else if (cmd == InstructionType.XOR) {
                func3 = Const.F100Str
            } else if (cmd == InstructionType.SRL || cmd == InstructionType.SRA) {
                func3 = Const.F101Str
                if (cmd == InstructionType.SRA) {
                    func7 = Const.F0100000Str
                }
            } else if (cmd == InstructionType.OR) {
                func3 = Const.F110Str
            } else if (cmd == InstructionType.AND) {
                func3 = Const.F111Str
            }
            if (rs1value < 0 || rs1value > 31) {
                rv = "//rs1格式错误，请输入0-31之间的数字"
            }
            if (rs2value < 0 || rs2value > 31) {
                rv = "//rs2格式错误，请输入0-31之间的数字"
            }
            if (rdvalue < 0 || rdvalue > 31) {
                rv = "//rd格式错误，请输入0-31之间的数字"
            }
            if (rv == "") {
                rv = "${func7}${getRegStr(rs2value)}${getRegStr(rs1value)}${func3}${getRegStr(rdvalue)}${op}"
            }
            rv += "//${cmd.toAsciiLower()} x${rdvalue},x${rs1value},x${rs2value}\\n"
        } else if (InstructionType.I.contains(cmd)) {
            op = Const.OP0010011Str
            if (cmd == InstructionType.ADDI) {
                func3 = Const.F000Str
            } else if (cmd == InstructionType.SLLI) {
                func3 = Const.F001Str
            } else if (cmd == InstructionType.SLTI) {
                func3 = Const.F010Str
            } else if (cmd == InstructionType.SLTIU) {
                func3 = Const.F011Str
            } else if (cmd == InstructionType.XORI) {
                func3 = Const.F100Str
            } else if (cmd == InstructionType.SRLI || cmd == InstructionType.SRAI) {
                func3 = Const.F101Str
                if (cmd == InstructionType.SRAI) {
                    func7 = Const.F0100000Str
                }
            } else if (cmd == InstructionType.ORI) {
                func3 = Const.F110Str
            } else if (cmd == InstructionType.ANDI) {
                func3 = Const.F111Str
            } else if (cmd == InstructionType.LB) {
                func3 = Const.F000Str
                op = Const.OP0000011Str
            } else if (cmd == InstructionType.LH) {
                func3 = Const.F001Str
                op = Const.OP0000011Str
            } else if (cmd == InstructionType.LW) {
                func3 = Const.F010Str
                op = Const.OP0000011Str
            } else if (cmd == InstructionType.LBU) {
                func3 = Const.F100Str
                op = Const.OP0000011Str
            } else if (cmd == InstructionType.LHU) {
                func3 = Const.F101Str
                op = Const.OP0000011Str
            } else if (cmd == InstructionType.JALR) {
                func3 = Const.F000Str
                op = Const.OP1100111Str
            }
            if (rs1value < 0 || rs1value > 31) {
                rv = "//rs1格式错误，请输入0-31之间的数字"
            }
            if (rdvalue < 0 || rdvalue > 31) {
                rv = "//rd格式错误，请输入0-31之间的数字"
            }
            if (immvalue == Int64.Min) {
                rv = "//imm格式错误，请输入正确的数值"
            }
            if (rv == "") {
                if (cmd == InstructionType.SLLI || cmd == InstructionType.SRLI || cmd == InstructionType.SRAI) {
                    rv = "${func7}${getImmStr(immvalue, 12)[6..]}${getRegStr(rs1value)}${func3}${getRegStr(rdvalue)}${op}"
                } else {
                    rv = "${getImmStr(immvalue, 12)}${getRegStr(rs1value)}${func3}${getRegStr(rdvalue)}${op}"
                }
            }
            if (immvalue < -2048 || immvalue > 2047) {
                var immBinStr = Util.to32BString(immvalue)
                immvalue = Util.binToInt(immBinStr[20..])
            }
            if (cmd.startsWith("L") || cmd.equalsIgnoreAsciiCase(InstructionType.JALR)) {
                rv += "//${cmd.toAsciiLower()} x${rdvalue},${immvalue}(x${rs1value})\\n"
            } else {
                rv += "//${cmd.toAsciiLower()} x${rdvalue},x${rs1value},${immvalue}\\n"
            }
        } else if (InstructionType.B.contains(cmd)) {
            op = Const.OP1100011Str
            if (cmd == InstructionType.BEQ) {
                func3 = Const.F000Str
            } else if (cmd == InstructionType.BNE) {
                func3 = Const.F001Str
            } else if (cmd == InstructionType.BLT) {
                func3 = Const.F100Str
            } else if (cmd == InstructionType.BGE) {
                func3 = Const.F101Str
            } else if (cmd == InstructionType.BLTU) {
                func3 = Const.F110Str
            } else if (cmd == InstructionType.BGEU) {
                func3 = Const.F111Str
            }
            if (rs1value < 0 || rs1value > 31) {
                rv = "//rs1格式错误，请输入0-31之间的数字"
            }
            if (rs2value < 0 || rs2value > 31) {
                rv = "//rs2格式错误，请输入0-31之间的数字"
            }
            if (immvalue == Int64.Min) {
                rv = "//imm格式错误，请输入正确的数值"
            }
            if (rv == "") {
                var ims = getImmStr(immvalue, 12) + "0"
                rv = "${ims[0..1]}${ims[2..8]}${getRegStr(rs2value)}${getRegStr(rs1value)}${func3}${ims[8..12]}${ims[1..2]}${op}"
            }
            if (immvalue < -2048 || immvalue > 2047) {
                var immBinStr = Util.to32BString(immvalue)
                immvalue = Util.binToInt(immBinStr[20..])
            }
            rv += "//${cmd.toAsciiLower()} x${rs1value},x${rs2value},${immvalue}\\n"
        } else if (InstructionType.S.contains(cmd)) {
            op = Const.OP0100011Str
            if (cmd == InstructionType.SB) {
                func3 = Const.F000Str
            } else if (cmd == InstructionType.SH) {
                func3 = Const.F001Str
            } else if (cmd == InstructionType.SW) {
                func3 = Const.F010Str
            }
            if (rs1value < 0 || rs1value > 31) {
                rv = "//rs1格式错误，请输入0-31之间的数字"
            }
            if (rs2value < 0 || rs2value > 31) {
                rv = "//rs2格式错误，请输入0-31之间的数字"
            }
            if (immvalue == Int64.Min) {
                rv = "//imm格式错误，请输入正确的数值"
            }
            if (rv == "") {
                var ims = getImmStr(immvalue, 12)
                rv = "${ims[0..7]}${getRegStr(rs2value)}${getRegStr(rs1value)}${func3}${ims[7..12]}${op}"
            }
            if (immvalue < -2048 || immvalue > 2047) {
                var immBinStr = Util.to32BString(immvalue)
                immvalue = Util.binToInt(immBinStr[20..])
            }
            rv += "//${cmd.toAsciiLower()} x${rs2value},${immvalue}(x${rs1value})\\n"
        } else if (InstructionType.U.contains(cmd)) {
            if (cmd == InstructionType.AUIPC) {
                op = Const.OP0010111Str
            } else if (cmd == InstructionType.LUI) {
                op = Const.OP0110111Str
            }
            if (rdvalue < 0 || rdvalue > 31) {
                rv = "//rd格式错误，请输入0-31之间的数字"
            }
            if (immvalue == Int64.Min) {
                rv = "//imm格式错误，请输入正确的数值"
            }
            if (rv == "") {
                var ims = getImmStr(immvalue, 20)
                rv = "${ims}${getRegStr(rdvalue)}${op}"
            }
            if (immvalue < -524288 || immvalue > 524287) {
                var immBinStr = Util.to32BString(immvalue)
                immvalue = Util.binToInt(immBinStr[12..])
            }
            rv += "//${cmd.toAsciiLower()} x${rdvalue},${immvalue}\\n"
        } else if (InstructionType.J.contains(cmd)) {
            op = Const.OP1101111Str
            if (rdvalue < 0 || rdvalue > 31) {
                rv = "//rd格式错误，请输入0-31之间的数字"
            }
            if (immvalue == Int64.Min) {
                rv = "//imm格式错误，请输入正确的数值"
            }
            if (rv == "") {
                var ims = getImmStr(immvalue, 20) + "0"
                rv = "${ims[0..1]}${ims[10..20]}${ims[9..10]}${ims[1..9]}${getRegStr(rdvalue)}${op}"
            }
            if (immvalue < -524288 || immvalue > 524287) {
                var immBinStr = Util.to32BString(immvalue)
                immvalue = Util.binToInt(immBinStr[12..])
            }
            rv += "//${cmd.toAsciiLower()} x${rdvalue},${immvalue}\\n"
        }
        return rv
    }

    public static func parseReg(reg: String): Int64 {
        var rv: Int64 = -1
        if (Util.isBlank(reg)) {
            return rv
        }
        var register = reg.trimAscii().toAsciiLower()
        if (reg.startsWith("x") || reg.startsWith("X")) {
            register = register[1..]
            rv = Util.strToInt(register)
        } else {
            for (i in 0..Cpu.registerNames.size) {
                if (register.equalsIgnoreAsciiCase(Cpu.registerNames[i])) {
                    rv = i
                }
            }
        }
        return rv
    }

    private static func parseImm(imm: String): Int64 {
        var rv: Int64 = Int64.Min
        if (Util.isIntString(imm)) {
            return rv
        }
        rv = Util.strToInt(imm)
        return rv
    }

    private static func getRegStr(index: Int64): String {
        var rv = Util.to32BString(index)
        let size = rv.size
        if (size > 5) {
            rv = rv[size - 5..]
        }
        return rv
    }

    private static func getImmStr(imm: Int64, length: Int64): String {
        var rv = Util.to32BString(imm)
        let size = rv.size
        if (size > length) {
            rv = rv[size - length..]
        }
        return rv
    }
}