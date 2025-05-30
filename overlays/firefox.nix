self: super: {
  my-firefox-bin = super.stdenv.mkDerivation rec {
    pname = "firefox-moz-build";
    version = super.firefox-bin.version;

    nativeBuildInputs = [ super.makeWrapper ];
    src = super.firefox-bin;

    unpackPhase = "true"; # Already built

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${src}/bin/firefox \
        $out/bin/firefox \
        --set MOZ_DISABLE_AUTO_SAFE_MODE 1 \
        --set MOZ_ALLOW_DOWNGRADE 1 \
        --set MOZ_LEGACY_PROFILES 1 \
        --set-default MOZ_APP_LAUNCHER firefox \
        --set-default MOZ_BROWSER_TOOLBOX_FISSION 1
    '';

    meta = super.firefox-bin.meta // {
      description = "Wrapped Firefox binary that supports extensions and profiles";
    };
  };
}
