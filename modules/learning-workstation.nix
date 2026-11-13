{ pkgs, identity, ... }:
let
  vimarshaCheck = pkgs.writeShellApplication {
    name = "vimarsha-check";
    runtimeInputs = [ pkgs.coreutils pkgs.gnugrep pkgs.inetutils pkgs.vscodium pkgs.bun pkgs.git pkgs.python3 pkgs.jdk21 ];
    text = ''
      printf '\nVIMARSHA LEARNING COMPUTER\n'
      printf 'Configuration: vimarsha-learning-workstation\n'
      printf 'Host: %s\n' "$(hostname -s)"
      printf 'Account: %s\n' "$(id -un)"
      version="$(grep '^VERSION=' /etc/os-release | cut -d= -f2 | tr -d '\"')"
      printf 'NixOS: %s\n' "$version"
      printf 'Desktop: KDE Plasma\nIDE: VSCodium\n'
      printf '\nQuick checks:\n'
      for command in codium bun git python3 java; do
        if command -v "$command" >/dev/null 2>&1; then
          printf '  OK  %-10s %s\n' "$command" "$(command -v "$command")"
        else
          printf '  MISSING  %s\n' "$command"
        fi
      done
      printf '\nOpen Vimarsha’s project folder with: codium ~/Documents/Projects/Vimarsha\n'
      printf 'Run `vimarsha-welcome` for the first-use tour.\n'
    '';
  };
  vimarshaWelcome = pkgs.writeShellApplication {
    name = "vimarsha-welcome";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      cat <<'WELCOME'

      Welcome, Vimarsha!

      1. Check this is your computer:       vimarsha-check
      2. Open your coding workspace:        codium ~/Documents/Projects/Vimarsha
      3. Try JavaScript:                    bun --version
      4. Check Java and Python:             java --version  /  python3 --version
      5. Refresh NixOS when you choose:     refresh

      Your tools are ready before you begin. You can start with a drawing or a
      question, work on paper, and use the computer when you want to test an idea.
      Save your own work in Documents/Projects/Vimarsha. Ask for help whenever
      something is unclear; you do not need a finished answer first.

      WELCOME
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    # A friendly graphical desktop and creative toolkit.
    firefox chromium libreoffice krita inkscape gimp vlc
    kdePackages.kate kdePackages.dolphin kdePackages.konsole kdePackages.okular kdePackages.spectacle

    # IDE and the complete journey programming stack.
    vscodium bun nodejs git git-lfs gh python3 python3Packages.numpy
    python3Packages.matplotlib python3Packages.pandas python3Packages.sympy
    python3Packages.jupyterlab python3Packages.pipx uv
    jdk21 maven gradle

    # School, documents, graphs, and project build tools.
    pandoc texliveSmall gnuplot graphviz jq yq tree ripgrep fd
    gnumake gcc gdb cmake pkg-config shellcheck shfmt
    unzip zip p7zip rsync curl wget file which
    nerd-fonts.jetbrains-mono
    vimarshaCheck vimarshaWelcome
  ];

  environment.variables.EDITOR = "codium --wait";
  environment.variables.VISUAL = "codium --wait";
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  programs.bash.interactiveShellInit = ''
    alias refresh='sudo nixos-rebuild switch'
    alias study='vimarsha-welcome'
  '';
  programs.zsh.enable = true;
  programs.zsh.interactiveShellInit = ''
    alias refresh='sudo nixos-rebuild switch'
    alias study='vimarsha-welcome'
  '';

  environment.etc."xdg/vscodium/product.json".text = ''
    { "extensionsGallery": { "serviceUrl": "https://open-vsx.org/vscode/gallery", "itemUrl": "https://open-vsx.org/vscode/item" } }
  '';
}
