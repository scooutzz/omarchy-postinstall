# omarchy-postinstall

Postinstall pessoal para Omarchy. O Zsh usa uma configuração modular em
`config/new-zsh`, com Zinit para autosuggestions e syntax highlighting e o
Starship instalado pelo sistema.

## Instalação

Para executar todas as etapas do postinstall:

```bash
cd ~/omarchy-postinstall
./install.sh
```

Para instalar ou reaplicar apenas o Zsh, de qualquer diretório:

```bash
~/omarchy-postinstall/install-newzsh.sh
```

O instalador garante os pacotes necessários pelo `omarchy pkg add`, instala o
Zinit se estiver ausente e usa o próprio Zinit para instalar os dois plugins.
Dependências existentes são reaproveitadas, sem atualização automática. A
abertura do terminal apenas carrega as dependências já instaladas.

Os links e a configuração são aplicados antes da troca do shell padrão para
Zsh. Essa troca pode pedir a senha do usuário. Use `exec zsh` para abrir a nova
configuração no terminal atual; encerre a sessão e entre novamente para aplicar
a mudança do shell padrão às próximas sessões.

Opções:

```bash
# Aplicar sem mudar o shell padrão da conta.
./install-newzsh.sh --no-change-shell

# Reaplicar somente os arquivos, com as dependências já instaladas.
./install-newzsh.sh --skip-deps --no-change-shell
```

`install-zsh.sh` continua disponível e encaminha para o novo instalador. O
antigo `config/zsh` permanece como referência e não é instalado.

## Estrutura do Zsh

| Origem | Destino | Função |
| --- | --- | --- |
| `config/new-zsh/home.zshenv` | `~/.zshenv` | Define `ZDOTDIR` e carrega o bootstrap |
| `config/new-zsh/.zshenv` | `~/.config/zsh/.zshenv` | Ambiente básico para qualquer invocação |
| `config/new-zsh/.zshrc` | `~/.config/zsh/.zshrc` | Ambiente interativo e ordem de carregamento |
| `config/new-zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | Atalhos de comandos |
| `config/new-zsh/completion.zsh` | `~/.config/zsh/completion.zsh` | Completions do Zsh e do Omarchy |
| `config/new-zsh/functions.zsh` | `~/.config/zsh/functions.zsh` | `ff`, `eff`, `z`, `mkcd` |
| `config/new-zsh/keybindings.zsh` | `~/.config/zsh/keybindings.zsh` | Atalhos de teclado |
| `config/new-zsh/omarchy.zsh` | `~/.config/zsh/omarchy.zsh` | Funções originais do Omarchy |
| `config/new-zsh/plugins.zsh` | `~/.config/zsh/plugins.zsh` | Carregamento dos plugins pelo Zinit |
| `config/starship/starship.toml` | `~/.config/starship.toml` | Aparência do prompt |

Os caminhos respeitam `XDG_CONFIG_HOME` e `XDG_DATA_HOME`, quando definidos.
`~/.config/zsh` é um diretório real com links individuais: `.zsh_history` e
`.zcompdump` ficam nele, fora do repositório. Um histórico antigo em
`~/.zsh_history` é copiado somente se ainda não existir histórico no destino.

Arquivos substituídos recebem backup `nome.bak.AAAAMMDD-HHMMSS`. Links já
corretos são mantidos e o histórico existente não é sobrescrito. O instalador
recusa um destino `~/.config/zsh` que seja link de diretório, para evitar gravar
histórico e cache no repositório por acidente.

## Comportamento e atalhos

- `cd` é alias de `z`; a setinha segue as regras do Bash do Omarchy.
- Setas cima/baixo e `Ctrl+K/J` pesquisam pelo prefixo digitado.
- `Ctrl+L` aceita a sugestão sem executar o comando.
- `Ctrl+R` pesquisa o histórico pelo fzf; `Ctrl+T` insere caminhos.
- `Ctrl+X Ctrl+E` edita a linha no editor e devolve ao prompt para revisão.
- `..` e `...` sobem um e dois diretórios; `mkcd` cria e entra em uma pasta.
- Histórico: 65536 entradas em memória, 32768 no arquivo, compartilhado entre
  sessões. Comandos iniciados com espaço são omitidos do histórico persistido.
- Comentários interativos e completion no meio da palavra estão habilitados.

`env-bootstrap` e `envs` são carregados da instalação do Omarchy. Mise e
zoxide têm inicialização nativa para Zsh. Compressão usa a implementação
original compatível; discos, reconexão SSH e encaminhamento de portas executam
os arquivos originais em um Bash isolado que herda o ambiente. O completion do
Omarchy também consulta o gerador instalado, incluindo subcomandos e opções.

Starship usa `/usr/bin/starship`; o Zinit gerencia exclusivamente
`zsh-autosuggestions` e `zsh-syntax-highlighting`. Para atualizar esses plugins,
use `zinit update zsh-users/zsh-autosuggestions` e
`zinit update zsh-users/zsh-syntax-highlighting` dentro do Zsh.

## Outras etapas

O `install.sh` mantém os instaladores individuais de remoção de preinstalados,
fcitx5, Neovim, tmux, Hyprland, Tailscale, Bitwarden, MongoDB Compass e Helium.
Essas etapas também podem ser executadas pelos respectivos `install-*.sh`.
