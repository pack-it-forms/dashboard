{-|
Module      : PackItForms.BATZoneStatus
Description : Record for storing BAT/zone statuses
Copyright   : (c) 2015 Peter Amidon <peter@picnicpark.org>
License     : Apache-2

This module the 'BATZoneStatuses' type and code to generate it from
message files.

-}

module PackItForms.BatZoneStatuses where

import qualified Data.Map as M

import Import.NoFoundation hiding (Update) -- Update is a phantom type used by BATStatus
-- import System.Environment
-- import System.Directory
import Data.Map()
-- import qualified Data.List as L
-- import Control.Lens

-- import qualified PackItForms.MsgFmt as MF
-- import qualified PackItForms.ICS213 as ICS213
import qualified PackItForms.LADamage as LAD

data BatZoneStatuses = BatZoneStatuses {
    zoneStatuses :: M.Map LAD.ZoneNum LAD.ZoneStatus
  , batStatuses :: M.Map LAD.BATNum (LAD.BATStatus LAD.Accumulated)
  , batStatusUpdates :: M.Map LAD.BATNum [LAD.BATStatus LAD.Update] }

initBatZoneStatuses :: LAD.ZoneMapping -> IO BatZoneStatuses
initBatZoneStatuses _ = return $ BatZoneStatuses M.empty M.empty M.empty
