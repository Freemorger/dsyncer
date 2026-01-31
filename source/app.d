import std.stdio;
import std.conv;
import std.socket;
import argpars;

int main(string[] args)
{
    auto app = new ArgsParser();
    app.parse(args);
    app.runArgs();

    return 0;
}
