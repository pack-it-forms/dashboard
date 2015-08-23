{-# LANGUAGE OverloadedStrings #-}

import Import
import PackItForms.MsgFmt as MF
import System.FSNotify as FN

watcher d = FN.withManager  $ \mgr -> do
            FN.watchDir mgr d (const True) printn
