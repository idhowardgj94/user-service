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
import qualified Servant.Auth as SA
import qualified Servant.Auth.Server as SAS 
import Network.HTTP.Media ((//), (/:))
import Network.Wai
import Network.Wai.Handler.Warp
    ( setLogger, setPort, runSettings, defaultSettings )
import Network.Wai.Logger
import qualified App as A
import System.Log.FastLogger( ToLogStr(..)
                        , LoggerSet
                        , defaultBufSize
                        , newStdoutLoggerSet
                        , flushLogStr
                        , pushLogStrLn )
import Db.Connection (createConnPool)
import Database.MongoDB (createCollection)
import qualified Servant.Auth.Server.Internal.Cookie as SAS
import Data.Api

main :: IO ()
main = withStdoutLogger $ \aplogger -> do
    appLogger <- newStdoutLoggerSet defaultBufSize 
    dbPool <- createConnPool 
    let settings = setPort 3000 $ setLogger aplogger defaultSettings
    -- cookie setting
    let cookieCfg = SAS.defaultCookieSettings{SAS.cookieIsSecure=SAS.NotSecure, SAS.cookieXsrfSetting=Nothing}
    -- JWT setting
    mykey <- SAS.generateKey 
    let jwtCfg = SAS.defaultJWTSettings mykey
    let cfg = cookieCfg :. jwtCfg :. EmptyContext 

    runSettings settings $ A.app cfg cookieCfg jwtCfg (AppM appLogger dbPool)
    return ()