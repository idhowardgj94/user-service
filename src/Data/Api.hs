{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE  DuplicateRecordFields #-}
module Data.Api where
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Logger ()
import Data.Aeson.TH
import Servant
import Servant.Server
import GHC.Generics
import Data.Aeson (FromJSON, ToJSON, Value, encode, genericToEncoding)
import Servant.Auth.Server (SetCookie)
import System.Log.FastLogger.LoggerSet (LoggerSet)
import Data.Time (UTCTime)
import Data.Text (Text)
import Data.Aeson.Types (ToJSON(toEncoding), FromJSON)
import System.Log.FastLogger (ToLogStr, toLogStr)
import qualified Data.Pool as P
import Database.MongoDB ( connect, host, close, access, master, Action (..), (=:), insertMany, auth, authMongoCR, authSCRAMSHA1, Pipe, Host )
import Control.Monad.Reader
import Data.User (User(..))

data AppCtx = AppM {
    _getLogger :: LoggerSet,
    _getConnPool :: P.Pool Pipe
}

type AppM = ReaderT AppCtx Handler
type Api = "api" :> "v1" :> (LoginApi :<|> PingApi :<|> RegisterApi)

type LoginApi = "login"
  :> ReqBody '[JSON] LoginRequest
  :> Post '[JSON] ( Headers '[ Header "Set-Cookie" SetCookie,  Header "Set-Cookie" SetCookie] Value)
type PingApi = "ping" :> Get '[JSON] Ping
type RegisterApi = "register"
  :> ReqBody '[JSON] RegisterForm
  :> Post '[JSON]  ApiResponse

newtype Ping = Ping {
    msg :: String 
} deriving Generic
instance FromJSON Ping
instance ToJSON Ping 

data LoginRequest = UserRequest {
  account :: String
  , password :: String
} deriving (Eq, Show, Generic)
instance FromJSON LoginRequest
instance ToJSON LoginRequest

type RegisterForm = User

data Status = Success | Error deriving (Show, Eq, Generic)
instance ToJSON Status
instance FromJSON Status
data ApiResponse = Response {
  status :: Status
  , msg :: String
} deriving (Eq, Show, Generic)
instance FromJSON ApiResponse
instance ToJSON ApiResponse 