# omarchy-postinstall

Configura uma instalação do Omarchy com Zsh, Oh My Zsh e os dotfiles deste
repositório. O Zsh preserva ambiente, aliases, funções e ferramentas do Bash do
Omarchy, acrescentando vi-mode, autosuggestions e syntax highlighting.

## Uso

```bash
git clone <url-do-repositorio> ~/omarchy-postinstall
cd ~/omarchy-postinstall
./install.sh
```

Também é possível executar uma etapa isoladamente:

```bash
./install-zsh.sh
./install-dotfiles.sh
```

O instalador principal executa primeiro a instalação do zsh e depois cria os
links dos dotfiles. Ele pode ser executado novamente sem recriar links ou
reclonar dependências que já estejam instaladas.

## Como os dotfiles são aplicados

- `config/nvim`, `config/tmux` e `config/foot` viram links de diretório em
  `~/.config/`.
- Os arquivos de `config/hypr` são ligados individualmente em
  `~/.config/hypr`, preservando os outros arquivos gerenciados pelo Omarchy.
- Os arquivos de `config/zsh` são ligados individualmente no diretório pessoal,
  por exemplo `~/.zshrc` e `~/.zshenv`.

Quando já existe algo no destino, o instalador move esse caminho para um backup
com o formato `nome.bak.AAAAMMDD-HHMMSS` antes de criar o link. Backups antigos
nunca são sobrescritos.

Para adicionar outra configuração parcial, inclua o aplicativo no mapa
`PARTIAL_TARGETS` de `install-dotfiles.sh`. As demais pastas em `config/` são
automaticamente tratadas como configurações completas.

## Observações

- O script pressupõe uma instalação do Omarchy e usa `omarchy pkg add zsh`.
- Os aliases e as funções são carregados da versão instalada do Omarchy. As
  integrações que dependem do shell (`mise`, `zoxide`, `fzf`, `starship`, `try`
  e completion) têm inicialização própria para Zsh.
- A troca do shell padrão pode pedir a senha do usuário.
- Depois da primeira execução, encerre a sessão e entre novamente para que o
  novo shell padrão seja usado.
