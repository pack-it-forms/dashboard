self: super:

{
  nixpkgs = self.releaseGHDevLocal {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "66b4de79e3841530e6d9c6baf98702aa1f7124e4";
    sha256 = "1l3lwi944hnxka0nfq9a1g86xhc0b8hzqr2fm6cvds33gj26l0g4";
    local = <nixpkgs>;
    fetch = super.nixpkgs.fetchFromGitHub;
  } { config = {}; };

  hsExtraDeps = {
    pack-it-forms-msgfmt = self.releaseGHDevLocal {
      owner = "pack-it-forms";
      repo = "msgfmt";
      rev = "64274e480c88921f418f96fa8c581c286d173642";
      sha256 = "1hig48wgbams379hwm7q9hjygilm1gmjqaq1i7llfw1sk9wps7sy";
      local = ../pack-it-forms-msgfmt;
    };
  };
}
