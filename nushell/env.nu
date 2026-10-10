# ~/.config/nushell/env.nu

# Editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Pager
$env.PAGER = "less"

# Enable nice backtraces for Rust tools
$env.RUST_BACKTRACE = "1"

# Path setup
$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $"($env.HOME)/.local/bin"
  | prepend $"($env.HOME)/.cargo/bin"
  | prepend $"($env.HOME)/go/bin"
  | uniq
)

$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
mkdir $"($nu.cache-dir)"
carapace _carapace nushell | save --force $"($nu.cache-dir)/carapace.nu"

# ${UserConfigDir}/nushell/config.nu

# source $"($nu.cache-dir)/carapace.nu"
# fnm - config
# fnm env --shell nu | save --force $"($nu.cache-dir)/fnm.nu"



# Add fnm binary path to Nushell's PATH environment variable
$env.PATH = ($env.PATH | prepend [
    $"($env.HOME)/.local/share/fnm"
    $"($env.HOME)/.fnm"
])


# XDG paths
$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.XDG_DATA_HOME = $"($env.HOME)/.local/share"
$env.XDG_CACHE_HOME = $"($env.HOME)/.cache"

# Starship prompt
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
