package riscv.cpu

// import riscv.cpu.Cpu
// import riscv.cpu.CpuService
import riscv.util.Util

/// 将rs1和rs2中的值相加，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   000  |      rd      |      0110011       |

public class ADD <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() + cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// 将rs1中的值减去rs2中的值，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0100000       |       rs2    |     rs1      |   000  |      rd      |      0110011       |

public class SUB <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() - cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// 将rs1和rs2中的值相加，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000001       |       rs2    |     rs1      |   000  |      rd      |      0110011       |

public class MUL <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() * cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// 将rs1和rs2中的值按位进行与操作，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   111  |      rd      |      0110011       |

public class AND <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() & cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// 将rs1和rs2中的值按位进行或操作，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   110  |      rd      |      0110011       |

public class OR <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue()|cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// 将rs1和rs2中的值按位进行异或操作，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   100  |      rd      |      0110011       |

public class XOR <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() ^ cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SLL(Shift Left Logical) 将rs1的值逻辑左移rs2中的值，并将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   001  |      rd      |      0110011       |

public class SLL <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() << cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SLT(Set Less Then)如果rs1的值小于rs2中的值，rd的值设为1，否则rd的值设为0
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   010  |      rd      |      0110011       |

public class SLT <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = 0
        if (cpuInfo.registers[this.rs1].getValue() < cpuInfo.registers[this.rs2].getValue()) {
            newVal = 1
        }
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SLTU(Set Less Then Unsigned)如果rs1的值小于rs2中的值（无符号对比），rd的值设为1，否则rd的值设为0
/// 特殊处理，如果rs1是x0，则当rs2中的值等于0时，rd的值为1，否则rd的值为0
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   011  |      rd      |      0110011       |

public class SLTU <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = 0
        if (this.rs1 == 0) {
            if(cpuInfo.registers[this.rs2].getValue() == 0) {
                newVal = 1
            }
        } else {
            if (UInt64(cpuInfo.registers[this.rs1].getValue()) < UInt64(cpuInfo.registers[this.rs2].getValue())) {
                newVal = 1
            }
        }
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SRA(Shift Right Arithmetic) 将rs1的值算数右移rs2中的值，并将结果写入rd，算数右移意味着如果是正数，左边补零，如果是负数，左边补1
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0100000       |       rs2    |     rs1      |   101  |      rd      |      0110011       |

public class SRA <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = cpuInfo.registers[this.rs1].getValue() >> cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// SRL(Shift Right Logical) 将rs1的值逻辑右移rs2中的值，并将结果写入rd，逻辑右移意味着不管正数还是负数，左边都补0
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|      0000000       |       rs2    |     rs1      |   101  |      rd      |      0110011       |

public class SRL <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = UInt32(cpuInfo.registers[this.rs1].getValue()) >> cpuInfo.registers[this.rs2].getValue()
        cpuInfo.registers[this.rd].setValue(Int64(newVal))
        CpuService.registerChange(this.rd, Int64(newVal))
    }
}