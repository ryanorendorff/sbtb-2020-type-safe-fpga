module DotProductSignal where

import Clash.Prelude

import ReLU
import NetworkTypes

------------------------------------------------------------------------
--                      Linear algebra primitives                     --
------------------------------------------------------------------------

z :: (HiddenClockResetEnable dom) => Signal dom (Vec n a) -> Signal dom (Vec n a) -> Signal dom (Vec n (a, a))
z xs ys = (zip <$> xs <*> ys)
{-# INLINE z #-}

dotProduct :: (HiddenClockResetEnable dom, KnownNat n, Num a)
  => Signal dom (Vec n a) -> Signal dom (Vec n a) -> Signal dom a
dotProduct xs ys = (foldl (\acc (a, b) -> acc + a * b) 0) <$> (z xs ys)

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
  Signal System (Vec 2 (SFixed 8 8)) ->
  Signal System (Vec 2 (SFixed 8 8)) ->
  Signal System (SFixed 8 8)
topEntity = exposeClockResetEnable dotProduct
{-# NOINLINE topEntity #-}
