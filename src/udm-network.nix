{ config, lib, ... }:

let
  cfg = config.udm-nixos-nspawn.macVlanNetwork;
  adapter = "mv-br${toString cfg.vlan}";
in
{
  options.udm-nixos-nspawn.macVlanNetwork = {
    enable = lib.mkEnableOption "Enable MacVLAN Network";

    vlan = lib.mkOption {
      description = "Vlan to use for the VM";
      type = lib.types.int;
      example = 255;
      default = 255;
    };

    address = lib.mkOption {
      description = "IP address of the VM";
      type = lib.types.str;
      example = "10.0.255.3";
      default = "10.0.${toString cfg.vlan}.3";
    };

    gateway = lib.mkOption {
      description = "IP address of the VM";
      type = lib.types.str;
      example = "10.0.255.1";
      default = "10.0.${toString cfg.vlan}.1";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.network.networks."${adapter}" = {
      matchConfig.Name = "mv-br${cfg.vlan}";
      networkConfig = {
        IPForward = "yes";
        Address = "${cfg.address}/24";
        Gateway = cfg.gateway;
      };
    };

    networking.interfaces."${adapter}".ipv4.addresses = [
      {
        address = cfg.address;
        prefixLength = 24;
      }
    ];

    networking.defaultGateway = {
         address = cfg.gateway;
         interface = "${adapter}";
    };

    networking.nameservers = [ cfg.gateway ];
  };
}