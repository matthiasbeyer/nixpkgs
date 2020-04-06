{ lib, pkgs, config, ... }:

let
  name = "peertube";
  cfg = config.services.peertube;

  uid = config.ids.uids.peertube;
  gid = config.ids.gids.peertube;
in
{
  options.services.peertube = {
    enable = lib.mkEnableOption "Enable Peertube’s service";

    user = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "User account under which Peertube runs";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "Group under which Peertube runs";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/${name}";
      description = ''
        The directory where Peertube stores its data.
      '';
    };

    peertubeconfig = with lib; {
      listen = {
        hostname = mkOption {
          type = types.str;
          default = "localhost";
        };

        port = mkOption {
          type = types.int;
          default = 9000;
        };
      };

      webserver = {
        https = mkOption {
          type = types.boolean;
          default = true;

          description = ''
            Correspond to your reverse proxy server_name/listen configuration,
            whether there is https enabled
          '';
        };

        hostname = mkOption {
          type = types.str;
          default = "example.com";

          description = ''
            Correspond to your reverse proxy server_name/listen configuration,
            the hostname of your webserver.
          '';
        };

        port = mkOption {
          type = types.int;
          default = 443;

          description = ''
            Correspond to your reverse proxy server_name/listen configuration,
            the port your webserver is running on.
          '';
        };
      };

      rates_limit = {
        api = {
          # 50 attempts in 10 seconds
          window = mkOption {
            type = types.str;
            default = "10 seconds";
          };

          max = mkOption {
            type = types.str;
            default = "50";
          };
        };

        login = {
          # 15 attempts in 5 min
          window = mkOption {
            type = types.str;
            default = "5 minutes";
          };

          max = mkOption {
            type = types.str;
            default = "15";
          };
        };

        signup = {
          # 2 attempts in 5 min (only succeeded attempts are taken into account)
          window = mkOption {
            type = types.str;
            default = "5 minutes";
          };

          max = mkOption {
            type = types.str;
            default = "2";
          };
        };

        ask_send_email = {
          # 3 attempts in 5 min
          window = mkOption {
            type = types.str;
            default = "5 minutes";
          };

          max = mkOption {
            type = types.str;
            default = "3";
          };
        };

      };

      trust_proxy = mkOption {
        type = types.str;
        default = "loopback";
        description = ''
          Proxies to trust to get real client IP
          If you run PeerTube just behind a local proxy (nginx), keep 'loopback'
          If you run PeerTube behind a remote proxy, add the proxy IP address (or subnet)
        '';
      };

      database = {
        hostname = mkOption {
          type = types.str;
          default = "localhost";
        };

        port = mkOption {
          type = types.int;
          default = 5432;
        };

        suffix = mkOption {
          type = types.str;
          default = "_prod";
        };

        username = mkOption {
          type = types.str;
          default = "peertube";
        };

        password = mkOption {
          type = types.str;
          default = "peertube";
        };

        pool = {
          max = mkOption {
            type = types.int;
            default = 5;
          };
        };
      };

      redis = {
        hostname = mkOption {
          type = types.str;
          default = "localhost";
        };

        port = mkOption {
          type = types.int;
          default = 6379;
        };

        auth = mkOption {
          type = types.str;
          default = "null";
        };

        db = mkOption {
          type = types.int;
          default = 0;
        };

      };

      smtp = {
        hostname = mkOption {
          type = types.str;
          default = "null";
        };

        port = mkOption {
          type = types.int;
          default = 465;
        };

        username = mkOption {
          type = types.str;
          default = "null";
        };

        password = mkOption {
          type = types.str;
          default = "null";
        };

        tls = mkOption {
          type = types.boolean;
          default = true;
        };

        disable_starttls = mkOption {
          type = types.boolean;
          default = false;
        };

        ca_file = mkOption {
          type = types.str;
          default = "null"; # Used for self signed certificates
        };

        from_address = mkOption {
          type = types.str;
          default = "admin@example.com";
        };

      };

      email = {
        body = {
          signature = mkOption {
            type = types.str;
            default = "PeerTube";
          };
        };

        subject = {
          prefix = mkOption {
            type = types.str;
            default = "[PeerTube]";
          };
        };
      };

      storage = {
        tmp = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/tmp/";
        };

        avatars = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/avatars/";
        };

        videos = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/videos/";
        };

        streaming_playlists = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/streaming-playlists/";
        };

        redundancy = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/redundancy/";
        };

        logs = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/logs/";
        };

        previews = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/previews/";
        };

        thumbnails = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/thumbnails/";
        };

        torrents = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/torrents/";
        };

        captions = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/captions/";
        };

        cache = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/cache/";
        };

        plugins = mkOption {
          type = types.str;
          default = "/var/www/peertube/storage/plugins/";
        };

      };

      log = {
        level = mkOption {
          type = types.str;
          default = "info";
        };

        rotation = {
          enabled  = mkOption {
            type = types.boolean;
            default = true;
          };

          maxFileSize = mkOption {
            type = types.str;
            default = "12MB";
          };

          maxFiles = mkOption {
            type = types.int;
            default = 20;
          };

        };

        anonymizeIP = mkOption {
          type = types.boolean;
          default = false;
        };
      };

      search = {
        # Add ability to fetch remote videos/actors by their URI, that may not be federated with your instance
        # If enabled, the associated group will be able to "escape" from the instance follows
        # That means they will be able to follow channels, watch videos, list videos of non followed instances
        remote_uri = {
          users = mkOption {
            type = types.boolean;
            default = true;
          };

          anonymous = mkOption {
            type = types.boolean;
            default = false;
          };

        };
      };

      trending = {
        videos = {
          interval_days = mkOption {
            type = types.int;
            default = 7;
          };

        };
      };


      # Cache remote videos on your server, to help other instances to broadcast the video
      # You can define multiple caches using different sizes/strategies
      # Once you have defined your strategies, choose which instances you want to cache in admin -> manage follows -> following
      redundancy = {
        videos = {
          check_interval = mkOption {
            type = types.str;
            default = "1 hour";
          };
        };

        strategies = {
          size = mkOption {
            type = types.str;
            default = "10GB";
          };

          min_lifetime = mkOption {
            type = types.str;
            default = "48 hours";
          };

          strategy = mkOption {
            type = types.str;
            default = "most-views";

            description = ''
              'most-views' - Cache videos that have the most views
              'trending' - Cache trending videos
              'recently-added' - Cache recently added videos
            '';
          };

          min_views = mkOption {
            type = types.int;
            default = 10;
          };

        };
      };

      csp = {
        enabled = mkEnable {
          default = false;
        };

        report_only = mkOption {
          type = types.boolean;
          default = true;
          description = "CSP directives are still being tested, so disable the report only mode at your own risk!";
        };

        report_uri = mkOption {
          type = types.str;
          default = "";
        };
      };

      tracker = {
        enabled = mkEnable {
          default = true;
          description = ''
            If you disable the tracker, you disable the P2P aspect of PeerTube
          '';
        };

        private = mkOption {
          type = types.boolean;
          default = true;
          description = ''
            Only handle requests on your videos.
            If you set this to false it means you have a public tracker.
            Then, it is possible that clients overload your instance with external torrents
          '';
        };

        reject_too_many_announces = mkOption {
          type = types.boolean;
          default = false;
          description = ''
            Reject peers that do a lot of announces (could improve privacy of TCP/UDP peers)
          '';
        };
      };

      history = {
        videos = {
          max_age = mkOption {
            type = types.int;
            default = -1;

            description = ''
              If you want to limit users videos history
              -1 means there is no limitations
              Other values could be '6 months' or '30 days' etc (PeerTube will periodically delete old entries from database)
            '';
          };
        };
      };

      views = {
        videos = {
          remote = {
            max_age = mkOption {
              type = types.int;
              default = -1;

              description = ''
                PeerTube creates a database entry every hour for each video to track views over a period of time
                This is used in particular by the Trending page
                PeerTube could remove old remote video views if you want to reduce your database size (video view counter will not be altered)
                -1 means no cleanup
                Other values could be '6 months' or '30 days' etc (PeerTube will periodically delete old entries from database)
              '';
            };
          };
        };
      };

      plugins = {
        # The website PeerTube will ask for available PeerTube plugins and themes
        # This is an unmoderated plugin index, so only install plugins/themes you trust
        index = {
          enable = mkEnable {
            default = true;
          };
          check_latest_versions_interval = mkOption {
            type = types.str;
            default = "12 hours";
          };

          url = mkOption {
            type = types.str;
            default = "https://packages.joinpeertube.org";
          };

        };
      };


      cache = {
        previews = {
          size = mkOption {
            type = types.int;
            default = 500;
          };

          captions = mkOptions {
              type = types.int;
              default = 500;
          };
        };
      };

      admin = {
        email = {
          type = types.str;
          default = "admin@example.com";
          description = ''
            Used to generate the root user at first startup
            And to receive emails from the contact form
          '';
        };
      };

      contact_form = {
        enabled = mkEnable {
          default = true;
        };
      };

      signup = {
        enabled = mkEnable {
          default = false;
        };

        limit = mkOption {
          type = types.int;
          default = 10;

          description = ''
            When the limit is reached, registrations are disabled. -1 == unlimited
          '';
        };

        requires_email_verification = mkOption {
          type = types.boolean;
          default = false;
        };

        filters = {
          cidr = {
            whitelist = mkOption {
              type = types.listOf types.str;
              default = [];
            };

            blacklist = mkOption {
              type = types.listOf types.str;
              default = [];
            };

          };
        };
      };

      user = {
        video_quota = mkOption {
          type = types.int;
          default = -1;

          description = ''
            Default value of maximum video BYTES the user can upload (does not take into account transcoded files).
            -1 == unlimited
          '';
        };

        video_quota_daily = mkOption {
          type = types.int;
          default = -1;
        };
      };

      transcoding = {
        enabled = mkEnable {
          default = true;
          description = ''
            If enabled, the video will be transcoded to mp4 (x264) with "faststart" flag
            In addition, if some resolutions are enabled the mp4 video file will be transcoded to these new resolutions.
            Please, do not disable transcoding since many uploaded videos will not work
          '';
        };

        allow_additional_extensions = mkOption {
          type = types.int;
          default = true;

          description = ''
            Allow your users to upload .mkv, .mov, .avi, .flv videos
          '';
        };

        allow_audio_files = mkOption {
          type = types.boolean;
          default = true;

          description = ''
            If a user uploads an audio file, PeerTube will create a video by merging the preview file and the audio file
          '';
        };

        threads = mkOption {
          type = types.int;
          default = 1;
        };

        resolutions = {
          # Only created if the original video has a higher resolution, uses more storage!
          res0p = mkOption {
            type = types.boolean;
            default = false;
            description = ''
              audio-only (creates mp4 without video stream, always created when enabled);
            '';
          };

          res240p = mkOption {
            type = types.boolean;
            default = false;
          };

          res360p = mkOption {
            type = types.boolean;
            default = false;
          };

          res480p = mkOption {
            type = types.boolean;
            default = false;
          };

          res720p = mkOption {
            type = types.boolean;
            default = false;
          };

          res1080p = mkOption {
            type = types.boolean;
            default = false;
          };

          res2160p = mkOption {
            type = types.boolean;
            default = false;
          };

        };

        webtorrent = {
          enabled = mkEnable {
            default = true;

            description = ''
              Generate videos in a WebTorrent format (what we do since the first PeerTube release)
              If you also enabled the hls format, it will multiply videos storage by 2
              If disabled, breaks federation with PeerTube instances < 2.1
            '';
          };
        };

        hls = {
          enabled = mkEnable {
            default = false;

            description = ''
              /!\ Requires ffmpeg >= 4.1
              Generate HLS playlists and fragmented MP4 files. Better playback than with WebTorrent:
                  * Resolution change is smoother
                  * Faster playback in particular with long videos
                  * More stable playback (less bugs/infinite loading)
              If you also enabled the webtorrent format, it will multiply videos storage by 2
            '';
          };
        };

        import = {
          # Add ability for your users to import remote videos (from YouTube, torrent...)
          videos = {
            http = {
              enabled = mkEnable {
                default = false;

                description = ''
                  Classic HTTP or all sites supported by youtube-dl https://rg3.github.io/youtube-dl/supportedsites.html
                '';
              };

              # You can use an HTTP/HTTPS/SOCKS proxy with youtube-dl
              proxy = {
                enabled = mkEnable {
                  default = false;
                };

                url = mkOption {
                  type = types.str;
                  default = "";
                };
              };
            };

            torrent = {
              enabled = mkEnable {
                default = false;
                description = ''
                  Magnet URI or torrent file (use classic TCP/UDP/WebSeed to download the file)
                '';
              };
            };
          };
        };

        auto_blacklist = {
          videos = {
            of_users = {
              enabled = mkEnable {
                default = false;

                description = ''
                  New videos automatically blacklisted so moderators can review before publishing
                '';
              };
            };
          };
        };

        # Instance settings
        instance = {
          name = mkOption {
            type = types.str;
            default = "PeerTube";
          };

          short_description = mkOption {
            type = type.str;

            default = ''
              PeerTube, a federated (ActivityPub) video streaming platform using P2P (BitTorrent) directly in the web browser with WebTorrent and Angular.
            '';
          };

          description = mkOption {
            type = types.str;
            default = ''
              Welcome to this PeerTube instance!
            '';
          };

          terms = mkOption {
            type = types.str;
            default = "No terms for now.";
          };

          code_of_conduct = mkOption {
            type = types.str;
            default = "";
          };

          moderation_information = mkOption {
            type = types.str;
            default = "";

            description = ''
              Who moderates the instance? What is the policy regarding NSFW videos? Political videos? etc
            '';
          };

          creation_reason = mkOption {
            type = types.str;
            default = "";
          };

          administrator = mkOption {
            type = types.str;
            default = "";
          };

          maintenance_lifetime = mkOption {
            type = types.str;
            default = "";
          };

          business_model = mkOption {
            type = types.str;
            default = "";
          };

          hardware_information = mkOption {
            type = types.str;
            default = "";
          };

          languages = mkOption {
            type = types.listOf types.str;
            default = [ "en" "de" "fr" ];

            description = ''
              What are the main languages of your instance? To interact with your users for example
              Uncomment or add the languages you want
              List of supported languages: https://peertube.cpy.re/api/v1/videos/languages
            '';
          };

          categories = {
            type = types.int;
            description = ''
              You can specify the main categories of your instance (dedicated to music, gaming or politics etc)
              Uncomment or add the category ids you want
              List of supported categories: https://peertube.cpy.re/api/v1/videos/categories

              - 1  # Music
              - 2  # Films
              - 3  # Vehicles
              - 4  # Art
              - 5  # Sports
              - 6  # Travels
              - 7  # Gaming
              - 8  # People
              - 9  # Comedy
              - 10 # Entertainment
              - 11 # News & Politics
              - 12 # How To
              - 13 # Education
              - 14 # Activism
              - 15 # Science & Technology
              - 16 # Animals
              - 17 # Kids
              - 18 # Food
            '';
          };

          default_client_route = mkOption {
            type = types.str;
            default = "/videos/trending";
          };

          is_nsfw = mkOption {
            type = types.boolean;
            default = false;

            description = ''
              Whether or not the instance is dedicated to NSFW content
              Enabling it will allow other administrators to know that you are mainly federating sensitive content
              Moreover, the NSFW checkbox on video upload will be automatically checked by default
            '';
          };

          default_nsfw_policy = mkOption {
            type = types.str;
            default = "do_not_list";

            description = ''
              By default, "do_not_list" or "blur" or "display" NSFW videos
              Could be overridden per user with a setting
            '';
          };

          customizations = {
            javascript = mkOption {
              type = types.str;
              default = "";
            };

            css = mkOption {
              type = types.str;
              default = "";
            };
          };

          # Robot.txt rules. To disallow robots to crawl your instance and disallow indexation of your site, add '/' to "Disallow:'
          robots = mkOption {
            type = types.str;
            default = ''
              User-agent: *
              Disallow:
            '';
          };

          securitytxt = mkOption {
            type = types.str;

            default = ''
              # If you would like to report a security issue\n# you may report it to:\nContact: mailto:
            '';
          };
        };

        services = {
          # Cards configuration to format video in Twitter
          twitter = {
            username = mkOption {
              type = types.str;
              description = ''
                Indicates the Twitter account for the website or platform on which the content was published
                If true, a video player will be embedded in the Twitter feed on PeerTube video share
                If false, we use an image link card that will redirect on your PeerTube instance
                Change it to "true", and then test on https://cards-dev.twitter.com/validator to see if you are whitelisted
              '';
            };

            whitelisted = mkOption {
              type = types.boolean;
              default = false;
            };
          };
        };

        followers = {
          instance = {
            enabled = mkEnable {
              default = true;
              description = ''
                Allow or not other instances to follow yours
              '';
            };

            manual_approval = mkEnable {
              default = false;
              description = ''
                Whether or not an administrator must manually validate a new follower
              '';
            };
          };
        };

        followings = {
          instance = {
            # If you want to automatically follow back new instance followers
            # If this option is enabled, use the mute feature instead of deleting followings
            # /!\ Don't enable this if you don't have a reactive moderation team /!\
            auto_follow_back = {
              enabled = mkOption {
                type = types.bool;
                default = false;
              };
            };

            auto_follow_index = {
              enabled = mkEnable {
                default = false;
                description = ''
                  If you want to automatically follow instances of the public index
                  If this option is enabled, use the mute feature instead of deleting followings
                  /!\ Don't enable this if you don't have a reactive moderation team /!\
                '';
              };

              index_url = mkOption {
                type = types.str;
                default = "https://instances.joinpeertube.org";
              };
            };
          };
        };

        theme = {
          default = mkOption {
            type = types.str;
            default = "default";
          };
        };
      };
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        The configuration file path for Peertube.
        '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.webapps.peertube;
      description = ''
        Peertube package to use.
        '';
    };

    # Output variables
    systemdStateDirectory = lib.mkOption {
      type = lib.types.str;

      # Use ReadWritePaths= instead if varDir is outside of /var/lib
      default = assert lib.strings.hasPrefix "/var/lib/" cfg.dataDir;
        lib.strings.removePrefix "/var/lib/" cfg.dataDir;

      description = ''
      Adjusted Peertube data directory for systemd
      '';

      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == name) {
      "${name}" = {
        inherit uid;
        group = cfg.group;
        description = "Peertube user";
        home = cfg.dataDir;
        useDefaultShell = true;
      };
    };
    users.groups = lib.optionalAttrs (cfg.group == name) {
      "${name}" = {
        inherit gid;
      };
    };

    systemd.services.peertube = {
      description = "Peertube";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      wants = [ "postgresql.service" ];

      environment.NODE_CONFIG_DIR = "${cfg.dataDir}/config";
      environment.NODE_ENV = "production";
      environment.HOME = cfg.package;

      path = [ pkgs.nodejs pkgs.bashInteractive pkgs.ffmpeg pkgs.openssl ];

      script = ''
        install -m 0750 -d ${cfg.dataDir}/config
        ln -sf ${cfg.configFile} ${cfg.dataDir}/config/production.yaml
        exec npm run start
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.package;
        StateDirectory = cfg.systemdStateDirectory;
        StateDirectoryMode = 0750;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectControlGroups = true;
        Restart = "always";
        Type = "simple";
        TimeoutSec = 60;
      };

      unitConfig.RequiresMountsFor = cfg.dataDir;
    };
  };
}

