
# Carapace completions
source $"($nu.cache-dir)/carapace.nu"
# Load Starship prompt
source ~/.cache/starship/init.nu

# Load fnm node version manager 
# source $"($nu.cache-dir)/fnm.nu"

# Core behavior
$env.config = {
  show_banner: false

  edit_mode: vi

  history: {
    max_size: 100_000
    sync_on_enter: true
    file_format: "sqlite"
    isolation: false
  }

  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "fuzzy"
    external: {
      enable: true
      max_results: 100
    }
  }

  cursor_shape: {
    emacs: line
    vi_insert: line
    vi_normal: block
  }

  table: {
    mode: rounded
    index_mode: always
    show_empty: true
    padding: {
      left: 1
      right: 1
    }
  }

  

  datetime_format: {
    normal: "%Y-%m-%d %H:%M:%S"
    table: "%Y-%m-%d %H:%M"
  }

  rm: {
    always_trash: false
  }

  hooks: {
    pre_prompt: []
    pre_execution: []
    env_change: {
      PWD: []
    }
    display_output: "if (term size).columns >= 100 { table -e } else { table }"
    command_not_found: null
  }
}

# Navigation
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

# Listing
alias ll = ls -la
alias la = ls -a
alias l = ls

# Git
alias g = git
alias gs = git status
alias ga = git add
alias gc = git commit
alias gp = git push
alias gl = git log --oneline --graph --decorate
alias gd = git diff
alias gco = git checkout

# System
alias cls = clear
alias h = history
alias c = clear
alias q = exit

# Safer defaults
alias cp = cp -i
alias mv = mv -i
alias rm = rm -i
