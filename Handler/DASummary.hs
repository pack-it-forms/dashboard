{-# LANGUAGE OverloadedStrings #-}

module Handler.DASummary where

import Import
import PackItForms.MsgFmt as MF
import System.FSNotify as FN

watcher d = FN.withManager  $ \mgr -> do
            FN.watchDir mgr d (const True) print

getSummaryR :: Handler Html
getSummaryR = do
  let zones = [1..11]
      bats = []
  defaultLayout $ do
    setTitle "Los Altos Damage Status - Summary"
    let czone = Nothing :: Maybe Integer
        cbat = Nothing :: Maybe Integer
        navbar = $(widgetFile "navbar")
    $(widgetFile "summary")


getZoneR :: Integer -> Handler Html
getZoneR zone = do
  let zones = [1..11]
      bats = [118..131]
  defaultLayout $ do
    setTitle $ "Los Altos Damage Status - Zone " ++ (toHtml zone)
    let czone  = Just zone
        cbat = Nothing :: Maybe Integer
        navbar = $(widgetFile "navbar")
    $(widgetFile "zone")

getBatR :: Integer -> Integer -> Handler Html
getBatR zone bat = do
  let zones = [1..11]
      bats = [118..131]
  defaultLayout $ do
    setTitle $ "Los Altos Damage Status - BAT " ++ (toHtml bat)
    let czone = Just zone
        cbat = Just bat
        navbar = $(widgetFile "navbar")
    $(widgetFile "bat")

