{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ExtendedDefaultRules #-}
{-# LANGUAGE NamedFieldPuns #-}

module Db.Connection where

import Control.Monad.IO.Class (liftIO)
import Database.MongoDB ( connect, host, close, access, master, Action (..), Value, (=:), insertMany, auth, authMongoCR, authSCRAMSHA1, Pipe, Host )
import qualified  Database.MongoDB.Query as Q
import Control.Monad.Cont
import Control.Monad.RWS ()
import Data.User
import qualified Data.Bson as B
import qualified Data.Pool as P

createConnPool :: IO (P.Pool Pipe)
createConnPool = P.createPool  (connect (host "127.0.0.1")) close 10 180 3

runQuery :: Action IO a ->  Pipe -> IO a
runQuery a p = Q.access p Q.master "user" a