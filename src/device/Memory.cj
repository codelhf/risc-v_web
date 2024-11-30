package riscv.device


public class Memory <: Device {

    private var name: String

    public init(size: Int64, name: String) {
        super(size)
        this.name = name
    }
}