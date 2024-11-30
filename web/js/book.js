initBook()
function initBook() {
    var cmds = {
        RType: {
            ADD: {
                label: "ADD(加)",
                desc: "将rs1和rs2中的值相加，并将结果写入rd"
            },
            SUB: {
                label: "SUB(减)",
                desc: "将rs1中的值减去rs2中的值，并将结果写入rd"
            },
            MUL: {
                label: "MUL(乘)",
                desc: "将rs1和rs2中的值相乘，并将结果写入rd"
            },
            AND: {
                label: "AND(与)",
                desc: "将rs1和rs2中的值按位进行与操作，并将结果写入rd"
            },
            OR: {
                label: "OR(或)",
                desc: "将rs1和rs2中的值按位进行或操作，并将结果写入rd"
            },
            XOR: {
                label: "XOR(异或)",
                desc: "将rs1和rs2中的值按位进行异或操作，并将结果写入rd"
            },
            SLL: {
                label: "SLL(逻辑左移)",
                desc: "SLL(Shift Left Logical) 将rs1的值逻辑左移rs2中的值，并将结果写入rd"
            },
            SRL: {
                label: "SRL(逻辑右移)",
                desc: "SRL(Shift Right Logical) 将rs1的值逻辑右移rs2中的值，并将结果写入rd，逻辑右移意味着不管正数还是负数，左边都补0"
            },
            SRA: {
                label: "SRA(算数右移)",
                desc: "SRA(Shift Right Arithmetic) 将rs1的值算数右移rs2中的值，并将结果写入rd，算数右移意味着如果是正数，左边补零，如果是负数，左边补1"
            },
            SLT: {
                label: "SLT(比较)",
                desc: "SLT(Set Less Then)如果rs1的值小于rs2中的值，rd的值设为1，否则rd的值设为0"
            },
            SLTU: {
                label: "SLTU(无符号比较)",
                desc: "SLTU(Set Less Then Unsigned)如果rs1的值小于rs2中的值（无符号对比），rd的值设为1，否则rd的值设为0<br/> 特殊处理，如果rs1是x0，则当rs2中的值等于0时，rd的值为1，否则rd的值为0"
            }
        },
        IType: {
            ADDI: {
                label: "ADDI(立即数加)",
                desc: "将rs1中的值和立即数相加，并将结果写入rd"
            },
            ANDI: {
                label: "ANDI(立即数与)",
                desc: "将rs1中的值和立即数按位进行与操作，并将结果写入rd"
            },
            ORI: {
                label: "ORI(立即数或)",
                desc: "将rs1中的值和立即数按位进行或操作，并将结果写入rd"
            },
            XORI: {
                label: "XORI(立即数异或)",
                desc: "将rs1中的值和立即数按位进行异或与操作，并将结果写入rd<br/>如果立即数是-1，表示非操作"
            },
            SLLI: {
                label: "SLLI(立即数逻辑左移)",
                desc: "SLLI(Shift Left Logical Immediate) 将rs1的值逻辑左移立即数中的值，并将结果写入rd<br/>立即数只取低五位，因为32位的数据最大也就移动2的5次方=32位，相当于R类型指令中rs2的位置<br/>立即数的高七位固定位0000000"
            },
            SRLI: {
                label: "SRLI(立即数逻辑右移)",
                desc: "SRLI(Shift Right Logical Immediate) 将rs1的值逻辑右移立即数中的值，并将结果写入rd，逻辑右移意味着不管正数还是负数，左边都补0<br/>立即数只取低五位，因为32位的数据最大也就移动2的5次方=32位，相当于R类型指令中rs2的位置<br/>立即数的高七位固定位0000000"
            },
            SRAI: {
                label: "SRAI(立即数算数右移)",
                desc: "SRAI(Shift Right Arithmetic Immediate) 将rs1的值算数右移立即数，并将结果写入rd，算数右移意味着如果是正数，左边补零，如果是负数，左边补1<br/>立即数只取低五位，因为32位的数据最大也就移动2的5次方=32位，相当于R类型指令中rs2的位置<br/>立即数的高七位固定位0100000"
            },
            SLTI: {
                label: "SLTI(立即数比较)",
                desc: "SLTI(Set Less Then Immediate)如果rs1的值小于立即数，rd的值设为1，否则rd的值设为0"
            },
            SLTIU: {
                label: "SLTIU(立即数无符号比较)",
                desc: "SLTIU(Set Less Then Immediate Unsigned)如果rs1的值小于立即数(无符号)，rd的值设为1，否则rd的值设为0<br/>特殊处理，当Immediate是1，如果rs1是x0,则rd的值为1，否则rd的值为0"
            },
            LB: {
                label: "LB(加载8位数)",
                desc: "LB(Load Byte) 将rs1中的值加上立即数作为地址，读取该地址中的字节值写入rd"
            },
            LBU: {
                label: "LBU(加载无符号8位数)",
                desc: "LBU(Load Byte Unsinged) 将rs1中的值加上立即数作为地址，读取该地址中的字节值写入rd,无符号"
            },
            LH: {
                label: "LH(加载16位数)",
                desc: "LH(Load HalfWord) 将rs1中的值加上立即数作为地址，从该地址开始读取16位的值写入rd"
            },
            LHU: {
                label: "LHU(加载无符号16位数)",
                desc: "LHU(Load HalfWord Unsigned) 将rs1中的值加上立即数作为地址，从该地址开始读取16位的值写入rd，无符号"
            },
            LW: {
                label: "LW(加载32位数)",
                desc: "LW(Load Word) 将rs1中的值加上立即数作为地址，从该地址开始读取32位的值写入rd"
            },
            JALR: {
                label: "JALR(绝对跳转)",
                desc: "JALR(Jump And Link Register) 将rs1中的值加上立即数作为地址，将下一条命令的地址（PC+4）存放到rd，然后 将PC寄存器指向新地址"
            }
        },
        BType: {
            BEQ: {
                label: "BEQ(相等时跳转)",
                desc: "BEQ(Branch Equal) 如果rs1和rs2中的值相等，则跳转到新地址，新地址是当前PC加上立即数的两倍"
            },
            BNE: {
                label: "BNE(不等时跳转)",
                desc: "BNE(Branch Not Equal) 如果rs1和rs2中的值不相等，则跳转到新地址，新地址是当前PC加上立即数"
            },
            BLT: {
                label: "BLT(小于时跳转)",
                desc: "BLT(Branch Less Than) 如果rs1的值小于rs2中的值，则跳转到新地址，新地址是当前PC加上立即数的两倍"
            },
            BLTU: {
                label: "BLTU(无符号小于时跳转)",
                desc: "BLTU(Branch Less Than Unsigned) 如果rs1的值小于rs2中的值(无符号)，则跳转到新地址，新地址是当前PC加上立即数的两倍"
            },
            BGE: {
                label: "BGE(大于等于时跳转)",
                desc: "BGE(Branch Great or Equal) 如果rs1的值大于等于rs2中的值，则跳转到新地址，新地址是当前PC加上立即数的两倍"
            },
            BGEU: {
                label: "BGEU(无符号大于等于时跳转)",
                desc: "BGEU(Branch Great or Equal Unsigned) 如果rs1的值大于等于rs2中的值(无符号)，则跳转到新地址，新地址是当前PC加上立即数的两倍"
            }
        },
        SType: {
            SB: {
                label: "SB(存储8位数)",
                desc: "SB(Save Byte) 将rs1中的值加上立即数作为地址，把rs2中低8位的数据写入该地址"
            },
            SH: {
                label: "SH(存储16位数)",
                desc: "SH(Save Halfword) 将rs1中的值加上立即数作为地址，把rs2中低16位的数据写入该地址"
            },
            SW: {
                label: "SW(存储32位数)",
                desc: "SW(Save Word) 将rs1中的值加上立即数作为地址，把rs2中的数据写入该地址"
            }
        },
        UType: {
            AUIPC: {
                label: "AUIPC(立取高位加PC)",
                desc: "AUIPC (Add Upper Immediate To PC)将立即数作为一个32位数的前20位，后12位补0，再加上当前PC的值，将结果写入rd"
            },
            LUI: {
                label: "LUI(取高位)",
                desc: "LUI (Load Upper Immediate)将立即数作为一个32位数的前20位，后12位补0，这样就形成了一个很大的数，将结果写入rd"
            }
        },
        JType: {
            JAL: {
                label: "JAL(相对跳转)",
                desc: "JAL(Jump And Link) 将当前PC中的值加上立即数的两倍作为地址，将下一条命令的地址（PC+4）存放到rd，然后 将PC寄存器指向新地址"
            },
        }
    }
    var optionHtml = '<option value="" selected>请选择</option>'
    for (var key in cmds) {
        optionHtml += "<optgroup label='" + key + "'>"
        for (var key2 in cmds[key]) {
            optionHtml += "<option value='" + key2 + "' desc='" + cmds[key][key2].desc +"'>" + cmds[key][key2].label + "</option>"
        }
        optionHtml += "</optgroup>"
    }
    var bookcmd = document.getElementById("bookcmd")
    bookcmd.innerHTML = optionHtml
}

function handleChange() {
    var obj = document.getElementById('bookcmd');
    var groupname = obj.selectedOptions[0].parentElement.label;
    var desc = obj.selectedOptions[0].attributes?.desc?.value;
    // 获取元素
    var rs1row = document.getElementById('rs1row');
    var rs2row = document.getElementById('rs2row');
    var rdrow = document.getElementById('rdrow');
    var immrow = document.getElementById('immrow');
    document.getElementById('bookrs1').value = "";
    document.getElementById('bookrs2').value = "";
    document.getElementById('bookrd').value = "";
    document.getElementById('bookimm').value = "";
    document.getElementById('bookdes').innerHTML = desc;
    switch(groupname){
        case "IType":
            rs1row.style.display = 'block';
            rs2row.style.display = 'none';
            rdrow.style.display = 'block';
            immrow.style.display = 'block';
            break;
        case "RType":
            rs1row.style.display = 'block';
            rs2row.style.display = 'block';
            rdrow.style.display = 'block';
            immrow.style.display = 'none';
        break;
        case "JType":
        case "UType":
            rs1row.style.display = 'none';
            rs2row.style.display = 'none';
            rdrow.style.display = 'block';
            immrow.style.display = 'block';
        break;
        case "SType":
        case "BType":
            rs1row.style.display = 'block';
            rs2row.style.display = 'block';
            rdrow.style.display = 'none';
            immrow.style.display = 'block';
        break;
    }
}