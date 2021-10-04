{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
module Api where
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Logger
import Data.Aeson.TH
import Servant
import GHC.Generics
import Data.Aeson (FromJSON, ToJSON)

type API = PingApi
type PingApi = "ping" :> Get '[JSON] Ping

apiData = "hello, world"

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