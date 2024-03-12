# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = lib.mkBefore [ # XXX: this is the default behavior without the lib.mkAfter
  #nixpkgs.overlays = lib.mkAfter [ # XXX: required or else it's the opposite of how it work from 'nix-build' command
  #nixpkgs.overlays = [
    (import ./overlay.oxalica) #direct git clone of https://github.com/oxalica/rust-overlay.git
    (import ./overlayu)
#    [ pkgs.overlays.github {
#    owner = "oxalica";
#    repo = "/home/user/overlays/oxalica/rust-overlay";
#    rev = "master";
#    }
#    ]

    #(import ./ccache_overlay { inherit config lib pkgs; }) #if mkBefore, then this overlay gets overriden by the /etc/nixos/nixpkgs/nixos/modules/programs/ccache.nix
    (import ./ccache_overlay) #if mkBefore, then this overlay gets overriden by the /etc/nixos/nixpkgs/nixos/modules/programs/ccache.nix
  ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

#        nixos
#        nixos.channels.nixos-channel.override {
#          jetbrains = pkgs.jetbrains;
#        }
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "70%";
  boot.kernelParams = [
  "ipv6.disable=1"
  "ipv6.disable_ipv6=1"
  "ipv6.autoconf=0"
  "loglevel=15"
  "ignore_loglevel"
  "log_buf_len=10M"
  "printk.always_kmsg_dump=y"
  "printk.time=y"
  "printk.devkmsg=on"
  "gk.log.keep=true"
  "earlyprintk=vga"
  "systemd.log_target=kmsg"
  "systemd.journald.forward_to_console=1"
  "oops=panic"
  "panic=0"
  "print_fatal_signals=1"
  "sysrq_always_enabled"
  "random.trust_cpu=off"
  "mce=bootlog"
  "reboot=force,cold"
  "noexec=on"
  "nohibernate"
  "consoleblank=120"
  #"mitigations=on" #only =off is a thing here! else assumed =on but =on itself doesn't work: `Unsupported mitigations=on, system may still be vulnerable`
  "rd.log=all"
  "noefi"
  "cpuidle.governor=menu"
  "vsyscall=none"
  "acpi_force_table_verification"
  "page_owner=on"
  "debug_pagealloc=on"
  "page_poison=1"
  "init_on_free=0"
  "init_on_alloc=0"
  "page_table_check=on"
  "delayacct"
  "mminit_loglevel=4"
  "memory_corruption_check_period=60"
  "memory_corruption_check=1"
  "memory_corruption_check_size=600K"
  "randomize_kstack_offset=on"
  "memtest=3"
  ];

  networking.hostName = "vbox1"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Budapest";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.xserver.displayManager.gdm.wayland = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
	users.defaultUserShell = pkgs.bash;
	users.users = {
		user = {
			useDefaultShell = true; #If true, the user’s shell will be set to users.defaultUserShell.
			isNormalUser = true;
			description = "user";
			extraGroups = [ "networkmanager" "wheel" ];
			packages = with pkgs; [
				firefox
					kate
#  thunderbird
			];
		};
	};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


#  function rustDocPath () {
#    "${system.buildInputs.rustPackages.rustDocs}/share/doc/rust/html/index.html";
#  }
  environment.shellAliases = {
    cp="cp -i";
    mv="mv -i";
    v = "nvim";
    rustupdoc="firefox /run/current-system/sw/share/doc/rust/html/index.html";
    #rustupdoc = "firefox $(rustDocPath)";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
neovim
    wget
#nano #FIXME: this gets installed anyway! and EDITOR=nano too!
mc
git
jetbrains.rust-rover
#rustup
#rust-rover
#  (jetbrains.rust-rover.overrideAttrs {
#    src = pkgs.fetchurl {
#      url = "https://download.jetbrains.com/rustrover/RustRover-233.14015.153.tar.gz";
#      sha256 = "e3b70ee54bd6ff2ac900400ebdf8ae2c10c4206e51d3b52c1c68bd4f56244f1c";
#    };
#  })

#findutils
mlocate
#  (mlocate.overrideAttrs (oldAttrs: rec { #works 
#      makeFlags = oldAttrs.makeFlags or [] ++ [ "groupname=users" ]; #ie. use root:users instead of root:mlocate when chowning /var/cache/locatedb at the end of scanning! ie. gets rid of error:  updatedb: can not find group `mlocate'
#  }))

#this rust-bin stuff uses oxalica's overlay
(rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
  extensions = [ "rust-src" "rust-docs" "rustc-docs" ];
  #targets = [ "arm-unknown-linux-gnueabihf" ];
}))
#rust-bin.stable."1.75.0".default  #1.75.0 but can't do -Z
#rust-bin.nightly."2023-12-28".default  #1.75.0 nightly (55 files) no warn
#rust-bin.nightly."2024-02-08".default #1.76.0 nightly (54 files) no warn
#rust-bin.nightly."2024-02-28".default #1.78.0 nightly (57 files) + warning: the item `libc` is imported redundantly

keepassxc
#(keepassxc.overrideAttrs(old: {NIX_DEBUG=13;})) #this affects build for keepassxc only! so this is how to set NIX_DEBUG so far!

gcc
clang

bc
ethtool

#glxinfo
#pkg-config
#pkgconf
#xorg.libX11.dev
#xorg.libXcursor.dev
#xorg.libXrandr.dev
#xorg.libXi.dev
#xorg.libXext.dev
#xorg.libXxf86vm.dev
#xorg.libXft.dev
#xorg.libXinerama.dev
#xorg.libXmu.dev
#xorg.libXtst
#xorg.libXrender.dev
#xorg.libXpresent
#xorg.libXScrnSaver
#xorg.libXt.dev
libGL.dev
libGL
glew-egl
#freeglut
#nix-index

colordiff
vbindiff
glxinfo
xfce.mousepad
  file
ripgrep
ccache
#  # other packages...
#  (pkgs.buildEnv {
#    name = "my-build-env";
#    paths = [ ]; #need to pass this else error
##    variables = {
##      NIX_DEBUG = "10";
##    };
#      passthru = {
#      NIX_DEBUG="10"; #no effect
#      };
#    })
  ]; # env

  #xserver.videoDrivers = lib.mkOverride 10 [ "vmware" ];
  services.xserver.videoDrivers = [
##default:
#"vmware"
#"virtualbox"
#"modesetting"
##enddefault

  "vmware"
  "virtualbox"
  "modesetting"
  "fbdev"
  "virtio"
  ];
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      sandbox = true;
      trusted-users = [ "root" "user" ];
      auto-optimise-store = true;
      extra-sandbox-paths = [ config.programs.ccache.cacheDir ];# needed for ccache
    };

  };

  #for a guest quemu:
  boot.kernelModules = ["vfio-pci"];
  #virtualisation.videoDrivers = [ "virtio" ]; #not a thing
  services.qemuGuest.enable = true;
  #virtualisation.qemu.virtioKeyboard=true;
#  virtualisation.qemu= {
#    virtioKeyboard =true; #presumable if this nixos is guest OS, needs this to have keyboard (untested if it doesn't without this)
#  };
  virtualisation.virtualbox = {
    host = {
      enable=false;
    };
    guest = {
      enable = true;
      x11 = true;
    };
  };

  #programs.ccache.packageNames = [ "ffmpeg" ]; #"keepassxc" ]; //recompiled a lot of shie from source!
  programs.ccache.packageNames = [ "keepassxc" ]; #if pkg is in this list then it's using ccache regardless of programs.ccache.enable flag state below.
  programs.ccache.enable = true; #doesn't affect anything
  #programs.neovim.defaultEditor=true; #FIXME: see why this doesn't work! it's still 'nano'; won't work even after a reboot!
  environment.variables.EDITOR="nvim"; #doneFIXME: still 'nano' lol? ok needed a reboot, actually a user relog (bash -l isn't enough!), instead of just starting a new terminal!
  environment.variables.NIX_DEBUG="11"; #doesn't affect anything during build, but it's in system-wide eg. bash
  environment.memoryAllocator.provider="jemalloc";
  #The system-wide memory allocator.
	#
	#Briefly, the system-wide memory allocator providers are:
	#
	#    libc: the standard allocator provided by libc
	#    graphene-hardened: An allocator designed to mitigate memory corruption attacks, such as those caused by use-after-free bugs.
	#    jemalloc: A general purpose allocator that emphasizes fragmentation avoidance and scalable concurrency support.
	#    mimalloc: A compact and fast general purpose allocator, which may optionally be built with mitigations against various heap vulnerabilities.
	#    scudo: A user-mode allocator based on LLVM Sanitizer’s CombinedAllocator, which aims at providing additional mitigations against heap based vulnerabilities, while maintaining good performance.
	#
	#Selecting an alternative allocator (i.e., anything other than libc) may result in instability, data loss, and/or service failure.
	#
  #NIX_DEBUG="12"; #won't work error
	programs.bash = {
		#enable=true; #        - The option definition `programs.bash.enable' in `/etc/nixos/configuration.nix' no longer has any effect; please remove it.
		interactiveShellInit=''
			HISTCONTROL=ignorespace
			HISTFILESIZE=-1
			HISTSIZE=-1
			HISTTIMEFORMAT='%F %T '
			'';
	};

  fileSystems."/home/user/vm" = {
    fsType = "vboxsf";
    device = "vm";
    options = [ "rw" "nofail" ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services = {
    openssh = {
      enable=false;
    };
    locate = {
      enable = true;
      package = pkgs.mlocate; #needed to get mlocate group! old://using this gives the warning that the second below is needed: (but twice I tested this to still yield the error: updatedb: can not find group `mlocate' // but yet I was wrong, this is enough to get rid of it, tf!)
      localuser = null; #this works only if above is used, and silences this: updatedb: can not find group `mlocate' // not true, this isn't needed! it's only to get rid of a red warning saying this isn't used!
    };
  };

	systemd = {
		user = {
			services = {
				user_startup = { #initial code from unkn
					enable = true; # you still have to `$ systemctl --user enable user_startup` , this enable only does: If set to false, this unit will be a symlink to /dev/null. This is primarily useful to prevent specific template instances (e.g. serial-getty@ttyS0) from being started.
					#wantedBy = [ "multi-user.target" "suspend.target" ];
					wantedBy = [ "default.target" ];
					#after = [ "multi-user.target" "acpid.service" "suspend.target" ];
					description = "user-level startup stuff";
					path = [ pkgs.bash ];

					serviceConfig = {
            #FIXME: this doesn't show log on `journalctl --user -u user_startup.service` or `journalctl --user -u user_startup.service` even tho it did run! But if I manually start it then yea: 
            #these two make no difference apparently
            #StandardOutput = "journal";
            #StandardError = "journal";
						Type = "oneshot";
						RemainAfterExit = "yes";
						ExecStart = "${pkgs.bash}${pkgs.bash.shellPath} -c '/home/user/bin/_user_startup.bash'";
						#ExecStart = "${pkgs.runtimeShell} -c '/home/user/bin/_user_startup.bash'";
            #nix-repl> :p pkgs.bash
            #«derivation /nix/store/dynj352jjy6921i1kpbdq7bp7mymm5p3-bash-5.2p26.drv»
            #
            #nix-repl> :p "${pkgs.bash}/bin/bash"
            #"/nix/store/087167dfxal194pm54cmcbbxsfy3cjgn-bash-5.2p26/bin/bash"
            #
            #nix-repl> :p pkgs.runtimeShell
            #"/nix/store/087167dfxal194pm54cmcbbxsfy3cjgn-bash-5.2p26/bin/bash"
            #
            #
					};
				};
			};
		}; #user services
		services = { # system-wide services
			system_startup = { # initial code from unkn
      #oknvmdelayediguessFIXME: so far this shows its log on `journalctl -u system_startup.service` and on `systemctl status system_startup`
				enable = true;
				wantedBy = [ "multi-user.target" "suspend.target" ];
				after = [ "multi-user.target" "acpid.service" "suspend.target" ];
				description = "My global startup stuff";
				path = [ pkgs.bash pkgs.ethtool ];

				serviceConfig = {
					Type = "oneshot";
					RemainAfterExit = "yes";
					ExecStart = "${pkgs.runtimeShell} -c '/_system_startup.bash'";
				};
			};
		}; # system-wide services
	};

  # Open ports in the firewall.
  # Or disable the firewall altogether.
  networking = {
    nftables.enable = false; #because using 'iptables', see: https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/firewall.nix#L73
    firewall = {
      enable = true;
      #this is INPUT only:
      #allowedTCPPorts = [ 443 ];
      #allowedUDPPorts = [ 443 ];
      logRefusedConnections = true;
      extraStopCommands = "iptables -P OUTPUT DROP
        iptables -P INPUT DROP
        iptables -P FORWARD DROP";
      pingLimit = "--limit 1/minute --limit-burst 5";
      allowPing = true;
#      iptables -A OUTPUT -p udp -d nixos.org --dport 443 -j ACCEPT
      extraCommands = ''
      #flush first, since it otherwise accumulates:
      iptables -F OUTPUT
      iptables -F INPUT

      iptables -P OUTPUT DROP
      iptables -A OUTPUT -p icmp -j ACCEPT #TODO: allow all for now.

      iptables -N TCP || iptables -F TCP #create or flush the 'TCP'(named) chain - both are needed else fail or appending to prev. ones!
#FIXME: this 443 has to be in two places, one here and one in OUTPUT, see why
      iptables -A TCP -p tcp --dport 443 -j ACCEPT
      iptables -A TCP -p tcp --dport 22 -j ACCEPT
      iptables -A TCP -j LOG --log-prefix "TCPchaindropped:" --log-level 7 --log-uid
      iptables -A TCP -i lo -s 127.0.0.1/8 -d 127.0.0.1/8 -j ACCEPT  #NOTE that on INPUT all 0/0 is accepted on 'lo' if it were to reach nixos-fw chain but it reaches TCP one instead now.
      iptables -A TCP -j DROP

      iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP
      iptables -A OUTPUT -p udp --dport 53 -d 10.0.2.3 -j ACCEPT
#      iptables -A OUTPUT -p udp --dport 443 -j ACCEPT
      iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
      iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
#      iptables -A OUTPUT -p tcp -d nixos.org --dport 443 -j ACCEPT #it won't resolve at all!

      iptables -A OUTPUT -o lo -s 127.0.0.1/8 -d 127.0.0.1/8 -j ACCEPT  #NOTE that on INPUT all 0/0 is accepted on 'lo'
      iptables -A OUTPUT -j LOG --log-prefix "outputdropped:" --log-level 7 --log-uid
      iptables -A OUTPUT -j DROP
      '';
    };
  };

#  jetbrains.rust-rover = pkgs.jetbrains.rust-rover;
  #pkgs = import <nixpkgs> {};
  #rust-rover = pkgs.jetbrains.rust-rover.overrideURL {

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
# vim: set tabstop=2 shiftwidth=2 expandtab :
