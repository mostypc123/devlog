import std.stdio : writeln;
import std.file : write, readText;
import std.path : expandTilde;
import config;

int main(string[] args)
{
    if (args.length == 1)
    {
        writeln("wrong usage (use -h to show a help message)");
        return 2;
    }
    else
    {
        // args.length is more that 1
        if (args[1] == "-h")
        {
            writeln("devlog - a CLI tool to manage your devlogs");
            writeln("Usage: devlog [COMMAND] [FLAGS]");
            writeln("");
            writeln("Commands:");
            writeln("  add -n NAME -d DIRECTORY  Add a project to the list");
            writeln("  remove -p PROJECT         Remove a project from the list");
            writeln("  update -p PROJECT -m MSG  Update a project's devlog");
        }
        else if (args[1] == "add")
        {
            if (args.length != 6)
            {
                writeln("wrong usage (use -h to show a help message)");
                writeln("hint: add requires -n NAME -d DIRECTORY");
                return 2;
            }
            else
            {
                if (args[2] != "-n" || args[4] != "-d")
                {
                    writeln("wrong usage (use -h to show a help message)");
                    writeln("hint: unknown flags: " ~ args[2] ~ ", " ~ args[4]);
                    return 2;
                }

                if (createConfIfNotExists() != 0)
                {
                    writeln("failed at createConfIfNotExists()");
                    return 1;
                }

                string name = args[3];
                string directory = args[5];

                if (projectExists(name))
                {
                    writeln("project already exists: " ~ name);
                    return 1;
                }

                write(expandTilde("~/.devlog/config"), readText(expandTilde("~/.devlog/config")) ~ "\n" ~ name ~ ":" ~ directory);
                writeln("project added: " ~ name);
                return 0;
            }
        }
        else if (args[1] == "update")
        {
            if (args.length != 6)
            {
                writeln("wrong usage (use -h to show a help message)");
                return 2;
            }
            else
            {
                if (args[2] != "-p" || args[4] != "-m")
                {
                    writeln("wrong usage (use -h to show a help message)");
                    writeln("hint: unknown flags: " ~ args[2] ~ ", " ~ args[4]);
                    return 2;
                }

                string project = args[3];
                string message = args[5];

                if (!projectExists(project))
                {
                    writeln("project does not exist: " ~ project);
                    return 1;
                }

                if (writeToDevlog(project, message) != 0)
                    return 1;

                writeln("updated: " ~ project);
                return 0;
            }
        }
        else if (args[1] == "remove")
        {
            if (args.length != 4)
            {
                writeln("wrong usage (use -h to show a help message)");
                writeln("hint: syntax is devlog remove -p project");
                return 2;
            }
            else
            {
                string project = args[3];

                if (!projectExists(project))
                {
                    writeln("project does not exist: " ~ project);
                    return 1;
                }

                if (removeProject(project) == -1)
                    return 1;

                writeln("removed: " ~ project);
                return 0;
            }
        }
        else
        {
            writeln("unknown command (use -h to show a help message): " ~ args[1]);
            return 2;
        }
    }

    return 0;
}
