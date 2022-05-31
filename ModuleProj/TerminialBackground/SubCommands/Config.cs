
using System;
using System.CommandLine;

public class ConfigCommand : Command
{
  public string Path;
  public ConfigCommand() : base("config", "terminal background configuration folder")
  {
    AddAlias("c");
    this.SetHandler((string path) =>
    {
      Path = path;
      Console.WriteLine(path);
    });
  }
}