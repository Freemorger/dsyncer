import std.socket;
import std.stdio;
import std.file;
import std.string;

class Client {
    const string END_TAG = "DSYNC$END";
    TcpSocket _conn;
    bool _runs = true;
    
    void connect(string host, ushort port) {
        _conn = new TcpSocket();
        auto addr = getAddress(host, port)[0];
        _conn.connect(addr);
        writefln("Connected to %s:%s", host, port);
    }

    void sendloop() {
        while (_runs) {
            string input = readln();
            handleCommand(input);
        }
    }

    void handleCommand(string input) {
        if (input == "") {
            return;
        }

        if (!input.startsWith("!")) {
            ubyte[] buf = [1]; // text
            buf ~= input.representation;
            _conn.send(buf);
            return;
        } 
        string[] toks = input.split(" ");
        switch (toks[0]) {
            case "!file": {
                if (toks.length < 2) {
                    writefln("Usage: !file filename");
                    break;
                }
                sendFile(toks[1]);
                break;
            }
            case "!say": {
                sendMsg(toks[1..toks.length].join(" "));
                break;
            }
            case "!exit": {
                _conn.close();
                _runs = false;
                break;
            }
            default:
                writefln("Unknown command: %s", toks[0]);
                break;
        }
    }


    void sendFile(string fname) {
        if (!exists(fname)) {
            writefln("File %s doesn't exist.", fname);
            return;
        }

        ubyte[] buf = [
            2 // file 
        ]; // header 
        buf ~= fname.representation; // adding fname to header 
        buf ~= [0];

        ubyte[] fbuf = cast(ubyte[])read(fname); 
        buf ~= fbuf; 
        buf ~= [0];
        buf ~= END_TAG.representation;
        _conn.send(buf);
    }
    
    void sendMsg(string msg) {
        msg = char(1) ~ msg;
        msg ~= 0;
        msg ~= END_TAG.representation;
        _conn.send(msg);
    }
}
