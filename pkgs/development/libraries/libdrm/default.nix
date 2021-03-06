{ stdenv, fetchurl, pkgconfig, libpthreadstubs, libpciaccess, valgrind-light }:

stdenv.mkDerivation rec {
  name = "libdrm-2.4.89";

  src = fetchurl {
    url = "http://dri.freedesktop.org/libdrm/${name}.tar.bz2";
    sha256 = "629f9782aabbb4809166de5f24d26fe0766055255038f16935602d89f136a02e";
  };

  outputs = [ "out" "dev" "bin" ];

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ libpthreadstubs libpciaccess valgrind-light ];
    # libdrm as of 2.4.70 does not actually do anything with udev.

  patches = stdenv.lib.optional stdenv.isDarwin ./libdrm-apple.patch;

  preConfigure = stdenv.lib.optionalString stdenv.isDarwin
    "echo : \\\${ac_cv_func_clock_gettime=\'yes\'} > config.cache";

  configureFlags = [ "--enable-install-test-programs" ]
    ++ stdenv.lib.optionals (stdenv.isArm || stdenv.isAarch64)
      [ "--enable-tegra-experimental-api" "--enable-etnaviv-experimental-api" ]
    ++ stdenv.lib.optional stdenv.isDarwin "-C";

  crossAttrs.configureFlags = configureFlags ++ [ "--disable-intel" ];

  meta = {
    homepage = https://dri.freedesktop.org/libdrm/;
    description = "Library for accessing the kernel's Direct Rendering Manager";
    license = "bsd";
    platforms = stdenv.lib.platforms.unix;
  };
}
