package riscv.cpu

// import riscv.cpu.Cpu
// import riscv.cpu.CpuService
import riscv.util.Util

///JAL(Jump And Link) 将当前PC中的值加上立即数的两倍作为地址，
///将下一条命令的地址（PC+4）存放到rd，然后 将PC寄存器指向新地址
///|31|30|29|28|27|26|25|24|23|22|21|20|19|18|17|16|15|14|13|12|11|10|09|08|07|06|05|04|03|02|01|00|
///|           imm[20|10:1|11|19:12]                           |      rd      |       1101111      |

public class JAL <: Instruction {

    public func execute(cpuInfo: Cpu) {
        var address = cpuInfo.pc.getValue() + this.imm * 2
        var newVal = cpuInfo.pc.getValue() + 4
        cpuInfo.registers[this.rd].setValue(newVal)
        cpuInfo.pc.setValue(address)
        // cpuInfo.InvodeRegisterChange(this.Rd, newVal.ToString("X8"))
        // cpuInfo.InvodeRegisterChange(cpuinfo.PC.Index, address.ToString("X8"))
        CpuService.registerChange(this.rd, newVal)
        CpuService.registerChange(cpuInfo.pc.index, newVal)
    }
}