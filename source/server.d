import std.socket;
import std.stdio;
import std.file;
import std.string;

class Server {
    const string END_TAG = "DSYNC$END";
    TcpSocket _sock;
    ushort _port;

    void inits(ushort port) {
        _port = port;
        _sock = new TcpSocket();
        assert(_sock.isAlive);
        _sock.bind(new InternetAddress(port));
        _sock.blocking = true;
    }

    void run() {
        _sock.listen(1);
        writefln("Server listening on port %d", _port);
        auto client = _sock.accept();  // currently only one con supported
        for (;;) {
            ubyte[1024] buf;
            auto ctr = client.receive(buf);
            if (ctr == Socket.ERROR) {
                writefln("Connection error");
                break;
            } else if (ctr > 0) {
                matchDataType(buf); // TODO: put here real data buffer
            } else {
                break;
            }
        }
    }

    void matchDataType(ubyte[] buf) {
        if (buf.length == 0) {
            writefln("The buffer is empty!");
            return;
        }

        switch (buf[0]) { // TODO
            case 1: {
                string sbuf = "";
                for (uint i = 1; i < buf.length; i++) {
                    ubyte cur = buf[i];
                    if ((cur == 0) && chkEndPattern(buf, i)) {
                        writefln("break");
                        break;
                    }
                    sbuf ~= cur;
                }  
                writefln(sbuf);
                break;
            }
            case 2: {
                handleFile(buf);
                break;
            }
            default:
                writefln("ERROR: Unknown datatype %u", buf[0]);
                break;
        }
    }

    bool chkEndPattern(ubyte[] buf, ulong start) {
        ulong end = start + END_TAG.length + 1; 
        if (end > buf.length) {
            return false;
        }
        return buf[(start + 1)..end] == END_TAG.representation;
        // adding 1 to avoid 0
    }

    void handleFile(ubyte[] buf) {
        string namebuf = "";
        int i = 1;
        for (; i < buf.length; i++) {
            ubyte cur = buf[i];
            if (cur == 0) {
                break;
            }
            namebuf ~= cur;
        }

        ubyte[] fbuf = [];
        int j = i + 1;
        for (; j < buf.length; j++) {
            ubyte cur_byte = buf[j];
            if (cur_byte == 0) {
                break;
            }
            fbuf ~= cur_byte;
        }

        std.file.write(namebuf, fbuf);
        // TODO: get remaining data
    }
}
