{-# LANGUAGE DeriveGeneric #-}
module Data.User where

import GHC.Generics
import Prelude
import Data.Aeson (ToJSON, FromJSON)
import Servant.Auth as SA
import Servant.Auth.Server as SAS ( FromJWT, ToJWT )
import Data.Text (Text)
import Data.String.Conversions (cs)
data User = User {
    name :: String,
    email :: String,
    password :: String
} deriving (Show, Generic)
instance ToJSON User
instance FromJSON User

newtype UserInfo = UserInfo {
                  username :: Text
} deriving (Eq, Show, Read, Generic)
instance ToJSON UserInfo
instance FromJSON UserInfo
instance SAS.ToJWT UserInfo
instance SAS.FromJWT UserInfo


