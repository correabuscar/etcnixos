self: super: {
    #ccacheWrapper = assert 2+2 == 4; super.ccacheWrapper.override {
    ccacheWrapper = assert 2+2 == 4; (super.ccacheWrapper.override { 
      #cmake = self.cmake2; #this won't work here
      }).overrideAttrs (oldAttrs: {

      #extraConfig = super.pkgs.lib.mkForce builtins.trace "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX some ccache shie" ''
      extraConfig = builtins.trace "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX some ccache shie" ''
        unset CCACHE_COMPRESS
        export CCACHE_NOCOMPRESS=1
        export CCACHE_TEMPDIR="/tmp"
        unset CCACHE_HARDLINK
        export CCACHE_NOHARDLINK=1
        unset CCACHE_HASHDIR
        #export -n CCACHE_HASHDIR
        export CCACHE_NOHASHDIR=1
        #export CCACHE_BASEDIR="/nix/store/"
        export CCACHE_BASEDIR="/
        export CCACHE_SLOPPINESS="include_file_mtime,file_stat_matches,include_file_ctime,file_stat_matches_ctime"
        export CCACHE_IGNOREOPTIONS="-frandom-seed=*" #space delimited, can end in *

        export CCACHE_DIR="${self.config.programs.ccache.cacheDir}" #FIXME: how to not err here ffs?!
        export CCACHE_UMASK=007

        export | grep --color=always CCACHE 1>&2 #shows these for every file about to get compiled!

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
    });

    #keepassxc = super.keepassxc.override { stdenv = super.ccacheStdenv; };
  }
