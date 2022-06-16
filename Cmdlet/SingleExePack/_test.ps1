nsl $env:temp\pack
ipmo Metaseed.Utility -fo
new-pack $env:PLANCK_APP_DIR\Slb.Planck.Acquisition.Downlink.Service -keepConsole
# new-pack $env:PLANCK_APP_DIR\Slb.Planck.Presto.ControlGateway.Service -keepConsole