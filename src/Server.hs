{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
module Server where
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Logger
import Data.Aeson.TH
import Servant
import GHC.Generics
import Data.Aeson (FromJSON, ToJSON, object, (.=), Value (String), Result ())
import Data.Api ( PingApi, Ping(Ping), Status(..), LoginApi, LoginRequest (..), AppM (..), AppCtx (..), Api, RegisterForm, ApiResponse (Response))
import Data.Text
import qualified Data.User as U
import GHC.TypeLits (ErrorMessage(Text))
import System.Log.FastLogger ( ToLogStr(..)
                             , LoggerSet
                             , defaultBufSize
                             , newStdoutLoggerSet
                             , flushLogStr
                             , pushLogStrLn )
import Control.Monad.Reader (Reader, MonadReader (ask), ReaderT, asks, MonadIO (liftIO))
import Control.Monad (liftM)
import Servant.Auth.Server (SetCookie)
import qualified Data.Pool as P
import qualified Db.UserRepository as UserRepo
import Database.MongoDB (Pipe)
import qualified Servant.Auth.Server as SAS
import Db.Connection (runQuery)
import Util
import Validate

api :: Proxy Api
api = Proxy

apiServer ::  SAS.CookieSettings  -> SAS.JWTSettings -> ServerT Api AppM
apiServer cs jwts = loginHandler cs jwts :<|> pingHandler :<|> registerHandler

loginHandler :: SAS.CookieSettings -> SAS.JWTSettings -> LoginRequest -> AppM (Headers '[ Header "Set-Cookie" SetCookie,  Header "Set-Cookie" SetCookie ] Value)
loginHandler cs js (UserRequest account password) = do
    logset <- asks _getLogger
    pool <- asks _getConnPool
    res <- liftIO $ do
         r <- P.withResource pool $ runQuery $ UserRepo.findByUserName account
         let v = validateLogin password r
         return $ if v then r else Nothing
    case res of
        Nothing -> throwError err401
        Just usr -> do
            mApplyCookies <- liftIO $ SAS.acceptLogin cs js $ toUserInfo usr
            case mApplyCookies of
                Nothing -> do
                    liftIO $ Util.log logset Err  "Error happen when set cookie"
                    throwError err401
                Just applyCookies -> do
                    liftIO $ Util.log logset Info "Successful "
                    pure $ applyCookies $ object [ "status" .=  ("success" :: String) ]

pingHandler :: AppM Ping
pingHandler = asks _getLogger >>= (\logset -> liftIO $ Util.log logset Info "recieved ping") >>= (\r-> pure $ Ping "pong")

registerHandler :: RegisterForm -> AppM ApiResponse
registerHandler form = do
    pool <- asks _getConnPool
    liftIO $ P.withResource pool $ runQuery $ UserRepo.insertUser form
    return $ success "you can login with new account"