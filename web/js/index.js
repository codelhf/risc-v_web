var sendData = null

window.onload = function () {
    // 建立 WebSocket 连接
    var socket = new WebSocket('ws://localhost:8888/ws');

    sendData = function (message) {
        console.log('发送了消息：' + JSON.stringify(message));
        if (socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify(message));
        } else {
            socket.addEventListener('open', () => {
                socket.send(JSON.stringify(message));
            });
        }
    }
    
    socket.onopen = function () {
        console.log('WebSocket 连接已建立');
        // socket.send('Hello from client!');
        socket.send(JSON.stringify({ cmd: 'pc', msg: 'read' }))
    };
    
    socket.onmessage = function (event) {
        console.log('接收到消息：' + event.data);
        receiveData(JSON.parse(event.data));
    };
    
    socket.onclose = function () {
        console.log('WebSocket 连接已关闭');
    };
}

//pc寄存器
var currentPc = 0;
function receiveData(data) {
    if (!data && typeof data != 'function') {
        return;
    }
    var cmd = data.cmd;
    var msg = data.msg;
    if (cmd == "pc") {
        var size = msg.split(',')
        initMemory(size[0], size[1]);
        initRegister(size[2]);
        document.getElementById("x0").value = "0x00000000";
        document.getElementById("x100").value = "0x00000000";
    }
    if (cmd == "register") {
        var data = msg.split(",");
        document.getElementById("x" + data[0]).value = "0x" + data[1];
        //根据pc寄存器的值修改内存指向
        if (data[0] == "100") {
            document.getElementById("m" + currentPc).style.border = "";
            currentPc = parseInt(data[1],16);
            document.getElementById("m" + currentPc).style.border = "medium solid #00FF00";
        }
    }
    if (cmd == "memory") {
        var data = msg.split(",");
        document.getElementById("m" + data[0]).value = "0x"+ data[1];
    }
    if (cmd == "comment") {
        var data = msg.split(";");
        document.getElementById("c" + data[0]).innerHTML = data[1];
    }
    if (cmd == "translate") {
        document.getElementById("messageInput").value += msg;
    }
    if (cmd == "display") {
        var li = document.createElement("li");
        document.getElementById("messagesList").appendChild(li);
        li.textContent = `${msg}`;
    }
}

function initMemory(ramSize = 200, romSize = 100) {
    var html = "";
    // 16k内存 41059
    // ramSize = 200
    for (let i = ramSize - 1; i >= 100; i -= 4) {
        html += `
        <div class="row">
            <div class="col-2" style="">${toHex8(i-3)}</div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i-3)}" readonly/></div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i-2)}" readonly/></div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i-1)}" readonly/></div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i)}" readonly/></div>
            <div class="col-6" style="padding-left:10px" id="c${(i+1)/4-1}"></div>
        </div>
        `;
    }
    for (let i = romSize - 1; i >= 0; i -= 4) {
        html += `
        <div class="row" style="background-color:yellow">
            <div class="col-2" style="">${toHex8(i-3)}</div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i-3)}" readonly/></div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i-2)}" readonly/></div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i-1)}" readonly/></div>
            <div class="col-1"><input style="width:40px;font-size:12px" id="m${(i)}" readonly/></div>
            <div class="col-6" style="padding-left:10px" id="c${(i+1)/4-1}"></div>
        </div>
        `;
    }
    var memoryDiv = document.getElementById("memory");
    memoryDiv.innerHTML = html;
    memoryDiv.scrollTop = memoryDiv.scrollHeight;
}

function initRegister() {
    const registers = ["zero", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"]
    var html = ""
    for (let i = 0; i < registers.length; i++) {
        html += `
        <div class="col-2" style="text-align: right">X${i}(${registers[i]})</div>
        <div class="col-4"><input class="form-control" id="x${i}" readonly/></div>
        `;
    }
    html += `
    <div class="col-2" style="text-align: right">X100(pc)</div>
    <div class="col-4"><input class="form-control" id="x100" readonly/></div>
    `;
    var registerDiv = document.getElementById("register");
    registerDiv.innerHTML = html;
}

function toHex8(num) {
    let hex = num.toString(16).toUpperCase();
    return "0x" + hex.padStart(8, "0");
}

function modelHide(modelId, event) {
    var modelie = document.getElementById(`${modelId}`);
    var model = bootstrap.Modal.getInstance(modelie);
    model.hide();
    event.preventDefault();
}

document.getElementById("run").addEventListener("click", function (event) {
    sendData({ cmd: 'run', msg: '' });
    event.preventDefault();
});

document.getElementById("runstep").addEventListener("click", function (event) {
    sendData({cmd: 'runstep', msg: '' });
    event.preventDefault();
});

document.getElementById("pause").addEventListener("click", function (event) {
    sendData({cmd: 'pause', msg: '' });
    event.preventDefault();
});

document.getElementById("reset").addEventListener("click", function (event) {
    sendData({cmd: 'reset', msg: '' });
    window.location.reload();
    event.preventDefault();
});

document.getElementById("debug").addEventListener("click", function (event) {
    var debugAddr = document.getElementById("debugAddr").value;
    sendData({ cmd: 'debug', msg: debugAddr });
    modelHide("debugwindow", event);
});

document.getElementById("setvalue").addEventListener("click", function (event) {
    var number = document.getElementById("registerNumber").value;
    var value = document.getElementById("registerValue").value;
    sendData({ cmd: 'setvalue', msg: `${number},${value}` });
    modelHide("setvaluewindow", event);
});

document.getElementById("write").addEventListener("click", function (event) {
    var message = document.getElementById("messageInput").value;
    var startAddr = document.getElementById("startAddr").value;
    var isText = document.getElementById("isText").checked;
    sendData({ cmd: 'write', msg: `${startAddr};${isText};${message}` });
    modelHide("writewindow", event);
});

document.getElementById("book").addEventListener("click", function (event) {
    var cmd = document.getElementById("bookcmd").value;
    var rs1 = document.getElementById("bookrs1").value;
    var rs2 = document.getElementById("bookrs2").value;
    var rd  = document.getElementById("bookrd").value;
    var imm = document.getElementById("bookimm").value;
    sendData({cmd: 'book', msg: `${cmd},${rs1},${rs2},${rd},${imm}`});
    modelHide("bookwindow", event);
});

document.getElementById("translate").addEventListener("click", function (event) {
    var message = document.getElementById("textInput").value;
    sendData({ cmd: 'translate', msg: message });
    modelHide("translatewindow", event);
});

document.getElementById("export").addEventListener("click", function (event) {
    var exportStart = document.getElementById("exportStart").value;
    var exportEnd = document.getElementById("exportEnd").value;
    sendData({ cmd: 'export', msg: `${exportStart},${exportEnd}` });
    modelHide("setvaluewindow", event);
});
