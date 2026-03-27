$env:STARSHIP_CONFIG = "$PSScriptRoot/.config/starship.toml"
# need to set to error to avoid the noise, because $env:RUST_LOG = trace (set by Cursor), Starship is a Rust application, and when STARSHIP_LOG is not explicitly set, it falls back to RUST_LOG via the underlying Rust logging framework.
$env:STARSHIP_LOG = "error" # "trace"
$ENV:STARSHIP_CACHE = "$PSScriptRoot\.log"

. $PSScriptRoot/.config/starship-init.ps1
# Enable-TransientPrompt
