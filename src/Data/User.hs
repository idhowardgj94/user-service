{-# LANGUAGE DeriveGeneric #-}
module Data.User where

import GHC.Generics
import Prelude
import Data.Aeson (ToJSON, FromJSON)

data User = User {
    name :: String,
    email :: String,
    password :: String
} deriving (Show, Generic)

instance ToJSON User
instance FromJSON User
