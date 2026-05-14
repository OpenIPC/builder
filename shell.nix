{ pkgs ? import <nixpkgs> {} }:

# Buildroot hardcodes paths like /usr/bin/file and expects a FHS-ish host
# environment. pkgs.buildFHSEnv gives us that by bind-mounting a /usr tree
# populated from the listed packages.
(pkgs.buildFHSEnv {
  name = "openipc-builder";

  targetPkgs = pkgs: with pkgs; [
    gcc gnumake binutils pkg-config
    bison flex m4 gawk gnused gnugrep diffutils findutils coreutils
    patch which file bc cpio rsync
    gzip bzip2 xz unzip gnutar zstd
    wget curl git
    python3 perl
    ncurses ncurses.dev
    libxcrypt
    texinfo
    newt
    tree
    openssh
    util-linux
  ];

  runScript = "bash";

  profile = ''
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8
    echo "OpenIPC builder FHS shell ready. Run: ./builder.sh ssc338q_fpv_openipc-urllc-aio"
  '';
}).env
