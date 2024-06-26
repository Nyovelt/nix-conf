{ config, pkgs, lib, home-manager,  ... }:

let
  user = "canarypwn";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;


    casks = pkgs.callPackage ./casks.nix {};

    brews = pkgs.callPackage ./brews.nix {};

    onActivation = {
        autoUpdate = true;
        upgrade = true;
        cleanup = "uninstall";
      };

    #taps = [];
    # taps = {
    #           "homebrew/homebrew-core" = homebrew-core;
    #           "homebrew/homebrew-cask" = homebrew-cask;
    #           "homebrew/cask-fonts" = cask-fonts;
    #         };

    



    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "wireguard" = 1451685025;
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "OneDrive" = 823766827;
      "Microsoft Remote Desktop" = 1295203466;
      "Copilot: Track & Budget Money" = 1447330651;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];
        stateVersion = "23.11";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local.dock.enable = true;
  local.dock.entries = [
    {path = "/Applications/Setapp/Spark%20Mail.app/";}
    {path = "/System/Applications/Calendar.app/";}
    { path = "/Applications/Slack.app/"; }
    { path = "/Applications/Warp.app/"; }
    { path = "/System/Applications/Music.app/"; }
    {path = "/Applications/telegram.app/"; }
    {path = "/Applications/discord.app/"; }
    {path = "/Applications/Obsidian.app/";}
    {path = "/Applications/zotero.app/";}
    {
      path = "/Applications/";
      section = "others";
      options = "--sort name --view grid --display folder";
    }

  ];

}
