# Zinit installs plugins during postinstall; shell startup only loads them.
if [[ ! -r "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh" ]]; then
  print -u2 -- 'Zinit is missing; run omarchy-postinstall/install-newzsh.sh.'
  return 0
fi
source "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Syntax highlighting remains the last plugin.
for zsh_plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  if [[ -r "${ZINIT[PLUGINS_DIR]}/zsh-users---$zsh_plugin/$zsh_plugin.zsh" ]]; then
    zinit light "zsh-users/$zsh_plugin"
  else
    print -u2 -- "Missing $zsh_plugin; run omarchy-postinstall/install-newzsh.sh."
  fi
done
unset zsh_plugin
