{-# LANGUAGE OverloadedStrings #-}

module Handler.DASummary where

import Import
import qualified Data.List as L
import qualified PackItForms.LADamage as LAD
-- import System.FSNotify as FN

-- watcher d = FN.withManager  $ \mgr -> do
--             FN.watchDir mgr d (const True) print

getSummaryR :: Handler Html
getSummaryR = do
  App {..} <- getYesod
  let zones = LAD.zones zoneMapping
      bats = [] :: [Integer]
  defaultLayout $ do
    setTitle "Los Altos Damage Status - Summary"
    let czone = Nothing :: Maybe Integer
        cbat = Nothing :: Maybe Integer
        navbar = $(widgetFile "navbar")
        areamap = mapW "cityMap" (-122.09847, 37.36513, 13)
                    ("/static/map-data/zones.kml", [])
                    ("/static/map-data/zones.kml", [])
        summaries =  L.foldr1 (>>) $ map (zoneSummaryW zoneMapping) zones
    $(widgetFile "summary")

zoneSummaryW :: LAD.ZoneMapping -> LAD.ZoneNum -> Widget
zoneSummaryW zoneMapping zone = $(widgetFile "zone-summary")
  where
    zbats = fromMaybe [] $ LAD.batsOfZone zoneMapping zone
    batbadges = L.foldr1 (>>) $ map (batBadgeW zone) zbats

batBadgeW :: LAD.ZoneNum -> LAD.BATNum -> Widget
batBadgeW zone bat = toWidget [hamlet|
  <a href=@{BatR zone bat}>
    <img src=@{StaticR img_status_badge_unknown_png}>|]

getZoneR :: Integer -> Handler Html
getZoneR zone = do
  App {..} <- getYesod
  let zones = LAD.zones zoneMapping
      bats = fromMaybe [] $ LAD.batsOfZone zoneMapping zone
  defaultLayout $ do
    setTitle $ "Los Altos Damage Status - Zone " ++ (toHtml zone)
    let czone  = Just zone
        cbat = Nothing :: Maybe Integer
        navbar = $(widgetFile "navbar")
        areamap = mapW "zoneMap" (-122.09847, 37.36513, 13)
                    ("/static/map-data/zones.kml", ["Zone " ++ (show zone)])
                    ("/static/map-data/bats.kml", ["BAT " ++ (show b) | b <- bats])
    $(widgetFile "zone")

getBatR :: Integer -> Integer -> Handler Html
getBatR zone bat = do
  App {..} <- getYesod
  let zones = LAD.zones zoneMapping
      bats = fromMaybe [] $ LAD.batsOfZone zoneMapping zone
  defaultLayout $ do
    setTitle $ "Los Altos Damage Status - BAT " ++ (toHtml bat)
    let czone = Just zone
        cbat = Just bat
        navbar = $(widgetFile "navbar")
        areamap = mapW "batMap" (-122.09847, 37.36513, 13)
                    ("/static/map-data/bats.kml", ["BAT " ++ (show bat)])
                    ("/static/map-data/bats.kml", ["BAT " ++ (show bat)])
    $(widgetFile "bat")

type Longitude = Double
type Lattitude = Double
type MapZoom = Integer

mapW :: String -> (Longitude, Lattitude, MapZoom) -> (String, [String]) -> (String, [String]) -> Widget
mapW mapId (longitude, lattitude, zoom)
           (clip_source_kml, clip_source_features)
           (areas_source_kml, areas_source_features) = do
  addStylesheet $ StaticR openlayers_ol_css
  addScript $ StaticR openlayers_ol_js
  $(widgetFile "map")
