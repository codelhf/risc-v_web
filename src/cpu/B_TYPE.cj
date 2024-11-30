package riscv.cpu

// import riscv.cpu.Cpu
// import riscv.cpu.CpuService
import riscv.device.Device
import riscv.util.Util

///BEQ(Branch Equal) 如果rs1和rs2中的值相等，则跳转到新地址，新地址是当前PC加上立即数的两倍
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|     imm[12|10:5]   |     rs2      |      rs1        |  000   |imm[4:1|11]|      1100011       |

public class BEQ <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        if(cpuInfo.registers[this.rs1].getValue() == cpuInfo.registers[this.rs2].getValue()) {
            cpuInfo.pc.setValue(address)
            CpuService.registerChange(cpuInfo.pc.index, address)
        } else {
            cpuInfo.pc.setValue(cpuInfo.pc.getValue() + 4)
            CpuService.registerChange(cpuInfo.pc.index, address)
        }
    }
}

///BGE(Branch Great or Equal) 如果rs1的值大于等于rs2中的值，则跳转到新地址，新地址是当前PC加上立即数的两倍
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|     imm[12|10:5]   |      rs2     |      rs1        |  101   |imm[4:1|11]|    1100011         |

public class BGE <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        if(cpuInfo.registers[this.rs1].getValue() >= cpuInfo.registers[this.rs2].getValue()) {
            cpuInfo.pc.setValue(address)
            CpuService.registerChange(cpuInfo.pc.index, address)
        } else {
            cpuInfo.pc.setValue(cpuInfo.pc.getValue() + 4)
            CpuService.registerChange(cpuInfo.pc.index, address)
        }
    }
}

///BGEU(Branch Great or Equal Unsigned) 如果rs1的值大于等于rs2中的值(无符号)，则跳转到新地址，新地址是当前PC加上立即数的两倍
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|     imm[12|10:5]   |     rs2      |      rs1        |  111   |imm[4:1|11]|      1100011       |

public class BGEU <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        if(UInt64(cpuInfo.registers[this.rs1].getValue()) >= UInt64(cpuInfo.registers[this.rs2].getValue())){
            cpuInfo.pc.setValue(address)
            CpuService.registerChange(cpuInfo.pc.index, address)
        } else {
            cpuInfo.pc.setValue(cpuInfo.pc.getValue() + 4)
            CpuService.registerChange(cpuInfo.pc.index, address)
        }
    }
}


///BLT(Branch Less Than) 如果rs1的值小于rs2中的值，则跳转到新地址，新地址是当前PC加上立即数的两倍
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|     imm[12|10:5]   |     rs2      |      rs1        |  100   |imm[4:1|11]|      1100011       |

public class BLT <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        if(cpuInfo.registers[this.rs1].getValue() < cpuInfo.registers[this.rs2].getValue()){
            cpuInfo.pc.setValue(address)
            CpuService.registerChange(cpuInfo.pc.index, address)
        } else {
            cpuInfo.pc.setValue(cpuInfo.pc.getValue()+4)
            CpuService.registerChange(cpuInfo.pc.index, address)
        }
    }
}

///BLTU(Branch Less Than Unsigned) 如果rs1的值小于rs2中的值(无符号)，则跳转到新地址，新地址是当前PC加上立即数的两倍
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|     imm[12|10:5]   |     rs2      |      rs1        |  110   |imm[4:1|11]|      1100011       |

public class BLTU <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        if(UInt64(cpuInfo.registers[this.rs1].getValue()) < UInt64(cpuInfo.registers[this.rs2].getValue())){
            cpuInfo.pc.setValue(address)
            CpuService.registerChange(cpuInfo.pc.index, address)
        } else {
            cpuInfo.pc.setValue(cpuInfo.pc.getValue() + 4)
            CpuService.registerChange(cpuInfo.pc.index, address)
        }
    }
}

///BNE(Branch Not Equal) 如果rs1和rs2中的值不相等，则跳转到新地址，新地址是当前PC加上立即数的两倍
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|     imm[12|10:5]   |     rs2      |      rs1        |  001   |imm[4:1|11]|      1100011       |

public class BNE <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        if(cpuInfo.registers[this.rs1].getValue() != cpuInfo.registers[this.rs2].getValue()){
            cpuInfo.pc.setValue(address)
            CpuService.registerChange(cpuInfo.pc.index, address)
        } else {
            cpuInfo.pc.setValue(cpuInfo.pc.getValue() + 4)
            CpuService.registerChange(cpuInfo.pc.index, address)
        }
    }
}