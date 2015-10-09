module PackItForms.ZoneMappingLoader
       (loadZoneMapping) where

import Import
import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy as B
import qualified PackItForms.LADamage as LAD

loadZoneMapping :: IO (LAD.ZoneMapping)
loadZoneMapping = do
  json <- B.readFile "static/map-data/zone-bat-mapping.json"
  let mappings = (A.decode json) :: Maybe [[Integer]]
      acc zm (b:z:[]) = LAD.insert zm z b
      acc zm _ = zm
  return $ foldl' acc LAD.empty $ fromMaybe ([]) mappings

