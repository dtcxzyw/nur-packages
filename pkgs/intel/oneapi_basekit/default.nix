# adapted from https://github.com/Gricad/nur-packages/blob/master/pkgs/intel/oneapi.nix
{ lib, stdenv, fetchurl, autoPatchelfHook, gcc, glibc, libX11, glib, libnotify, xdg-utils, ncurses, nss, at-spi2-core, libxcb, libdrm, gtk3, mesa, qt515, zlib }:

stdenv.mkDerivation rec {
  version = "2022.2.0.262"; 
  name = "intel-oneapi-${version}";

  # For localy downloaded offline installers
  # sourceRoot = "/data/scratch/intel/oneapi_installer";
 
  # For installer fetching (no warranty of the links)
  sourceRoot = ".";
  srcs = [
    (fetchurl {
      url = "https://registrationcenter-download.intel.com/akdlm/irc_nas/18673/l_BaseKit_p_2022.2.0.262_offline.sh";
      sha256 = "c6957c5415f270d790c495f7564a18d4481883276a23e6e36170565496361d0f";
    })
  ];

  buildInputs = [ gcc glibc glib libnotify xdg-utils ncurses nss at-spi2-core libxcb libdrm gtk3 mesa qt515.full zlib ];

  nativeBuildINputs = [ autoPatchelfHook ];

  phases = [ "installPhase" "fixupPhase" "installCheckPhase" "distPhase" ];

  installPhase = ''
     cd $sourceRoot
     mkdir -p $out/tmp
     if [ "$srcs" = "" ]
     then
       base_kit="./l_BaseKit_p_${version}_offline.sh"
     else
       base_kit=`echo $srcs|cut -d" " -f1`
     fi
     bash $base_kit --log $out/basekit_install_log --extract-only --extract-folder $out/tmp -a --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp
     $out/tmp/l_BaseKit_p_${version}_offline/install.sh --install-dir $out --download-cache $out/tmp --download-dir $out/tmp --log-dir $out/tmp
     rm -rf $out/tmp
  '';

  postFixup = ''
    echo "Fixing rights..."
    chmod u+w -R $out
  '';

  meta = {
    description = "Intel OneAPI Basekit";
    maintainers = [ lib.maintainers.dtcxzyw ];
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
  };
}

