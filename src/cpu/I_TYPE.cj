package riscv.cpu

// import riscv.cpu.Cpu
// import riscv.cpu.CpuService
import riscv.device.Device
import riscv.util.Util

/// 将rs1中的值和立即数相加，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   000  |      rd      |     0010011        |

public class ADDI <: Instruction {

    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() + this.imm
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// 将rs1中的值和立即数按位进行与操作，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   111  |      rd      |     0010011        |

public class ANDI <: Instruction {

    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() & this.imm
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

///JALR(Jump And Link register) 将rs1中的值加上立即数作为新地址，
///将下一条命令的地址（PC+4）存放到rd，然后 将PC寄存器指向新地址
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   000  |      rd      |     1100111        |

public class JALR <: Instruction {

    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.registers[this.rs1].getValue() + this.imm
        address = address & 0xfe //将最后一位设成0，因为即使用压缩格式，命令开始的位置至少是2的倍数，不可能从单数地址开始
        var newVal = cpuInfo.pc.getValue() + 4
        cpuInfo.registers[this.rd].setValue(newVal)
        cpuInfo.pc.setValue(address)
        CpuService.registerChange(this.rd, newVal)
        CpuService.registerChange(cpuInfo.pc.index, address)
    }
}

///LB(Load Byte) 将rs1中的值加上立即数作为地址，读取该地址中的字节值写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   000  |      rd      |     0000011        |

public class LB <: Instruction {
    public func execute(cpuInfo: Cpu){
        var address = cpuInfo.registers[this.rs1].getValue() + this.imm
        var device = Device(0)
        var deviceStart = 0
        for (item in cpuInfo.addressMap.values()) {
            if (address >= item.getStart() && address < item.getEnd()) {
                device = item
                deviceStart = address - item.getStart()
                break
            }
        }
        if (device.getSize() > 0) {
            var newVal = Int64(device.read(deviceStart))
            cpuInfo.registers[this.rd].setValue(newVal)
            CpuService.registerChange(this.rd, newVal)
        }
    }
}

///LBU(Load Byte Unsinged) 将rs1中的值加上立即数作为地址，读取该地址中的字节值写入rd,无符号
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   100  |      rd      |     0000011        |

public class LBU <: Instruction {
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
            var newVal = Int64(device.read(deviceStart))
            cpuInfo.registers[this.rd].setValue(newVal)
            CpuService.registerChange(this.rd, newVal)
        }
    }
}

///LH(Load HalfWord) 将rs1中的值加上立即数作为地址，从该地址开始读取16位的值写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   001  |      rd      |     0000011        |

public class LH <: Instruction {
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
            let val1 = device.read(deviceStart)
            let val2 = device.read(deviceStart + 1)
            var newVal = Util.to8BString(val2) + Util.to8BString(val1)
            cpuInfo.registers[this.rd].setValue(Util.binToInt(newVal))
            CpuService.registerChange(this.rd, Util.binToInt(newVal))
        }
    }
}

///LHU(Load HalfWord Unsigned) 将rs1中的值加上立即数作为地址，从该地址开始读取16位的值写入rd，无符号
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   101  |      rd      |     0000011        |

public class LHU <: Instruction {
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
            // var newVal = (int)BitConverter.ToUInt16(new byte[] { device[deviceStart], device[deviceStart + 1] }, 0)
            let val1 = device.read(deviceStart)
            let val2 = device.read(deviceStart + 1)
            var newVal = Util.to8BString(val2) + Util.to8BString(val1)
            cpuInfo.registers[this.rd].setValue(Util.binToUInt(newVal))
            CpuService.registerChange(this.rd, Util.binToUInt(newVal))
        }
    }
}

///LW(Load Word) 将rs1中的值加上立即数作为地址，从该地址开始读取32位的值写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   010  |      rd      |     0000011        |

public class LW <: Instruction {
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
            // var newVal = BitConverter.ToInt32(new byte[] { device[deviceStart], device[deviceStart + 1], device[deviceStart + 2], device[deviceStart + 3] }, 0)
            let val1 = device.read(deviceStart)
            let val2 = device.read(deviceStart + 1)
            let val3 = device.read(deviceStart + 2)
            let val4 = device.read(deviceStart + 3)
            var newVal = Util.to8BString(val4) + Util.to8BString(val3) + Util.to8BString(val2) + Util.to8BString(val1)
            cpuInfo.registers[this.rd].setValue(Util.binToInt(newVal))
            CpuService.registerChange(this.rd, Util.binToInt(newVal))
        }
    }
}

/// 将rs1中的值和立即数按位进行或操作，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   110  |      rd      |     0010011        |

public class ORI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() | this.imm
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SLLI(Shift Left Logical imm) 将rs1的值逻辑左移立即数中的值，并将结果写入rd
/// 立即数只取低五位，因为32位的数据最大也就移动2的5次方=32位，相当于r类型指令中rs2的位置
/// 立即数的高七位固定位0000000
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|           0000000+低五位          |      rs1     |   001  |      rd      |     0010011        |

public class SLLI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() << this.rs2 //立即数的低五位，相当于rs2的位置
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SLTI(Set Less Then imm)如果rs1的值小于立即数，rd的值设为1，否则rd的值设为0
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   010  |      rd      |     0010011        |

public class SLTI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = 0
        if (cpuInfo.registers[this.rs1].getValue() < this.imm) {
            newVal = 1
        }
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SLTIU(Set Less Then imm Unsigned)如果rs1的值小于立即数(无符号)，rd的值设为1，否则rd的值设为0
/// 特殊处理，当imm是1，如果rs1是x0,则rd的值为1，否则rd的值为0
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   011  |      rd      |     0010011        |

public class SLTIU <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = 0
        if (imm == 1) {
            if (this.rs1 == 0) {
                newVal = 1
            }
        } else {
            if (cpuInfo.registers[this.rs1].getValue() < this.imm) {
                newVal = 1
            }
        }
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SRAI(Shift Right Arithmetic imm) 将rs1的值算数右移立即数，并将结果写入rd，算数右移意味着如果是正数，左边补零，如果是负数，左边补1
/// 立即数只取低五位，因为32位的数据最大也就移动2的5次方=32位，相当于R型指令中rs2的位置
/// 立即数的高七位固定位0100000
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|           0100000+低五位          |      rs1     |   101  |      rd      |     0010011        |

public class SRAI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() >> this.rs2 //立即数的低五位，相当于rs2的位置
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SRLI(Shift Right Logical imm) 将rs1的值逻辑右移立即数中的值，并将结果写入rd，逻辑右移意味着不管正数还是负数，左边都补0
/// 立即数只取低五位，因为32位的数据最大也就移动2的5次方=32位，相当于R类型指令中rs2的位置
/// 立即数的高七位固定位0000000
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|           0000000+低五位          |      rs1     |   101  |      rd      |     0010011        |

public class SRLI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = UInt32(cpuInfo.registers[this.rs1].getValue() >> this.rs2)//立即数的低五位，相当于rs2的位置
        cpuInfo.registers[this.rd].setValue(Int64(newVal))
        CpuService.registerChange(this.rd, Int64(newVal))
    }
}

/// 将rs1中的值和立即数按位进行异或与操作，并将结果写入rd
/// 如果立即数是-1，表示非操作
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                imm[11:0]          |      rs1     |   100  |      rd      |     0010011        |

public class XORI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() ^ this.imm
        if(imm == -1) {
            newVal = !cpuInfo.registers[this.rs1].getValue()
        }
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}