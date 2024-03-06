self: super:
#aka final: prev:
{
  mlocate = super.mlocate.overrideAttrs (oldAttrs: rec { #works 
      makeFlags = oldAttrs.makeFlags or [] ++ [ "groupname=users" ]; #ie. use root:users instead of root:mlocate when chowning /var/cache/locatedb at the end of scanning! ie. gets rid of error:  updatedb: can not find group `mlocate'
      });

  jetbrains = super.jetbrains // {
  rust-rover = super.jetbrains.rust-rover.overrideAttrs (oldAttrs: rec {
      build_number = "233.14015.153";
      src = self.fetchurl {
      url = "https://download.jetbrains.com/rustrover/RustRover-${build_number}.tar.gz";
      sha256 = "e3b70ee54bd6ff2ac900400ebdf8ae2c10c4206e51d3b52c1c68bd4f56244f1c";
      };
#      patches = [ ]; #FIXME: ./fookmi.patch ];
#      postPatch = ''
#      mv plugins/remote-dev-server plugins/remote-dev-server.tmp
#      ${oldAttrs.postPatch}
#      mv plugins/remote-dev-server.tmp plugins/remote-dev-server
#      '';
      postFixup = builtins.replaceStrings [ "patchelf --set-interpreter" ]
      ["# patchelf --set-interpreter" ] (oldAttrs.postFixup or "");
      });
      };

  keepassxc = super.keepassxc.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [] ++ [
      ./patches/0100_unhide_after_autotype.patch
    ];
    doCheck = false;
  });


#ok well, oxilica has bin rusts so the patch is useless
#  rust-bin = super.rust-bin // {
#  nightly = super.rust-bin.nightly // {
#  latest = super.rust-bin.nightly.latest // {
#  rustc=super.rust-bin.nightly.latest.rustc.overrideAttrs (oldAttrs: rec {
#      patches = [
#				./1500_error_on_unused_manifest_key.patch
#      ];
#      });
#			patchFlags = [ "-p1" ];
#      CARGO_PEDANTIC="off";
#    };
#    };
#    };

#code from "a nix fan" (not me):
#  rust-bin = super.rust-bin // {
#    nightly = super.rust-bin.nightly // {
#      "2023-12-28" = super.rust-bin.nightly."2023-12-28" // rec {
#        rustc = super.rust-bin.nightly."2023-12-28".rustc.overrideAttrs (oldAttrs: rec {
#          name = oldAttrs.name + "-moo";
#          # whatever
#          patches = [
#            ./1500_error_on_unused_manifest_key.patch
#          ];
#          patchFlags = [ "-p1" ];
#          CARGO_PEDANTIC="off";
#        });
#        clippy = super.rust-bin.nightly."2023-12-28".clippy.override {inherit rustc; };
#        rustfmt = super.rust-bin.nightly."2023-12-28".rustfmt.override {inherit rustc; };
#        default = super.rust-bin.nightly."2023-12-28".default.overrideAttrs (old: rec {
#          paths = [ rustc ] ++ (let
#            paths1 = (super.lib.remove super.rust-bin.nightly."2023-12-28".rustc old.paths);
#            paths2 = (super.lib.remove super.rust-bin.nightly."2023-12-28".clippy paths1);
#            paths' = (super.lib.remove super.rust-bin.nightly."2023-12-28".rustfmt paths2);
#          in
#            paths');
#        });
#      };
#    };
#  };
#
#let-ified:
#rust-bin = super.rust-bin // {
#  nightly = super.rust-bin.nightly // {
#    let date = "2023-12-28";  # Use let to define the date variable
#    in date = let
#      mata = super.rust-bin.nightly.date;  # Utilize the defined date variable
#    in
#      mata // rec {
#        rustc = mata.rustc.overrideAttrs (oldAttrs: rec {
#          name = oldAttrs.name + "-moo";
#          # whatever
#          # patches = [
#          #  ./1500_error_on_unused_manifest_key.patch
#          # ];
#          # patchFlags = [ "-p1" ];
#          # CARGO_PEDANTIC="off";
#        });
#        clippy = mata.clippy.override {inherit rustc; };
#        rustfmt = mata.rustfmt.override {inherit rustc; };
#        default = mata.default.overrideAttrs (old: rec {
#          paths = [ rustc ] ++ (let
#            paths1 = (super.lib.remove mata.rustc old.paths);
#            paths2 = (super.lib.remove mata.clippy paths1);
#            paths' = (super.lib.remove mata.rustfmt paths2);
#          in
#            paths');
#        });
#      };
#  };
#};
#
#  rust-bin = super.rust-bin // {
#    nightly = super.rust-bin.nightly // {
#      "2023-12-28" = let
#        mata = super.rust-bin.nightly."2023-12-28";
#      in
#        mata // rec {
#        rustc = mata.rustc.overrideAttrs (oldAttrs: rec {
#          name = oldAttrs.name + "-moo";
#        });
#        clippy = mata.clippy.override {inherit rustc; };
#        rustfmt = mata.rustfmt.override {inherit rustc; };
#        default = mata.default.overrideAttrs (old: rec {
#          paths = let
#            remove' = xs: self.lib.filter (x: !self.lib.elem x xs);
#          in
#            [ rustc ] ++ (remove' [ mata.rustc mata.clippy mata.rustfmt ] old.paths);
#        });
#      };
#    };
#  };
#


#
#virtualbox = super.virtualbox.overrideAttrs (oldAttrs: rec {
#    version = "7.0.14";
#  src = self.fetchurl {
#    url = "https://download.virtualbox.org/virtualbox/${version}/VirtualBox-${version}.tar.bz2";
#    sha256 = "45860d834804a24a163c1bb264a6b1cb802a5bc7ce7e01128072f8d6a4617ca9";
#  };
#
#});
#
##linuxPackages = super.linuxPackages // {
##
##
##   virtualboxGuestAdditions = super.linuxPackages.virtualboxGuestAdditions.overrideAttrs (oldAttrs: rec {
##
##   version = "7.0.14";
##     name = "VirtualBox-GuestAdditions-${version}-${super.linuxPackages.kernel.version}";
##   src = self.fetchurl {
##    url = "http://download.virtualbox.org/virtualbox/${version}/VBoxGuestAdditions_${version}.iso";
##    sha256 = "0efbcb9bf4722cb19292ae00eba29587432e918d3b1f70905deb70f7cf78e8ce";
##    };
##         prePatch = ''
##    substituteInPlace src/vboxguest-${version}/vboxvideo/vbox_ttm.c \
##      --replace "<ttm/" "<drm/ttm/"
##  '';
##  patchFlags = [ "-p1" "-d" "src/vboxguest-${version}" ];
##     buildPhase = builtins.replaceStrings ["vboxguest-7.0.12"] ["vboxguest-${version}"] oldAttrs.buildPhase;
##   installPhase = builtins.replaceStrings ["vboxguest-7.0.12"] ["vboxguest-${version}"] oldAttrs.installPhase;
##
##
##
##});
##}; #  super.linuxPackages
#
#linuxKernel = super.linuxKernel // {
#  packageAliases = super.packageAliases // {
#    linux_default = self.linuxKernel.packages.linux_6_1;
#  };
#  packages = super.linuxKernel.packages // {
#    linux_6_1 = super.linuxKernel.packages.linux_6_1 // {
#        virtualboxGuestAdditions = super.linuxKernel.packages.linux_6_1.virtualboxGuestAdditions.overrideAttrs (oldAttrs: rec {
#					 version = "7.0.14";
#					 name = "VirtualBox-GuestAdditions-${version}-${super.linuxKernel.packages.linux_6_1.kernel.version}";
#           #name = "VirtualBox-GuestAdditions-${version}-${super.linuxPackages.kernel.version}";
#					 #name = "VirtualBox-GuestAdditions-${version}-koe";
#					 src = self.fetchurl {
#						url = "http://download.virtualbox.org/virtualbox/${version}/VBoxGuestAdditions_${version}.iso";
#						sha256 = "0efbcb9bf4722cb19292ae00eba29587432e918d3b1f70905deb70f7cf78e8ce";
#						};
#						prePatch = ''
#						substituteInPlace src/vboxguest-${version}/vboxvideo/vbox_ttm.c \
#							--replace "<ttm/" "<drm/ttm/"
#							'';
#					patchFlags = [ "-p1" "-d" "src/vboxguest-${version}" ];
#						 buildPhase = builtins.replaceStrings ["vboxguest-7.0.12"] ["vboxguest-${version}"] oldAttrs.buildPhase;
#					 installPhase = builtins.replaceStrings ["vboxguest-7.0.12"] ["vboxguest-${version}"] oldAttrs.installPhase;
#				});
#    };
#  };
#};
#
#linuxPackages = super.linuxKernel.packages.linux_6_1;


} #self/super

# vim: set tabstop=2 shiftwidth=2 expandtab :
