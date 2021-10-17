{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module App where

import Lib
import Prelude;
import Data.Aeson.TH
import Servant
import Network.HTTP.Media ((//), (/:))
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Logger
import Server ( api, apiServer  )
import System.Log.FastLogger.LoggerSet (LoggerSet)
import Data.Api
import Control.Monad.Reader ( ReaderT(runReaderT) )
import qualified Servant.Auth.Server as SAS
import Servant.Auth.Server (CookieSettings, JWTSettings)

app :: Context '[SAS.CookieSettings, SAS.JWTSettings ] -> CookieSettings -> JWTSettings -> AppCtx ->  Application
app cfg cs jwts env = serveWithContext api cfg $ 
 hoistServerWithContext api (Proxy :: Proxy '[SAS.CookieSettings, SAS.JWTSettings ] ) (`runReaderT` env) (apiServer cs jwts)