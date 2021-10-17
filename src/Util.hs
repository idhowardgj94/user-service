{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module Util where
import Data.Time.Clock (UTCTime, getCurrentTime)
import Data.Text
import GHC.Generics (Generic)
import Data.Aeson (FromJSON, ToJSON, encode)
import System.Log.FastLogger
import Data.String.Conversions (cs)
import Data.User (User (User), UserInfo (UserInfo))
import Data.Api (ApiResponse (Response), Status(Success, Error))
import Data.Aeson.Types
    ( defaultOptions, ToJSON(toEncoding), FromJSON, genericToEncoding )

data LogMessage = LogMessage {
    message :: !Text
    , timestamp :: !UTCTime
    , level :: !Text
} deriving (Eq, Show, Generic)

instance FromJSON LogMessage
instance ToJSON LogMessage where
    toEncoding = genericToEncoding defaultOptions
instance ToLogStr LogMessage where
    toLogStr = toLogStr . encode 
data Level = Info | Warning | Debug | Err
type Message = String

log :: LoggerSet -> Level -> Message -> IO ()
log logset i s = getCurrentTime >>= (\t -> 
    case i of 
        Info -> pushLogStrLn logset $ toLogStr $ LogMessage (cs s) t "INFO"
        Warning -> pushLogStrLn logset $ toLogStr $ LogMessage (cs s) t "WARNING"
        Debug ->  pushLogStrLn logset $ toLogStr $ LogMessage (cs s) t "DEBUG"
        Err ->  pushLogStrLn logset $ toLogStr $ LogMessage (cs s) t "ERROR"
    )

toUserInfo :: User -> UserInfo
toUserInfo (User n _ _ ) = UserInfo $ cs n

success :: String -> ApiResponse
success = Response Success

err :: String -> ApiResponse
err = Response Error