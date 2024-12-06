package riscv.util

import encoding.hex.*
import encoding.json.*
import std.convert.*
import std.format.*
import std.regex.*
import std.collection.ArrayList

public class Util {

    public static func isBlank(str: String) {
        return str.trimAscii().isEmpty()
    }

    public static func isNotBlank(str: String) {
        return !isBlank(str)
    }

    public static func to2XString(value: Int): String {
        return value.format("02X")
    }

    public static func to8XString(value: Int): String {
        return value.format("08X")
    }

    public static func to8BString(value: UInt8): String {
        return value.format("08B")
    }

    public static func to32BString(value: Int): String {
        var n = value.format("032B")
        if (!n.startsWith("-")) {
            return n
        }
        // 取反码
        var str = StringBuilder()
        for (i in 0..n.size) {
            let bit = n[i..i+1]
            if (bit == "1") {
                str.append("0")
            } else {
                str.append("1")
            }
        }
        // 加一取补码
        let result = Int64.parse("0b" + str.toString()) + 1
        return result.format("B")
    }

    public static func isIntString(str: String): Bool {
        let r = Regex("^(0b[01]+|0x[0-9a-fA-F]+|\\d+)$")
        let md = r.matcher(str).allCount()
        return md > 0
    }

    public static func strToInt(str: String): Int64 {
        var val = str.trimAscii().toAsciiLower()
        if (val.startsWith("0x")) {
            return Int64.parse(val)
        }
        if (val.startsWith("0b")) {
            return Int64.parse(val)
        }
        return Int64.parse(val)
    }

    public static func binToInt(str: String): Int64 {
        var line = str.trimAscii().toAsciiLower().replace("-", "").replace(" ", "")
        if (line.startsWith("0b")) {
            line = line[2..]
        }
        var prefix = "0"
        if (line.startsWith("1")) {
            prefix = "1"
        }
        while (line.size < 32) {
            line = prefix + line
        }
        if (line.size > 32) {
            line = line[0..32]
        }
        // println("line: ${line}")
        var result = Int64.parse("0b" + line)
        // println("result: ${result}")
        // 4294967296
        if (prefix == "1") {
            return Int64(result - 4294967296)
        }
        return result
    }

    public static func binToUInt(str: String): Int64 {
        var line = str.trimAscii().toAsciiLower().replace("-", "").replace(" ", "")
        if (line.startsWith("0b")) {
            line = line[2..]
        }
        while (line.size < 32) {
            line = "0" + line
        }
        if (line.size > 32) {
            line = line[0..32]
        }
        return Int64(UInt32.parse("0b" + line))
    }

    public static func binToBytes(str: String): ArrayList<UInt8> {
        var line = str.trimAscii().toAsciiLower().replace("-", "").replace(" ", "")
        if (line.startsWith("0b")) {
            line = line[2..]
        }
        while (line.size < 32) {
            line = "0" + line
        }
        if (line.size > 32) {
            line = line[0..32]
        }
        var i = line.size - 1
        var rv = ArrayList<UInt8>()
        // 11111111-11101111-11110001-01101111
        while (i >= 0) {
            if (i % 8 == 0) {
                var numStr = line[i..(i + 8)]
                var num = UInt8.parse("0b${numStr}")
                rv.append(num)
            }
            i = i - 1
        }
        return rv
    }

    public static func toList(str: String): ArrayList<String> {
        var json = JsonValue.fromStr(str)
        let jsonObj = json.asObject()
        var result = ArrayList<String>()
        match (jsonObj.get("cmd")) {
            case Some(v) => v
                let cmd = v.toString()
                result.append(cmd[1..cmd.size-1])
            case None =>
                result.append("")
        }
        match (jsonObj.get("msg")) {
            case Some(v) => v
                let msg = v.toString()
                result.append(msg[1..msg.size-1])
            case None =>
                result.append("")
        }
        return result
    }
}
