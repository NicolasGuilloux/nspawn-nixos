{ pkgs, modulesPath, ... }:


{
  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./udm-network.nix
    ./nspawn-image.nix
  ];

  boot.isContainer = true;
  boot.kernelModules = [
    "iptable_nat"
    "iptable_filter"
  ];

  # activate Nix Flakes
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  networking.hostName = "UDM-nixos";
  system.stateVersion = "24.05";

  # Set an initial password here or at runtime do `machinectl shell nixos` and run `passwd` there.
  # users.users.root.initialHashedPassword = "";

  # Activate MacVLAN network
  # udm-nixos-nspawn.macVlanNetwork.enable = true;

  # Fix firewall issue
  networking.firewall.package = pkgs.iptables-legacy;
}