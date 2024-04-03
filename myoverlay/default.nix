self: super:
#aka final: prev:
{
  mlocate = super.mlocate.overrideAttrs (oldAttrs: rec { #works 
      makeFlags = oldAttrs.makeFlags or [] ++ [ "groupname=users" ]; #ie. use root:users instead of root:mlocate when chowning /var/cache/locatedb at the end of scanning! ie. gets rid of error:  updatedb: can not find group `mlocate'
      });

  jetbrains = super.jetbrains // {
  rust-rover = super.jetbrains.rust-rover.overrideAttrs (oldAttrs: rec {
      #build_number = "233.14015.153";
      build_number = "233.14015.155";
      src = self.fetchurl {
      url = "https://download.jetbrains.com/rustrover/RustRover-${build_number}.tar.gz";
      #sha256 = "e3b70ee54bd6ff2ac900400ebdf8ae2c10c4206e51d3b52c1c68bd4f56244f1c"; #233.14015.153
      sha256 = "51b6db1563d68326bd7c8defe1f6c04b428e1a592d06579edfeb0feb60c45077";
      };
#      patches = [ ]; #FIXME: ./fookmi.patch ];
#      postPatch = ''
#      mv plugins/remote-dev-server plugins/remote-dev-server.tmp
#      ${oldAttrs.postPatch}
#      mv plugins/remote-dev-server.tmp plugins/remote-dev-server
#      '';

      # replaceStrings from to s - Given string s, replace every occurrence of the strings in from with the corresponding string in to.
      #see https://nixos.org/manual/nix/stable/language/builtins.html#builtins-replaceStrings
      postFixup = builtins.replaceStrings [ "patchelf --set-interpreter" ]
      ["# patchelf --set-interpreter" ] (oldAttrs.postFixup or "");
      });
      };

  keepassxc = (super.keepassxc.override { 
      cmake = self.cmake2;
      }).overrideAttrs (oldAttrs: {
    #NIX_DEBUG=13; #untested
    patches = oldAttrs.patches or [] ++ [
      ./patches/0100_unhide_after_autotype.patch
      #./ is "A path relative to the file containing this Nix expression"
    ];
    doCheck = false; #tests? at least one fails due to patch!
#    patchPhase = oldAttrs.patchPhase or "" + ''
#    '';
#    preConfigurePhase = oldAttrs.preConfigurePhase or "" + ''
#    export CMAKE_VERBOSE_MAKEFILE=ON
#    export CMAKE_BUILD_TYPE=Debug
#    export CMAKE_DEBUG_TARGET_PROPERTIES=YES
#    export CMAKE_EXPORT_COMPILE_COMMANDS=YES
#    #export CMAKE_MESSAGE_LOG_LEVEL=DEBUG  #unsure if it worked
#    export CMAKE_MESSAGE_LOG_LEVEL=VERBOSE
#    '';
#		glibPreInstallPhase = oldAttrs.glibPreInstallPhase or "" + ''
#    echo "glibPreInstallPhase phase starting... failing on purpose"
#    exit 1
#    '';
#		buildPhase = oldAttrs.buildPhase or "" + ''
#    echo "Build phase starting... failing on purpose"
#    exit 1
#    '';
    #cmake=self.cmake2; #XXX can't use this here due to it's not an attr, even tho it compiles fine/no errs/warns!
  });

  cmake2 = super.cmake.overrideAttrs (oldAttrs: {
    patches = oldAttrs.patches or [] ++ [
      ./patches/0100_cmake_unpaired_square_brackets.patch
      ./patches/0200_cmake_fail_not_just_warn.patch
      #./ is "A path relative to the file containing this Nix expression"
    ];
    #doCheck = false; #tests?
#    patchPhase = oldAttrs.patchPhase or "" + ''
#    export CMAKE_VERBOSE_MAKEFILE=ON
#    export CMAKE_BUILD_TYPE=Debug
#    export CMAKE_DEBUG_TARGET_PROPERTIES=YES
#    export CMAKE_EXPORT_COMPILE_COMMANDS=YES
#    export CMAKE_MESSAGE_LOG_LEVEL=DEBUG
#    '';
    #export CMAKE_MESSAGE_LOG_LEVEL=VERBOSE
#		buildPhase = ''
#    echo "Build phase starting... failing on purpose"
#    exit 1
#    '';
  });
  cmake3 = super.cmake.overrideAttrs (oldAttrs: { #confirmed fail
    patches = oldAttrs.patches or [] ++ [
      ./patches/0100_cmake_unpaired_square_brackets_first_half.patch
      #./patches/0100_cmake_unpaired_square_brackets_second_half.patch
      ./patches/0200_cmake_fail_not_just_warn.patch
      #./ is "A path relative to the file containing this Nix expression"
    ];
  });
  cmake4 = super.cmake.overrideAttrs (oldAttrs: { #works only with this! but it's not the same .cmake file contents as with cmake2
    patches = oldAttrs.patches or [] ++ [
      #./patches/0100_cmake_unpaired_square_brackets_first_half.patch
      ./patches/0100_cmake_unpaired_square_brackets_second_half.patch
      ./patches/0200_cmake_fail_not_just_warn.patch
      #./ is "A path relative to the file containing this Nix expression"
    ];
  });

#	keepassxc = super.keepassxc.overrideAttrs (oldAttrs: {
#		installPhase = "";
#	});

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

#  systemd = super.systemd.overrideAttrs (oldAttrs: {
#      patches = oldAttrs.patches or [] ++ [ #well this can't be used, it's recompiling to many other stuff like firefox,openjdk etc.
#      #./patches/systemd_30263.patch #removed from disk
#      ];
#  });
  mybin = super.rustPlatform.buildRustPackage rec {
    name = "mybin";
    version = "0.1.0";
    src = ./rustdylibusage/mybin/mybin-${version}.tar.gz;
    #cargoSha256 = "0qbdcw601m09fw7vqmafvw5q7w17dh37fbbycs6is3rff5qlmbyw"; #mybin
    #cargoSha256 = "sha256-i9TVX8LydRtaiEF0SAz0dKbdW2wMxrdisXkY293tI0Q";
    cargoHackageDeps = false;
    cargoBuildFlags = [ "--release" ];
    #cargoDepInputs = [ mylib ];
    buildInputs = [ self.mylib ];
    sourceRoot = "./";
    cargoLock = {
      lockFile = ./rustdylibusage/mybin/Cargo.lock;
    };

    #To can find the lib:
    libPath = super.lib.makeLibraryPath [ self.mylib ];
    fixupPhase = ''
      patchelf --set-rpath $libPath \
      $out/bin/mybin
      '';
#    fixupPhase = ''
#      patchelf --add-rpath $mylib/lib/libmylib.so \
#      $out/bin/mybin
#      '';

  };

  mylib = super.rustPlatform.buildRustPackage rec {
    version = "0.1.0";
    name = "mylib";
    src = ./rustdylibusage/mylib/mylib-${version}.tar.gz;
    #cargoSha256 = "1zwcx7637zl6ka058hfgwzmnxln1y592gfwiycxiz65qygxph383"; #mylib
    #cargoSha256 = "sha256-7AfdCKEh4xTyRir/hmA8I6WYnoPYAQH8NN1Jx19SYDc";
    cargoHackageDeps = false;
    cargoBuildFlags = [ "--release" ];
    sourceRoot = "./";
    cargoLock = {
      lockFile = ./rustdylibusage/mylib/Cargo.lock;
    };
  };



} #self/super

# vim: set tabstop=2 shiftwidth=2 softtabstop=2 expandtab :
