{-# LANGUAGE NamedFieldPuns #-}
module Validate where

import Data.User as U
import Data.Api(LoginRequest(..))
import Data.String.Conversions (cs)
import Data.Bool
import Data.Password.Bcrypt
    ( mkPassword,
      PasswordCheck(PasswordCheckFail, PasswordCheckSuccess),
      PasswordHash(PasswordHash),
      checkPassword,
      checkPassword )
import Data.Text
validateLogin :: String -> Maybe U.User -> Bool
validateLogin p Nothing = False
validateLogin p (Just User {U.password}) = do
    let h = PasswordHash $ pack password
    let pass = mkPassword $ pack p
    case checkPassword pass h of
        PasswordCheckSuccess -> True
        PasswordCheckFail  -> False

