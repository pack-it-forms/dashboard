module Handler.Home where

import Handler.DASummary
import Import
import Yesod()

getHomeR :: Handler TypedContent
getHomeR = getSummaryR
