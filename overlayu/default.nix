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
      patches = [ ]; #FIXME: ./fookmi.patch ];
      postPatch = ''
      mv plugins/remote-dev-server plugins/remote-dev-server.tmp
      ${oldAttrs.postPatch}
      mv plugins/remote-dev-server.tmp plugins/remote-dev-server
      '';
      postFixup = builtins.replaceStrings [ "patchelf --set-interpreter" ]
      ["# patchelf --set-interpreter" ] (oldAttrs.postFixup or "");
      });
      };

}

# vim: set tabstop=2 shiftwidth=2 expandtab :
