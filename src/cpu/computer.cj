package riscv.cpu

// import riscv.cpu.Cpu
import riscv.device.*
import std.collection.{HashMap, ArrayList}

public class Computer {

    public var cpu: Cpu
    public var ram: Memory
    public var rom: Memory

    public init() {
        this.ram = Memory(0xA000, "RAM")
        this.rom = Memory(0x0064, "ROM")
        var addressMap = HashMap<String, Device>()
        rom.setStart(0x0000)
        rom.setEnd(0x0064)
        ram.setStart(0x0064)
        ram.setEnd(0xA064)
        addressMap["ROM"] = rom
        addressMap["RAM"] = ram
        this.cpu = Cpu(addressMap)
    }

    public func start() {
        ram.clear()
        rom.clear()
        cpu.start(0x0064)
        // writeRom(0)
    }

    public func reset() {
        ram.clear()
        rom.clear()
        cpu.reset(0x0064)
        // writeRom(0)
    }

    public func writeRom(addr: Int64) {
        var cmds = ArrayList<UInt32>()
        cmds.append(0b00000110010000000000000001101111) //jal x0,0,50 ，跳转到25行以后
        var index = addr
        for (item in cmds) {
            let b1 = UInt8(item >> 0)
            let b2 = UInt8(item >> 8)
            let b3 = UInt8(item >> 16)
            let b4 = UInt8(item >> 24)
            
            rom.write(index, b1)
            rom.write(index + 1, b2)
            rom.write(index + 2, b3)
            rom.write(index + 3, b4)
            index += 4
        }
        println("ROM write ${addr} done")
    }
}