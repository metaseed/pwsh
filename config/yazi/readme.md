> Set-Env YAZI_CONFIG_HOME M:/Script/Pwsh/config/yazi
>
## Quick Start
https://yazi-rs.github.io/docs/quick-start

## Key Map Default
https://github.com/sxyazi/yazi/blob/main/yazi-config/preset/keymap-default.toml

## debug
$env:YAZI_LOG = "debug"; yazi
use ya.dbg() and ya.err()

 a yazi --debug command that includes all your environment information, such as terminal emulator, image adapter, whether you're in SSH mode, etc.