import std.socket;
import std.stdio;
import std.file;
import std.string;
import std.algorithm;
import std.array;
import std.zip;

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
        string cmd = toks[0].strip();
        switch (cmd) {
            case "!files": {
                if (toks.length < 2) {
                    writefln("Usage: !file filename");
                    break;
                }
                sendFiles(
                        toks[1..$].map!(s => s.strip()).array
                );
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
            case "!help": {
                helpMsg();
                break;
            }
            default:
                writefln("Unknown command: %s", cmd);
                break;
        }
    }


    void sendFiles(string[] fnames) {
        auto zip = new ZipArchive();

        foreach (fname; fnames) {
            if (!exists(fname)) {
                // additional newline to protect from \r 
                writefln("File %s doesn't exist, continuing\n", fname);
                continue;
            } else {
                writefln("\rAdding file %s to archive", fname);
            } 

            auto member = new ArchiveMember();
            member.name = fname;
            member.expandedData = cast(ubyte[])read(fname);
            member.compressionMethod = CompressionMethod.deflate;

            zip.addMember(member);
        }

        void[] zipDat = zip.build();

        ubyte[] buf = [
            2 // file 
        ]; // header 
        buf ~= "tmp_dsync_arc.zip".representation; // adding fname to header 
        buf ~= [0];

        ubyte[] fbuf = cast(ubyte[])zipDat; 
        buf ~= fbuf; 
        buf ~= [0];
        buf ~= END_TAG.representation;

        writefln("\rSending compressed data to remote server");
        _conn.send(buf);
        writefln("\rCompressed data sent to sever.");
    }
    
    void sendMsg(string msg) {
        msg = char(1) ~ msg;
        msg ~= 0;
        msg ~= END_TAG.representation;
        _conn.send(msg);
    }

    void helpMsg() {
        writefln("HELP:
                !say MSG - sends text message to server
                !files FNAME [FNAME2 ..] - sends files to server 
                !exit - exit app and close connection");
    }
}
