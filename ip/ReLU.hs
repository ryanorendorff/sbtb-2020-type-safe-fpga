{-# LANGUAGE RankNTypes #-}

module ReLU where

import Clash.Class.HasDomain (WithSpecificDomain)
import Clash.Prelude
import Clash.Intel.ClockGen
import Clash.Annotations.SynthesisAttributes

reLU :: (Num a, Ord a) => a -> a
reLU = max 0
{-# INLINE reLU #-}


-- I guess we don't really need a toplevel entity but whatever
{-# ANN topEntity
  (Synthesize
    { t_name   = "reLU"
    , t_inputs = [ PortName "clk"
                 , PortName "reset"
                 , PortName "enable"
                 , PortName "val"
                 ]
    , t_output = PortName "result"
    }) #-}
topEntity ::
  Clock System ->
  Reset System ->
  Enable System ->
  Signal System (SFixed 8 8) ->
  Signal System (SFixed 8 8)
topEntity = exposeClockResetEnable (reLU <$>)
{-# NOINLINE topEntity #-}
