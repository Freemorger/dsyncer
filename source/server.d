import std.socket;
import std.stdio : writefln, write, writeln;
import std.file;
import std.string;
import std.zip;
import std.logger;

class Server {
    const string END_TAG = "DSYNC$END";
    TcpSocket _sock;
    ushort _port;
    bool _err = false; // error flag 
    bool _shouldStop = false;
    bool _verbose = false;

    void inits(ushort port, bool verbose) {
        _verbose = verbose;
        _port = port;
        _sock = new TcpSocket();
        assert(_sock.isAlive);
        _sock.bind(new InternetAddress(port));
        _sock.blocking = true;
    }

    void run() {
        _sock.listen(1);
        info("Server listening on port %d", _port);

        while (!_shouldStop) {
            _err = false;
            Socket client = _sock.accept();  // currently only one con supported

            info("Client connected");
            while (!_err) {
                auto buf = getPacket(client);
                if (!_err) matchDataType(buf); 
            }

            info("Client disconnected. Awaiting next connection...");
        }
    }

    void matchDataType(ubyte[] buf) {
        if (buf.length == 0) {
            writefln("The buffer is empty!");
            return;
        }

        switch (buf[0]) {
            case 1: {
                string sbuf = "";
                for (uint i = 1; i < buf.length; i++) {
                    ubyte cur = buf[i];
                    if ((cur == 0) && chkEndPattern(buf, i)) {
                        break;
                    }
                    sbuf ~= cur;
                }  
                writeln(sbuf);
                break;
            }
            case 2: {
                handleFile(buf);
                break;
            }
            default:
                error("ERROR: Unknown datatype %u", buf[0]);
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

    ubyte[] getPacket(Socket client) {
        ubyte[] res = [];
        bool flag = true;
        while (flag) {
            ubyte[1024] tmp;
            auto recvd = client.receive(tmp);
            //writefln("Received: %d bytes", recvd);
            if (recvd == Socket.ERROR) {
                throw new Exception("Connection error!");
                _err = true;
                return res;
            } else if (recvd <= 0) {
                info("Connection lost");
                _err = true; 
                return res;
            }

            for (int i = 0; i < recvd; i++) {
                ubyte cur_b = tmp[i];
                if (cur_b == 0 && chkEndPattern(tmp, i)) {
                    flag = false;
                    break;
                } else res ~= cur_b;
                
            }
        }
        return res;
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
            fbuf ~= cur_byte;
        }

        auto zip = new ZipArchive(fbuf);
        foreach (name, member; zip.directory) {
            infof(_verbose, "Extracting %s", name);

            ubyte[] expanded = zip.expand(member);

            std.file.write(name, expanded);
        }
        infof(_verbose, "Files received and decompressed, done.");
    }
}
