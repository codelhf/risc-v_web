package riscv.cpu

public class Register {
    
    // 寄存器编号，RISC-V有32个通用寄存器，编号0-31
    public var index: Int64
    // 寄存器别名，RISC-V中ABI中定义的别名
    public var name: String
    // 寄存器中的内容，因为模拟32位系统，每个寄存器能保存一个32位的数据，所以用Int32
    private var value: Int32

    // 构造函数，传入寄存器编号和别名
    public init(index: Int64, name: String) {
        this.index = index
        this.name = name
        this.value = 0
    }

    public func getValue() {
        return Int64(this.value)
    }

    public func setValue(value: Int64) {
        //x0寄存器永远是0，不会改变
        if (this.index != 0) {
            this.value = Int32(value)
        }
    }

    public func clear() {
        this.value = 0
    }
}