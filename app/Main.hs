{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
module Main where

import Lib
import Prelude;
import Data.Aeson.TH
import Servant
import GHC.Generics
import Data.Aeson (FromJSON, ToJSON)
import Network.HTTP.Media ((//), (/:))
import Network.Wai
import Network.Wai.Handler.Warp

main :: IO ()
main = run 3000 app



type API = PingApi
type PingApi = "ping" :> Get '[JSON] Ping

-- data type
newtype Ping = Ping {
    message :: String 
} deriving Generic

instance FromJSON Ping
instance ToJSON Ping 
-- helper function
pong = Ping "pong"

api :: Proxy PingApi
api = Proxy


pingApi :: Server PingApi
pingApi = return pong

-- main application
app :: Application
app = serve api pingApi