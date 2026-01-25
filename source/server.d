import std.socket;
import std.stdio;

class Server {
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
            char[1024] buf = 0;
            auto ctr = client.receive(buf);
            if (ctr == Socket.ERROR) {
                writefln("Connection error");
                break;
            } else if (ctr > 0) {
                write(buf[0..ctr]);
            } else {
                break;
            }
        }
    }
}
