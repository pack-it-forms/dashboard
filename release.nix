let
  projectPkgs = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = new: old: rec {
        sdtpl = old.callPackage ./sdtpl.nix {};
        pack-it-forms-msgfmt = old.callPackage ./pack-it-forms-msgfmt.nix {};
        pack-it-forms-dashboard = old.callPackage ./default.nix {};
      };
    };
  };

  pkgs = import <nixpkgs> { overlays = [ projectPkgs ];
                            config = { allowUnfree = true; }; };
in
  { pack-it-forms-dashboard = pkgs.haskellPackages.pack-it-forms-dashboard; }
