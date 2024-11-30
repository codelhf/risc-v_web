package riscv.cpu

// import riscv.cpu.Cpu
// import riscv.cpu.CpuService
import riscv.util.Util

/// AUIPC (Add Upper Immediate To PC)将立即数作为一个32位数的前20位，后12位补0，再加上当前PC的值，将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                 imm[31:12]                                |     rd       |       0110111      |

public class AUIPC <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = this.imm << 12
        newVal += cpuInfo.pc.getValue()
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}

/// LUI (Load Upper Immediate)将立即数作为一个32位数的前20位，后12位补0，这样就形成了一个很大的数，将结果写入rd
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|                 imm[31:12]                                |     rd       |       0110111      |

public class LUI <: Instruction {
    public func execute(cpuInfo: Cpu) {
        var newVal = this.imm << 12
        cpuInfo.registers[this.rd].setValue(newVal)
        CpuService.registerChange(this.rd, newVal)
    }
}