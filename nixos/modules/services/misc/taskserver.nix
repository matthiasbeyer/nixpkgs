{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.taskserver;

  taskd = "${pkgs.taskserver}/bin/taskd";

  mkVal = val:
    if val == true then "true"
    else if val == false then "false"
    else if isList val then concatStringsSep ", " val
    else toString val;

  mkConfLine = key: val: let
    result = "${key} = ${mkVal val}";
  in optionalString (val != null && val != []) result;

  needToCreateCA = all isNull (with cfg; [
    server.key server.cert server.crl caCert
  ]);

  configFile = pkgs.writeText "taskdrc" ''
    # systemd related
    daemon = false
    log = -

    # logging
    ${mkConfLine "debug" cfg.debug}
    ${mkConfLine "ip.log" cfg.ipLog}

    # general
    ${mkConfLine "ciphers" cfg.ciphers}
    ${mkConfLine "confirmation" cfg.confirmation}
    ${mkConfLine "extensions" cfg.extensions}
    ${mkConfLine "queue.size" cfg.queueSize}
    ${mkConfLine "request.limit" cfg.requestLimit}

    # client
    ${mkConfLine "client.cert" cfg.client.cert}
    ${mkConfLine "client.allow" cfg.client.allow}
    ${mkConfLine "client.deny" cfg.client.deny}

    # server
    server = ${cfg.server.host}:${toString cfg.server.port}
    ${mkConfLine "server.crl" cfg.server.crl}

    # certificates
    ${if needToCreateCA then ''
    ca.cert = ${cfg.dataDir}/keys/ca.cert
    server.cert = ${cfg.dataDir}/keys/server.cert
    server.key = ${cfg.dataDir}/keys/server.key
    '' else ''
    ca.cert = ${cfg.caCert}
    server.cert = ${cfg.server.cert}
    server.key = ${cfg.server.key}
    ''}
  '';

in {

  options = {
    services.taskserver = {

      enable = mkEnableOption "the Taskwarrior server";

      user = mkOption {
        type = types.str;
        default = "taskd";
        description = "User for Taskserver.";
      };

      group = mkOption {
        type = types.str;
        default = "taskd";
        description = "Group for Taskserver.";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/taskserver";
        description = "Data directory for Taskserver.";
      };

      caCert = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Fully qualified path to the CA certificate.";
      };

      ciphers = mkOption {
        type = types.nullOr types.string;
        default = null;
        example = "NORMAL";
        description = ''
          List of GnuTLS ciphers to use. See the GnuTLS documentation for full
          details.
        '';
      };

      confirmation = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Determines whether certain commands are confirmed.
        '';
      };

      debug = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Logs debugging information.
        '';
      };

      extensions = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Fully qualified path of the Taskserver extension scripts.
          Currently there are none.
        '';
      };

      ipLog = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Logs the IP addresses of incoming requests.
        '';
      };

      queueSize = mkOption {
        type = types.int;
        default = 10;
        description = ''
          Size of the connection backlog, see <citerefentry>
            <refentrytitle>listen</refentrytitle>
            <manvolnum>2</manvolnum>
          </citerefentry>.
        '';
      };

      requestLimit = mkOption {
        type = types.int;
        default = 1048576;
        description = ''
          Size limit of incoming requests, in bytes.
        '';
      };

      client = {

        allow = mkOption {
          type = types.listOf types.str;
          default = [];
          example = [ "[Tt]ask [2-9]+" ];
          description = ''
            A list of regular expressions that are matched against the reported
            client id (such as <literal>task 2.3.0</literal>).

            The values <literal>all</literal> or <literal>none</literal> have
            special meaning. Overidden by any entry in the option
            <option>services.taskserver.client.deny</option>.
          '';
        };

        cert = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Fully qualified path of the client cert. This is used by the
            <command>client</command> command.
          '';
        };

        deny = mkOption {
          type = types.listOf types.str;
          default = [];
          example = [ "[Tt]ask [2-9]+" ];
          description = ''
            A list of regular expressions that are matched against the reported
            client id (such as <literal>task 2.3.0</literal>).

            The values <literal>all</literal> or <literal>none</literal> have
            special meaning. Any entry here overrides these in
            <option>services.taskserver.client.allow</option>.
          '';
        };

      };

      server = {
        host = mkOption {
          type = types.string;
          default = "localhost";
          description = ''
            The address (IPv4, IPv6 or DNS) of the Taskserver.
          '';
        };

        port = mkOption {
          type = types.int;
          default = 53589;
          description = ''
            Port number of the Taskserver.
          '';
        };

        cert = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = "Fully qualified path to the server certificate";
        };

        crl = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Fully qualified path to the server certificate revocation list.
          '';
        };

        key = mkOption {
          type = types.nullOr types.path;
          default = null;
          description = ''
            Fully qualified path to the server key.

            Note that reloading the <literal>taskserver.service</literal> causes
            a configuration file reload before the next request is handled.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ pkgs.taskserver ];

    users.users = optional (cfg.user == "taskd") {
      name = "taskd";
      uid = config.ids.uids.taskd;
      description = "Taskserver user";
      group = cfg.group;
    };

    users.groups = optional (cfg.group == "taskd") {
      name = "taskd";
      gid = config.ids.gids.taskd;
    };

    systemd.services.taskserver-ca = mkIf needToCreateCA {
      requiredBy = [ "taskserver.service" ];
      after = [ "taskserver-init.service" ];
      description = "Initialize CA for TaskServer";
      serviceConfig.Type = "oneshot";
      serviceConfig.UMask = "0077";

      script = ''
        mkdir -m 0700 -p "${cfg.dataDir}/keys"
        chown root:root "${cfg.dataDir}/keys"

        if [ ! -e "${cfg.dataDir}/keys/ca.key" ]; then
          ${pkgs.gnutls}/bin/certtool -p \
            --bits 2048 \
            --outfile "${cfg.dataDir}/keys/ca.key"
          ${pkgs.gnutls}/bin/certtool -s \
            --template "${pkgs.writeText "taskserver-ca.template" ''
              cn = ${cfg.server.host}
              cert_signing_key
              ca
            ''}" \
            --load-privkey "${cfg.dataDir}/keys/ca.key" \
            --outfile "${cfg.dataDir}/keys/ca.cert"

          chgrp "${cfg.group}" "${cfg.dataDir}/keys/ca.cert"
          chmod g+r "${cfg.dataDir}/keys/ca.cert"
        fi

        if [ ! -e "${cfg.dataDir}/keys/server.key" ]; then
          ${pkgs.gnutls}/bin/certtool -p \
            --bits 2048 \
            --outfile "${cfg.dataDir}/keys/server.key"

          ${pkgs.gnutls}/bin/certtool -s \
            --template "${pkgs.writeText "taskserver-cert.template" ''
              cn = ${cfg.server.host}
              tls_www_server
              encryption_key
              signing_key
            ''}" \
            --load-ca-privkey "${cfg.dataDir}/keys/ca.key" \
            --load-ca-certificate "${cfg.dataDir}/keys/ca.cert" \
            --load-privkey "${cfg.dataDir}/keys/server.key" \
            --outfile "${cfg.dataDir}/keys/server.cert"

          chgrp "${cfg.group}" "${cfg.dataDir}/keys/server.key"
          chmod g+r "${cfg.dataDir}/keys/server.key"
          chmod a+r "${cfg.dataDir}/keys/server.cert"
        fi

        chmod go+x "${cfg.dataDir}/keys"
      '';
    };

    systemd.services.taskserver-init = {
      requiredBy = [ "taskserver.service" ];
      description = "Initialize Taskserver Data Directory";

      preStart = ''
        mkdir -m 0770 -p "${cfg.dataDir}"
        chown "${cfg.user}:${cfg.group}" "${cfg.dataDir}"
      '';

      script = ''
        ${taskd} init
        echo "include ${configFile}" > "${cfg.dataDir}/config"
        touch "${cfg.dataDir}/.is_initialized"
      '';

      environment.TASKDDATA = cfg.dataDir;

      unitConfig.ConditionPathExists = "!${cfg.dataDir}/.is_initialized";

      serviceConfig.Type = "oneshot";
      serviceConfig.User = cfg.user;
      serviceConfig.Group = cfg.group;
      serviceConfig.PermissionsStartOnly = true;
    };

    systemd.services.taskserver = {
      description = "Taskwarrior Server";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment.TASKDDATA = cfg.dataDir;

      serviceConfig = {
        ExecStart = "@${taskd} taskd server";
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
