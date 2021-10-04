{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE NamedFieldPuns #-}

module Db where

import Control.Monad.IO.Class (liftIO)
import Database.MongoDB ( connect, host, close, access, master, Action (..), Value, (=:), insertMany, auth, authMongoCR, authSCRAMSHA1 )
import qualified  Database.MongoDB.Query as Q
import Control.Monad.Cont
import Control.Monad.RWS ()
import Data.User
import qualified Data.Bson as B

db :: Action IO () ->IO ()
db run = do
    pipe <- connect (host "127.0.0.1")
    e <- access pipe master "user" run
    close pipe
    print e

insertUser :: User ->  Action IO ()
insertUser User{ name, email, password } = do
    Q.insert "users" [ "name" =: name, "email" =: email, "password" =: password ]
    return ()

type Result = Action IO

findByUserName :: String -> Result (Maybe User)
findByUserName username = do
    res <- Q.findOne (Q.select ["name" =: username ] "users")
    liftIO $ print res
    return $ case res of
      Nothing -> Nothing
      Just res -> User <$> B.lookup "name" res
                <*> B.lookup "email" res
                <*> B.lookup "password" res

print' :: Show m =>  Result m -> Result ()
print' res = do
    str <-  res
    liftIO $ print str