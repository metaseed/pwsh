
using System;
using System.CommandLine;
using Metaseed.TerminalBackground;

public class StartSubCommand : Command
{
    public StartSubCommand() : base("startCyclic", "start terminal background cyclically changing based on configuration")
    {
        AddAlias("sa");
        AddAlias("start");
        AddOption(new Option<string>(new[] { "-settingsPath", "-settings", "-s" }, "the settings for cyclic background image"));

        this.SetHandler((string settingsPath) =>
        {
            new Client().StartCyclic(settingsPath);
            //return WtBackgroundImage.StartCyclic;
        });
    }
}

public class StopSubCommand : Command
{
    public StopSubCommand() : base("stopCyclic", "stop terminal background cyclically changing based on configuration")
    {
        AddAlias("sp");
        AddAlias("stop");

        this.SetHandler(() =>
        {
            new Client().StopCyclic();
            //return WtBackgroundImage.StopCyclic;
        });
    }
}
public class SetBackgroundImageSubCommand : Command
{
    public SetBackgroundImageSubCommand() : base("SetBackgroundImage", "Set background image directly")
    {
        AddAlias("sbg");
        AddOption(new Option<string>(new[] { "-p", "-profile" }, "the profile to modify"));
        AddOption(new Option<float>(new[] { "-d", "-duration", "-durationInSeconds" }, "duration in seconds"));
        AddOption(new Option<float>(new[] { "-v", "-value", "-jsonProfileValueString" }, "json string value to modify the profile"));

        this.SetHandler((string profile, float durationInSeconds, string jsonProfileValueString) =>
        {
            new Client().SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString);
            //WtBackgroundImage.SetBackgroundImage(profile, durationInSeconds, jsonProfileValueString);
        });
    }
}