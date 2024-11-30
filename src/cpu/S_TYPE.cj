package riscv.cpu

// import riscv.cpu.Cpu
// import riscv.cpu.CpuService
import riscv.device.Device
import riscv.util.Util
 
///SB(Save Byte) 将rs1中的值加上立即数作为地址，把rs2中低8位的数据写入该地址
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      imm[11:5]     |     rs2      |     rs1         |  000   | imm[4:0]  |    0100011         |

public class SB <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.registers[this.rs1].getValue() + this.imm
        var device = Device(0)
        var deviceStart = 0
        for(item in cpuInfo.addressMap.values()) {
            if (address >= item.getStart() && address < item.getEnd()) {
                device = item
                deviceStart = address - item.getStart()
                break
            }
        }
        if (device.getSize() > 0) {
            var newVal = cpuInfo.registers[this.rs2].getValue()
            device.write(deviceStart, UInt8(newVal))
            CpuService.memoryChange(address, newVal)
        }
    }
}

///SH(Save Halfword) 将rs1中的值加上立即数作为地址，把rs2中低16位的数据写入该地址
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      imm[11:5]     |     rs2      |     rs1         |  001   | imm[4:0]  |    0100011         |

public class SH <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.registers[this.rs1].getValue() + this.imm
        var device = Device(0)
        var deviceStart = 0
        for(item in cpuInfo.addressMap.values()) {
            if (address >= item.getStart() && address < item.getEnd()) {
                device = item
                deviceStart = address - item.getStart()
                break
            }
        }
        if (device.getSize() > 0) {
            var bin = Util.to32BString(cpuInfo.registers[this.rs2].getValue())
            var bs = Util.binaryToBytes(bin)
            device.write(deviceStart, bs[0])
            CpuService.memoryChange(address, Int64(device.read(deviceStart)))
            device.write(deviceStart + 1, bs[1])
            CpuService.memoryChange(address + 1, Int64(device.read(deviceStart + 1)))
        }
    }
}

///SW(Save Word) 将rs1中的值加上立即数作为地址，把rs2中的数据写入该地址
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      imm[11:5]     |     rs2      |     rs1         |  010   | imm[4:0]  |    0100011         |

public class SW <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.registers[this.rs1].getValue() + this.imm
        var device = Device(0)
        var deviceStart = 0
        for(item in cpuInfo.addressMap.values()) {
            if (address >= item.getStart() && address < item.getEnd()) {
                device = item
                deviceStart = address - item.getStart()
                break
            }
        }
        if (device.getSize() > 0) {
            var bin = Util.to32BString(cpuInfo.registers[this.rs2].getValue())
            var bs = Util.binaryToBytes(bin)
            device.write(deviceStart, bs[0])
            CpuService.memoryChange(address, Int64(device.read(deviceStart)))
            device.write(deviceStart + 1, bs[1])
            CpuService.memoryChange(address+1, Int64(device.read(deviceStart + 1)))
            device.write(deviceStart + 2, bs[1])
            CpuService.memoryChange(address+2, Int64(device.read(deviceStart + 2)))
            device.write(deviceStart + 3, bs[1])
            CpuService.memoryChange(address+3, Int64(device.read(deviceStart + 3)))
        }
    }
}