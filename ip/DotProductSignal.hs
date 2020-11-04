{-# LANGUAGE ScopedTypeVariables #-}
module DotProductSignal where

import Clash.Prelude

import ReLU
import NetworkTypes

------------------------------------------------------------------------
--                      Linear algebra primitives                     --
------------------------------------------------------------------------

dotProduct :: (KnownDomain dom, KnownNat n, Num a, NFDataX a)
  => Signal dom (Vec (n + 1) a)
  -> Signal dom (Vec (n + 1) a)
  -> Signal dom a
dotProduct xs ys = fold (+) $ unbundle $ (zipWith (*) <$> xs <*> ys)

{-# ANN topEntity
  (Synthesize
    { t_name   = "dotProductSignal"
    , t_inputs = [ PortName "clk",
                   PortName "reset",
                   PortName "enable",
                   PortName "xs",
                   PortName "ys"
                 ]
    , t_output = PortName "out"
    }) #-}
topEntity ::
  Clock System ->
  Reset System ->
  Enable System ->
  Signal System (Vec 4 (Unsigned 4)) ->
  Signal System (Vec 4 (Unsigned 4)) ->
  Signal System (Unsigned 4)
topEntity = exposeClockResetEnable dotProduct
{-# NOINLINE topEntity #-}
