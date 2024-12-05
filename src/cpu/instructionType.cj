package riscv.cpu

public class InstructionType {
    // Register
    public static let ADD = "ADD"
    public static let SUB = "SUB"
    public static let AND = "AND"
    public static let OR = "OR"
    public static let XOR = "XOR"
    public static let SLL = "SLL"
    public static let SLT = "SLT"
    public static let SLTU = "SLTU"
    public static let SRA = "SRA"
    public static let SRL = "SRL"
    public static let MUL = "MUL"
    // Immediate
    public static let ADDI = "ADDI"
    public static let ANDI = "ANDI"
    public static let ORI = "ORI"
    public static let XORI = "XORI"
    public static let SLLI = "SLLI"
    public static let SLTI = "SLTI"
    public static let SLTIU = "SLTIU"
    public static let SRAI = "SRAI"
    public static let SRLI = "SRLI"
    public static let LB = "LB"
    public static let LBU = "LBU"
    public static let LH = "LH"
    public static let LHU = "LHU"
    public static let LW = "LW"
    public static let JALR = "JALR"
    // Store
    public static let SB = "SB"
    public static let SH = "SH"
    public static let SW = "SW"
    // Branch
    public static let BEQ = "BEQ"
    public static let BGE = "BGE"
    public static let BGEU = "BGEU"
    public static let BLT = "BLT"
    public static let BLTU = "BLTU"
    public static let BNE = "BNE"
    // Upper
    public static let AUIPC = "AUIPC"
    public static let LUI = "LUI"
    // Jump
    public static let JAL = "JAL"


    //Register的缩写，操作两个寄存器，并把结果写到第三个寄存器上的类型
    public static let R: Array<String> = [ADD, SUB, AND, OR, XOR, SLL, SLT, SLTU, SRA, SRL, MUL]
    //Immediate的缩写，操作一个寄存器和一个常量，并把结果写到第二个寄存器上的类型
    public static let I: Array<String> = [ADDI, ANDI, ORI, XORI, SLLI, SLTI, SLTIU, SRAI, SRLI, LB, LBU, LH, LHU, LW, JALR]
    //Branch的缩写，用于分支判断，操作两个寄存器和一个常量
    public static let B: Array<String> = [BEQ, BGE, BGEU, BLT, BLTU, BNE]
    //Store的缩写，用于将寄存器数据写入内存，操作两个寄存器和一个常量
    public static let S: Array<String> = [SB, SH, SW]
    //Upper的缩写，用于取一个数的高20位，将一个常量的高20位写到一个寄存器里
    public static let U: Array<String> = [AUIPC, LUI]
    //Jump的缩写，用于跳转，操作一个寄存器和一个常量
    public static let J: Array<String> = [JAL]
}