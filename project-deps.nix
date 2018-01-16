self: super:

{
  nixpkgs = self.releaseGHDevLocal {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "TODO";
    sha256 = "TODO";
    local = <nixpkgs>;
    fetch = super.nixpkgs.fetchFromGitHub;
  } { config = {}; };

  hsExtraDeps = {
    pack-it-forms-msgfmt = self.releaseGHDevLocal {
      owner = "pack-it-forms";
      repo = "msgfmt";
      rev = "TODO";
      sha256 = "TODO";
      local = ../pack-it-forms-msgfmt;
    };
  };
}
