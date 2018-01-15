{ mkDerivation, aeson, base, bytestring, classy-prelude
, classy-prelude-conduit, classy-prelude-yesod, conduit, containers
, data-default, directory, dns, fast-logger, file-embed, filepath
, fsnotify, hjsmin, hspec, http-conduit, lens, memoize, MissingH
, monad-control, monad-logger, network-info, pack-it-forms-msgfmt
, persistent, persistent-sqlite, persistent-template, resourcet
, safe, shakespeare, stdenv, stm, template-haskell, text, time
, transformers, unordered-containers, vector, wai-extra, wai-logger
, warp, yaml, yesod, yesod-auth, yesod-core, yesod-form
, yesod-static, yesod-test
}:
mkDerivation {
  pname = "pack-it-forms-dashboard";
  version = "0.0.0";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson base bytestring classy-prelude classy-prelude-conduit
    classy-prelude-yesod conduit containers data-default directory dns
    fast-logger file-embed filepath fsnotify hjsmin http-conduit lens
    memoize MissingH monad-control monad-logger network-info
    pack-it-forms-msgfmt persistent persistent-sqlite
    persistent-template safe shakespeare stm template-haskell text time
    unordered-containers vector wai-extra wai-logger warp yaml yesod
    yesod-auth yesod-core yesod-form yesod-static
  ];
  executableHaskellDepends = [ base ];
  testHaskellDepends = [
    base classy-prelude classy-prelude-yesod hspec monad-logger
    persistent persistent-sqlite resourcet shakespeare transformers
    yesod yesod-core yesod-test
  ];
  license = stdenv.lib.licenses.unfree;
}
