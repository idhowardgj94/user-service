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
import Network.HTTP.Media ((//), (/:))
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Logger
import Api ( api, pingApi )
 
main :: IO ()
main = withStdoutLogger $ \aplogger -> do 
    let settings = setPort 3000 $ setLogger aplogger defaultSettings
    runSettings settings app

-- main application
app :: Application
app = serve api pingApi



