module Handler.Home where

import Handler.DASummary
import Import
import Yesod()

getHomeR :: Handler Html
getHomeR = getSummaryR
