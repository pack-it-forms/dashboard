{-# LANGUAGE OverloadedStrings #-}

module PackItForms.NetInfo (getNetInfo
                           ,NetInfo(..)) where

import Import.NoFoundation

import qualified Data.ByteString.Char8 as B8
import Data.Function.Memoize (memoize, Memoizable(..), memoizeFinite)
import Data.List (init)
import Network.Info
import Network.DNS.Lookup
import Network.DNS.Resolver
import Network.DNS.Types

data NetInfo = NetInfo { wired :: String
                        ,wifi :: String }
                       deriving (Show)

type IntfName = String

newtype IPv4Addr = IPv4Addr IPv4
   deriving (Eq, Bounded, Ord)

instance Show IPv4Addr where
  show (IPv4Addr a) = show a

instance Enum IPv4Addr where
  fromEnum (IPv4Addr (IPv4 w)) = fromEnum w
  toEnum i = IPv4Addr (IPv4 (toEnum i))

instance Memoizable IPv4Addr where memoize = memoizeFinite

getNetInfo :: IO NetInfo
getNetInfo = do
  s <- intfInfo "eth0"
  return NetInfo { wired = s, wifi = "---" }

intfInfo :: IntfName -> IO String
intfInfo i = do
  ipaddr <- intfIPAddr i
  name <- case ipaddr of
            Nothing -> return Nothing
            Just a -> lookupName a
  case (name, ipaddr) of
    (Just n, Just a) -> return $ mconcat [(init n), " (", (show a), ")"]
    (Nothing, Just a) -> return (show a)
    _ -> return "---"

intfIPAddr :: IntfName -> IO (Maybe IPv4Addr)
intfIPAddr i = do
  intfs <- getNetworkInterfaces
  return $ IPv4Addr . ipv4 <$> find (\e -> name e == i) intfs

lookupName :: IPv4Addr -> IO (Maybe String)
lookupName = memoize lookupName'


lookupName' :: IPv4Addr -> IO (Maybe String)
lookupName' a = either (\_ -> Nothing) (\(x:_) -> Just (B8.unpack x)) <$> ipv4Names a

ipv4Names :: IPv4Addr -> IO (Either DNSError [Domain])
ipv4Names a = do
  let c = defaultResolvConf{ resolvTimeout = 2000, resolvRetry = 1 }
  s <- makeResolvSeed c
  withResolver s $ (\r -> lookupRDNS r $ B8.pack $ show a)
