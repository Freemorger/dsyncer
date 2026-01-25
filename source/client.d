import std.socket;
import std.stdio;

class Client {
    TcpSocket _conn;
    
    void connect(Address addr) {
        _conn = new TcpSocket();
        _conn.connect(addr);
    }

    void sendloop() {
        for (;;) {
            string input = readln();
            _conn.send(input);
        }
    }
}
