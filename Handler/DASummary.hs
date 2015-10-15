{-# LANGUAGE OverloadedStrings #-}

module Handler.DASummary where

import Import
import qualified Data.List as L
import qualified Data.Map as M
import qualified PackItForms.LADamage as LAD
import PackItForms.BatZoneStatuses

getSummaryR :: Handler TypedContent
getSummaryR = selectRep $ do
    provideRep $ do
        defaultLayout $ do
        App {..} <- getYesod
        let zones = LAD.zones zoneMapping
            clipAreas = MapAreas map_data_zones_kml []
            overlayAreas = MapAreas map_data_zones_kml []
            areamap = mapW "cityMap" centerOfLosAltos 13 clipAreas overlayAreas
            summaries =  L.foldr1 (>>) $ map (zoneSummaryW zoneMapping) zones
        setTitle "Los Altos Damage Status - Summary"
        navbarW Nothing (LAD.zones zoneMapping) Nothing []
        $(widgetFile "summary")
    provideRep $ do
        App {..} <- getYesod
        bzs <- liftIO $ readTVarIO statuses
        render <- getUrlRender
        let allZones = M.keys (LAD.zonesToBats zoneMapping)
            mkZoneRec zn = object [ "number" .= zn
                                  , "summary" .= (zoneStatuses bzs M.! zn)
                                  , "link" .= render (ZoneR zn)
                                  ]
        return $ toJSON [ map mkZoneRec allZones ]

getZoneR :: Integer -> Handler TypedContent
getZoneR zone = selectRep $ do
    provideRep $ do
        defaultLayout $ do
            App {..} <- getYesod
            let zones = LAD.zones zoneMapping
                bats = fromMaybe [] $ LAD.batsOfZone zoneMapping zone
                clipAreas = MapAreas map_data_zones_kml ["Zone " ++ (show zone)]
                overlayAreas = MapAreas map_data_bats_kml ["BAT " ++ (show b) | b <- bats]
                areamap = mapW "zoneMap" centerOfLosAltos 13 clipAreas overlayAreas
            setTitle $ "Los Altos Damage Status - Zone " ++ (toHtml zone)
            navbarW (Just zone) zones Nothing bats
            $(widgetFile "zone")
    provideRep $ do
        App {..} <- getYesod
        bzs <- liftIO $ readTVarIO statuses
        render <- getUrlRender
        return $ object
            [ "zoneStatus" .= (zoneStatuses bzs M.! zone)
            , "batStatuses" .= (map (createJSONSummary render bzs)
                               (LAD.zonesToBats zoneMapping M.! zone))
            ]
  where createJSONSummary render bzs bn
            = object [ "number" .= bn
                     , "summary" .= (bs M.! bn)
                     , "link" .= render (BatR zone bn) ]
          where bs = (batStatuses bzs)

getBatR :: Integer -> Integer -> Handler TypedContent
getBatR zone bat = selectRep $ do
    provideRep $ do
        defaultLayout $ do
            App {..} <- getYesod
            let zones = LAD.zones zoneMapping
                bats = fromMaybe [] $ LAD.batsOfZone zoneMapping zone
                clipAreas = MapAreas map_data_bats_kml ["BAT " ++ (show bat)]
                overlayAreas = MapAreas map_data_bats_kml ["BAT " ++ (show bat)]
                areamap = mapW "batMap" centerOfLosAltos 13 clipAreas overlayAreas
            setTitle $ "Los Altos Damage Status - BAT " ++ (toHtml bat)
            navbarW (Just zone) zones (Just bat) bats
            $(widgetFile "bat")
    provideRep $ do
        App {..} <- getYesod
        bzs <- liftIO $ readTVarIO statuses
        return $ object
            [ "batStatusUpdates" .= (batStatusUpdates bzs M.! bat)
            , "aggregateBatStatus" .= (batStatuses bzs M.! bat)
            ]

navbarW :: Maybe LAD.ZoneNum -> [LAD.ZoneNum]
             -> Maybe LAD.BATNum -> [LAD.BATNum] -> Widget
navbarW czone zones cbat bats = $(widgetFile "navbar")

zoneSummaryW :: LAD.ZoneMapping -> LAD.ZoneNum -> Widget
zoneSummaryW zoneMapping zone = $(widgetFile "zone-summary")
  where
    zbats = fromMaybe [] $ LAD.batsOfZone zoneMapping zone
    batbadges = L.foldr1 (>>) $ map (batBadgeW zone) zbats

batBadgeW :: LAD.ZoneNum -> LAD.BATNum -> Widget
batBadgeW zone bat = toWidget [hamlet|
  <a href=@{BatR zone bat}>
    <img src=@{StaticR img_status_badge_unknown_png} title="BAT #{bat}">|]

type Longitude = Double
type Lattitude = Double
data GeoPt = GeoPt { longitude :: Longitude
                    ,lattitude :: Lattitude }

centerOfLosAltos :: GeoPt
centerOfLosAltos = GeoPt (-122.09847) 37.36513

type MapZoom = Integer

data MapAreas = MapAreas { kmlUrl :: Route Static
                          ,areaNames :: [String] }

mapW :: String -> GeoPt -> MapZoom -> MapAreas -> MapAreas -> Widget
mapW mapId centerPt initialZoom clipAreas overlayAreas = do
  addStylesheet $ StaticR openlayers_ol_css
  addScript $ StaticR openlayers_ol_js
  $(widgetFile "map")
