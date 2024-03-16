self: super: {
    #ccacheWrapper = assert 2+2 == 4; super.ccacheWrapper.override {
    ccacheWrapper = assert 2+2 == 4; (super.ccacheWrapper.override {
      #cmake = self.cmake2; #this won't work here
      }).overrideAttrs (oldAttrs: { #this line's needed to can override extraConfig, oddly enough.

      # '${extraConfig}'" ''
      extraConfig = builtins.trace "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX using ccache overrides from ccache_overlay" ''
        #export CCACHE_DIR="$\{self.options.programs.ccache.cacheDir}" #FIXME: how to not err here ffs?!
        export CCACHE_DIR="/var/cache/ccache" #FIXME: hardcoded until I figure out how to refer to cfg.ccacheDir from /etc/nixos/nixpkgs/nixos/modules/programs/ccache.nix

              #XXX: anything in here like 'false' that returns exit code non-zero will break the build (doesn't matter if NIX_DEBUG is unset or set to non-zero or zero)
              #false #<= that breaks the build due to 'set -e' being set in the gcc wrapper eg. set -eu -o pipefail +o posix /nix/store/d2b32n6jpah9c2vdnkcpz4jxnkwkhzsx-ccache-links-wrapper-4.9.1/bin/gcc
              #even this script here in extraConfig which is found in like /nix/store/czrhqbzm94c8n4jfa4jxjdqva55lhslj-ccache-links-4.9.1/bin/gcc  has bash -e as interpreter
              #export CCACHE_COMPRESS=1
							unset CCACHE_COMPRESS
							export CCACHE_NOCOMPRESS=1
							export CCACHE_TEMPDIR="/tmp"
							unset CCACHE_HARDLINK
							export CCACHE_NOHARDLINK=1
#							#export -n CCACHE_HASHDIR
							unset CCACHE_HASHDIR
							export CCACHE_NOHASHDIR=1
#							#export CCACHE_BASEDIR="/nix/store/"
							export CCACHE_BASEDIR="/"
							export CCACHE_SLOPPINESS="include_file_mtime,file_stat_matches,include_file_ctime,file_stat_matches_ctime"
							export CCACHE_IGNOREOPTIONS="-frandom-seed=*" #space delimited, can end in * for each option
              export CCACHE_MAXSIZE="50Gi"
              #export CCACHE_DIR="$\{cfg.cacheDir}"
              export CCACHE_UMASK=007 #so o-rwx
              export | grep --color=always CCACHE 1>&2
              #echo "hi$(tput setaf 1)mootwo" 1>&2
              #echo "TERM=1''${TERM}1" 1>&2
              #export | grep TERM 1>&2
#              echo -e ']' 1>&2 #[ or ] here makes it compile but fail to load some .so when run (eg. for keepassxc) due to unpaired square brackets treating multiple lines as one big line due to https://gitlab.kitware.com/cmake/cmake/-/issues/19156 and thus `warn: unable to parse implicit include dirs!` so this cmake var CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES has only one include dir instead of tens of them, thus the resulting keepassxc binary somehow getting `keepassxc: error while loading shared libraries: libQt5Svg.so.5: cannot open shared object file: No such file or directory` because of all that, so build doesn't fail but the exe does! see also: https://cmake.org/cmake/help/v3.0/manual/cmake-language.7.html#lists and https://cmake.org/cmake/help/v3.0/manual/cmake-language.7.html#bracket-argument
              #echo 1>&2
              #export | grep --color=always NIX_DEBUG 1>&2
              #export | grep --color=never NIIX_DEBUGGGG 1>&2
              #export | grep --color=never A_E 1>&2
              #echo A_E 1>&2
#              export NIX_DEBUG=9
              #echo 'declare -x $(tput setaf 1)NIX_DEBUG$(tput sgr0)="8"' 1>&2
##							#exit 2
#							set -xv

        #export | grep --color=always CCACHE 1>&2 #shows these for every file about to get compiled!

        if [ ! -d "$CCACHE_DIR" ]; then
          echo "====="
          echo "Directory '$CCACHE_DIR' does not exist"
          echo "Please create it with:"
          echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
          echo "  sudo chown root:nixbld '$CCACHE_DIR'"
          echo "====="
          exit 1
        fi
        if [ ! -w "$CCACHE_DIR" ]; then
          echo "====="
          echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
          echo "Please verify its access permissions"
          echo "====="
          exit 1
        fi
      '';
    #};
    });

    #keepassxc = super.keepassxc.override { stdenv = super.ccacheStdenv; };
  }
