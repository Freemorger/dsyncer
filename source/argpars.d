// Simple command line args parser

import std.conv;
import std.stdio;
import server;
import client;

class ArgsParser {
    bool _isServ;
    bool _verbose = false;
    string _ip;
    ushort _port;
    string[] _files;

    /// Tries parsing args and returns whether it was successful
    bool parse(string[] args) {
        int i = 1;
        for (; i < args.length; i++) {
            auto arg = args[i];
            switch (arg) {
                case "-serv": {
                    if ((i+1) >= args.length) {
                        writefln("Usage: dsyncer -serv PORT [-verbose]");
                        return false;
                    }
                    _port = args[i+1].to!ushort;
                    _isServ = true;
                    i++;
                    break;
                }
                case "-con": {
                    if ((i+2) >= args.length) {
                        writefln("Usage: dsyncer -con IP PORT [-f]");
                        return false;
                    }
                    if (_isServ) {
                        writefln("Run either server or client once");
                        return false;
                    }

                    _ip = args[i+1];
                    _port = args[i+2].to!ushort;
                    i += 2;
                    break;
                }
                case "-verbose": {
                    if (!_isServ) {
                        writefln("Only server could be verbose");
                        return false;
                    }

                    _verbose = true;
                    break;
                }
                case "-f": {
                    if (_isServ) {
                        writefln("Option `-f` is only meant to send files
                                to server from client");
                        return false;
                    }

                    int j = i;
                    for (; j < args.length; j++) {
                        _files ~= args[j];
                    }
                    i = j;

                    break;
                }
                default: {
                    writefln("Unknown arg %s", arg);
                    return false;
                }
            }
        }
        return true;
    }

    /// Runs client/server based on args
    void runArgs() {
        if (_isServ) {
            Server serv = new Server();
            serv.inits(_port, _verbose);
            serv.run();
        } else {
            if (_port == 0 || _ip == "") {
                writefln("Specify IP and Port. Eg: dsyncer -con IP PORT");
                return;
            }

            Client client = new Client();
            client.connect(_ip, _port);
            if (_files.length > 0) {
                client.sendFiles(_files);
            } else {
                client.sendloop();
            }
        }
    }
}
