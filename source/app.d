import std.stdio;
import server;
import client;
import std.conv;
import std.socket;

int main(string[] args)
{
    if (args.length > 2 && args[1] == "-serv" ) {
        auto serv = new Server();
        ushort port = args[2].to!ushort; 
        serv.inits(port);
        serv.run();
    } else if (args.length > 3 && args[1] == "-con") {
        auto client = new Client();
        client.connect(args[2], args[3].to!ushort);
        if (args.length > 5 && args[4] == "-f") {
            client.sendFile(args[5]);
        } else {
            client.sendloop();
        }
    } else {
        usage_msg();
        return 1;
    }

    return 0;
}

void usage_msg() {
    writefln("Usage: dsyncer [-serv port]\n
                            [-con addr port]");
}
