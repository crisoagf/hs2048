{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Touch where

import Control.Monad
import Data.Aeson.Types
import qualified Data.Map as M
import Debug.Trace
import Miso
import Miso.String (MisoString)

data Touch = Touch
  { identifier :: Int
  , screen :: (Int, Int)
  , client :: (Int, Int)
  , page :: (Int, Int)
  } deriving (Eq, Show)

instance FromJSON Touch where
  parseJSON =
    withObject "touch" $ \o -> do
      identifier <- o .: "identifier"
      screen <- (,) <$> o .: "screenX" <*> o .: "screenY"
      client <- (,) <$> o .: "clientX" <*> o .: "clientY"
      page <- (,) <$> o .: "pageX" <*> o .: "pageY"
      return Touch {..}

data TouchEvent =
  TouchEvent Touch
  deriving (Eq, Show)

instance FromJSON TouchEvent where
  parseJSON obj = do
    x <- parseJSON obj
    return $ TouchEvent x

touchDecoder :: Decoder TouchEvent
touchDecoder = Decoder {..}
  where
    decodeAt = ["changedTouches", "0"]
    decoder = parseJSON

onTouchMove :: (TouchEvent -> action) -> Attribute action
onTouchMove = on "touchmove" touchDecoder

onTouchStart :: (TouchEvent -> action) -> Attribute action
onTouchStart = on "touchstart" touchDecoder

onTouchEnd :: (TouchEvent -> action) -> Attribute action
onTouchEnd = on "touchend" touchDecoder

touchEvents :: M.Map MisoString Bool
touchEvents =
  M.fromList [("touchmove", False), ("touchstart", False), ("touchend", False)]
