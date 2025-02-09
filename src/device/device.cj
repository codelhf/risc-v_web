package riscv.device

import std.collection.ArrayList

public open class Device {

    private var size: Int64

    private var data: ArrayList<Byte>

    private var start: Int64

    private var end: Int64 // 不包含

    public init(size: Int64) {
        this.size = size
        this.data = ArrayList<Byte>(size)
        for (_ in 0..size) {
            this.data.add(0)
        }
        this.start = 0
        this.end = 0
    }

    public func clear() {
        for ( i in 0..size) {
            this.data[i] = 0
        }
    }

    public func getSize(): Int64 {
        return this.size
    }

    public func read(addr: Int64): Byte {
        return this.data[addr]
    }
    
    public func write(addr: Int64, data: Byte) {
        this.data[addr] = data
    }

    public func getStart(): Int64 {
        return this.start
    }
    
    public func setStart(start: Int64) {
        this.start = start
    }

    public func getEnd(): Int64 {
        return this.end
    }

    public func setEnd(end: Int64) {
        this.end = end
    }
}