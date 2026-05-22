import std.file : exists, mkdirRecurse, readText, write, remove;
import std.path : expandTilde;
import std.stdio : writeln;
import std.algorithm.searching : canFind, startsWith;
import std.string : splitLines, indexOf;
import std.datetime : Clock;
import std.array : split, join;
import std.format : format;

/*
    Creates the config file if it does not exist.
    Returns 0 on success, -1 on failure.
*/
int createConfIfNotExists()
{
    try
    {
        if (!exists(expandTilde("~/.devlog")) || !exists(expandTilde("~/.devlog/config")))
        {
            mkdirRecurse(expandTilde("~/.devlog"));
            write(expandTilde("~/.devlog/config"), "");
            return 0;
        }
    }
    catch (Exception e)
    {
        // Failed to create config file
        return -1;
    }

    // Config file already exists, do nothing
    return 0;
}

/*
    Returns true if the project exists in the config file, false otherwise.
*/
bool projectExists(string name)
{
    string file = expandTilde("~/.devlog/config");
    if (!exists(file))
        return false;

    foreach (line; readText(file).splitLines())
    {
        auto idx = line.indexOf(':');
        if (idx != -1 && line[0 .. idx] == name)
            return true;
    }

    return false;
}

/*
    Write a string to the devlog file of the project.

    Arguments:
        string project - the name of the project
        string message - the message to write

    Returns 0 on success, -1 on general failure and 1 on D exception.
*/
int writeToDevlog(string project, string message)
{
    string file = expandTilde("~/.devlog/config");

    if (!exists(file))
        return -1;

    foreach (line; readText(file).splitLines())
    {
        if (line.length == 0)
            continue;

        auto idx = line.indexOf(':');
        if (idx == -1)
            continue;

        if (line[0 .. idx] == project)
        {
            auto now = Clock.currTime();

            auto prefix = format("[%04d-%02d-%02d %02d:%02d]",
                now.year,
                now.month,
                now.day,
                now.hour,
                now.minute
            );

            string dir = line[idx + 1 .. $];

            string logFile = expandTilde(dir) ~ "/devlog";

            write(
                logFile,
                readText(logFile) ~ prefix ~ " " ~ message ~ "\n"
            );

            return 0;
        }
    }

    return -1;
}

/*
    Remove a project from the devlog config file.

    Arguments:
        string name - the name of the project to remove

    Returns 0 on success, -1 on failure.
*/
int removeProject(string name)
{
    string file = expandTilde("~/.devlog/config");
    if (!exists(file))
        return -1;

    string[] lines;
    bool removed = false;

    foreach (line; readText(file).splitLines())
    {
        auto idx = line.indexOf(':');

        if (idx != -1 && line[0 .. idx] == name)
        {
            removed = true;
            continue;
        }

        lines ~= line;
    }

    if (!removed)
        return -1;

    write(file, lines.join("\n") ~ "\n");
    return 0;
}
