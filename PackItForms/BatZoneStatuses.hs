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
import System.Directory
import qualified System.FilePath as FP
import Data.Map()
import Data.Either
import Data.Either.Utils
import Control.Lens

import qualified PackItForms.MsgFmt as MF
import qualified PackItForms.ICS213 as ICS213
import PackItForms.LADamage

data BatZoneStatuses = BatZoneStatuses {
    zoneStatuses :: M.Map ZoneNum ZoneStatus
  , batStatuses :: M.Map BATNum (BATStatus Accumulated)
  , batStatusUpdates :: M.Map BATNum [BATStatus Update]
  } deriving (Show)

initBatZoneStatuses :: AppSettings -> ZoneMapping -> IO BatZoneStatuses
initBatZoneStatuses AppSettings{appMsgsDir=amd} zm = do
  files <- join $ filterM doesFileExist
                  <$> fmap (FP.joinPath . (amd:) . (:[]))
                  <$> getDirectoryContents amd
  msgs <- mapM (liftM ICS213.fromMsgFmt . MF.parseFile) files :: IO [ICS213.Msg LADamageBody]
  let statusUpdates = concatMap (statuses . body) $ sortMsgs msgs
      batStatusUpdates = foldl' mkBatStatusUpdates M.empty statusUpdates
      batStatuses = M.map rollupBATStatuses batStatusUpdates
      zoneStatuses = rollupZoneStatuses zm $ M.elems batStatuses
      allBats = M.keys (batsToZones zm)
      allZones = M.keys (zonesToBats zm)
      defaultBatStatusUpdates = M.fromList $ map (\n -> (n, [])) allBats
      batStatusUpdates' = M.union batStatusUpdates defaultBatStatusUpdates
      defaultBatStatuses = M.fromList $ map (\n -> (n, defaultBatStatus n)) allBats
      batStatuses' = M.union batStatuses defaultBatStatuses
      defaultZoneStatuses = M.fromList $ map (\n -> (n, defaultZoneStatus n)) allZones
      zoneStatuses' = M.union zoneStatuses defaultZoneStatuses
  return $ BatZoneStatuses zoneStatuses' batStatuses' batStatusUpdates'
  where sortMsgs = sortBy cmpStatusTimes . filter onlyTimes
          where cmpStatusTimes (ICS213.Msg h1 _ _) (ICS213.Msg h2 _ _) =
                  (compare `on` fromRight . ICS213.formTime) h1 h2
                onlyTimes (ICS213.Msg h _ _) = isRight $ ICS213.formTime h
        body (ICS213.Msg _ b _) = b
        mkBatStatusUpdates :: M.Map BATNum [BATStatus Update]
                           -> BATStatus Update
                           -> M.Map BATNum [BATStatus Update]
        mkBatStatusUpdates m u = m & at n %~ addBAT
            where n = either (const (-1)) id (u ^. number)
                  addBAT ls = Just $ maybe [u] (\xs -> u:xs) ls
        defaultBatStatus n = BATStatus { _number = Right n
                                       , _okay = Nothing
                                       , _minorInjuryCnt = Nothing
                                       , _delayedInjuryCnt = Nothing
                                       , _immediateInjuryCnt = Nothing
                                       , _fatalityCnt = Nothing
                                       , _missingCnt = Nothing
                                       , _trappedCnt = Nothing
                                       , _lightDamageCnt = Nothing
                                       , _moderateDamageCnt = Nothing
                                       , _heavyDamageCnt = Nothing
                                       , _fireCnt = Nothing
                                       , _electricHazardCnt = Nothing
                                       ,  _waterHazardCnt = Nothing
                                       , _gasHazardCnt = Nothing
                                       , _chemicalHazardCnt = Nothing
                                       , _roadBlocked = Nothing }
        defaultZoneStatus n = ZoneStatus { _zoneNum = n
                                         , _numBATs = zoneBATNum n
                                         , _okayCnt = CoveredField 0 0
                                         , _minorInjurySum = CoveredField 0 0
                                         , _delayedInjurySum = CoveredField 0 0
                                         , _immediateInjurySum = CoveredField 0 0
                                         , _fatalitySum = CoveredField 0 0
                                         , _missingSum = CoveredField 0 0
                                         , _trappedSum = CoveredField 0 0
                                         , _lightDamageSum = CoveredField 0 0
                                         , _moderateDamageSum = CoveredField 0 0
                                         , _heavyDamageSum = CoveredField 0 0
                                         , _fireSum = CoveredField 0 0
                                         , _electricHazardSum = CoveredField 0 0
                                         , _waterHazardSum = CoveredField 0 0
                                         , _gasHazardSum = CoveredField 0 0
                                         , _chemicalHazardSum = CoveredField 0 0
                                         , _roadBlockedCnt = CoveredField 0 0 }
        zoneBATNum n = length $ zonesToBats zm M.! n
