{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RankNTypes #-}

module Db.UserRepository where
import Db.Connection
import Control.Monad.IO.Class (liftIO)
import Database.MongoDB ( connect, host, close, access, master, Action (..), Value, (=:), insertMany, auth, authMongoCR, authSCRAMSHA1, Pipe )
import qualified  Database.MongoDB.Query as Q
import Control.Monad.Cont
import Control.Monad.RWS ()
import qualified Data.User as U
import qualified Data.Bson as B
import GHC.Generics (Generic)
import Data.Api (RegisterForm (..))
import qualified Data.Password.Bcrypt as PB
import Data.String.Conversions (cs)
import Data.Password.Scrypt (PasswordHash(unPasswordHash))
import Data.Text

insertUser :: U.User ->  Action IO  ()
insertUser U.User{ U.name=n, U.email=e, U.password=p } = do
    hashM <- liftIO $ PB.hashPassword $ PB.mkPassword (cs p)
    let hashp = unPasswordHash hashM
    Q.insert "users" [ "name" =: n, "email" =: e, "password" =: (cs hashp :: String) ]
    return ()

findByUserName :: String -> Action IO (Maybe U.User)
findByUserName username = do
    res <- Q.findOne (Q.select ["name" =: username ] "users")
    liftIO $ print res
    return $ case res of
      Nothing -> Nothing
      Just res -> U.User <$> B.lookup "name" res
                <*> B.lookup "email" res
                <*> B.lookup "password" res

