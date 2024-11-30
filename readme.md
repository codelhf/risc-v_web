1. 32指令占4个字节，1个字节占8位
2. 正序读取4个字节的指令，每个字节为10进制数字
3. 指令格式为二进制，从左往右读，每4个字节为一条指令
4. bytes-> ins 每个元素倒序转二进制拼接
5. ins-> bytes 每8位倒序转十进制拼接

32个寄存器的别名以及作用：

RISC-V中32个通用寄存器的别名及作用如下：
1. **`x0`：别名`zero`**
    - **作用**：零寄存器，其值恒为0，读操作始终返回0，写操作无效。在程序中常数0的使用频率较高，使用该寄存器存放0可使编译器工作更简便，并且不浪费寄存器资源。常用于需要使用0值的运算或作为初始值等情况。
2. **`x1`：别名`ra`（Return Address）**
    - **作用**：链接寄存器，用于保存函数调用的返回地址。当一个函数调用另一个函数时，当前函数的下一条指令地址会被保存到`ra`寄存器中，以便被调用函数执行完毕后能够正确地返回。
3. **`x2`：别名`sp`（Stack Pointer）**
    - **作用**：栈指针寄存器，指向栈的地址。栈是一种数据结构，用于存储函数调用时的局部变量、参数、返回地址等信息。`sp`寄存器的值会随着函数调用和返回、数据的入栈和出栈操作而不断变化，用于跟踪栈的当前位置。
4. **`x3`：别名`gp`（Global Pointer）**
    - **作用**：全局指针寄存器，主要用于链接器松弛优化等场景。它可以帮助程序更高效地访问全局数据，具体的使用方式和作用可能因编译器和具体的程序设计而异。
5. **`x4`：别名`tp`（Thread Pointer）**
    - **作用**：线程寄存器，常用于操作系统中保存指向进程控制块（task_struct）数据结构的指针，以便操作系统管理和切换不同的线程或进程。
6. **`x5` - `x7`：别名`t0` - `t2`（Temporary）**
    - **作用**：临时寄存器，可用于在函数调用过程中临时存储数据或作为中间结果的暂存器。这些寄存器在函数内部的使用比较灵活，可以根据程序员的需要自由使用，但通常在函数调用结束后其值可能会被覆盖。
7. **`x8`：别名`s0`或`fp`（Frame Pointer）**
    - **作用**：在函数调用中，被调用函数可以使用该寄存器作为帧指针。帧指针用于指向当前函数的栈帧的起始位置，方便访问函数的局部变量和参数。它可以帮助在函数调用过程中更好地管理栈空间和访问局部数据。
8. **`x9`：别名`s1`**
    - **作用**：也是被调用函数用于保存数据的寄存器。具体的使用方式和用途可能因函数的具体需求而异，但通常与函数的内部数据存储和操作相关。
9. **`x10` - `x17`：别名`a0` - `a7`（Argument）**
    - **作用**：用于函数调用时传递参数和返回值。`a0` - `a7`寄存器通常用于传递函数的参数，其中`a0`还常用于保存函数的返回值。当函数调用时，参数会被依次放入这些寄存器中，如果参数数量超过8个，其余的参数会通过栈来传递。
10. **`x18` - `x27`：别名`s2` - `s11`**
    - **作用**：这些寄存器同样用于被调用函数保存数据。在函数执行过程中，如果需要额外的存储空间来保存临时数据或中间结果，这些寄存器可以被使用。它们的使用相对较为灵活，具体的用途取决于函数的具体逻辑。
11. **`x28` - `x31`：别名`t3` - `t6`（Temporary）**
    - **作用**：与`t0` - `t2`类似，也是临时寄存器，可用于函数内部的临时数据存储和运算。在函数调用过程中，这些寄存器可以根据需要被使用，但需要注意在函数调用结束后其值可能会被修改。

在RISC-V中，不同类型指令的立即数转换为十进制的方法如下：

**一、I-Type指令（立即数指令）**

以`addi`（加法立即数）指令为例，立即数为12位。假设指令中的立即数为`imm`（二进制表示）。

1. 如果立即数最高位（第11位）为0，表示正数：
   - 直接将二进制立即数转换为十进制数即可。例如，立即数`0b000001111111`转换为十进制为`1023`。

2. 如果立即数最高位为1，表示负数：
   - 先将立即数的二进制补码转换为原码，再转换为十进制数。
   - 转换方法为：对补码按位取反，然后加1得到原码，再转换为十进制。例如，立即数`0b111110000001`，先按位取反得到`0b000001111110`，再加1得到`0b000001111111`，转换为十进制为`1023`，由于最高位为1表示负数，所以最终结果为`-1023`。

**二、S-Type指令（存储指令）**

S-Type指令的立即数分为两部分，高位部分为`imm[11:5]`，低位部分为`imm[4:0]`。假设指令中的立即数表示为`imm`（二进制表示）。

1. 组合立即数：
   - 将高位部分左移5位，然后与低位部分拼接得到完整的12位立即数。例如，高位部分为`0b10101`，低位部分为`0b11001`，则组合后的立即数为`0b1010111001`。

2. 转换为十进制：
   - 按照I-Type指令中立即数的转换方法，根据立即数的最高位判断正负，然后进行转换。例如，对于组合后的立即数`0b1010111001`，最高位为1表示负数，先转换为原码再转换为十进制。按位取反得到`0b0101000110`，加1得到`0b0101000111`，转换为十进制为`335`，由于是负数，最终结果为`-335`。

**三、B-Type指令（分支指令）**

B-Type指令的立即数分为两部分，高位部分为`imm[12|10:5]`，低位部分为`imm[4:1|11]`。假设指令中的立即数表示为`imm`（二进制表示）。

1. 组合立即数：
   - 将高位部分左移1位，然后与低位部分拼接得到完整的13位立即数。例如，高位部分为`0b1111111111100`，低位部分为`0b1110`，则组合后的立即数为`0b11111111111001110`。

2. 转换为十进制：
   - 按照分支指令的特点，分支的偏移量是将立即数乘以2（因为RISC-V地址是字节地址，以2字节作为立即数的基本单位来计算偏移量可以用有限的立即数表达更大的偏移量），然后根据最高位判断正负进行转换。例如，对于组合后的立即数`0b11111111111001110`，乘以2得到`0b111111111110011100`，最高位为1表示负数，先转换为原码再转换为十进制。按位取反得到`0b000000000001100011`，加1得到`0b000000000001100100`，转换为十进制为`52`，由于是负数，最终结果为`-52`。

**四、U-Type指令（高位立即数载入指令）**

以`lui`（load upper immediate）指令为例，立即数为20位。假设指令中的立即数为`imm`（二进制表示）。

1. 转换为十进制：
   - 直接将20位二进制立即数转换为十进制数。例如，立即数`0b11111111111111111111`转换为十进制为`1048575`。

**五、J-Type指令（无条件跳转指令）**

J-Type指令的立即数分为两部分，高位部分为`imm[20|10:1|11|19:12]`。假设指令中的立即数表示为`imm`（二进制表示）。

1. 组合立即数：
   - 将高位部分左移1位，然后拼接得到完整的21位立即数。例如，高位部分为`0b111111111111111111111`，则组合后的立即数为`0b1111111111111111111110`。

2. 转换为十进制：
   - 按照无条件跳转指令的特点，跳转的偏移量是将立即数乘以2（原因同B-Type指令），然后根据最高位判断正负进行转换。例如，对于组合后的立即数`0b1111111111111111111110`，乘以2得到`0b11111111111111111111100`，最高位为1表示负数，先转换为原码再转换为十进制。按位取反得到`0b00000000000000000000011`，加1得到`0b00000000000000000000100`，转换为十进制为`4`，由于是负数，最终结果为`-4`。