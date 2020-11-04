module DotProduct where

import Clash.Prelude

import ReLU
import NetworkTypes

------------------------------------------------------------------------
--                      Linear algebra primitives                     --
------------------------------------------------------------------------

dotProduct :: (KnownNat n, Num a) => Vec (n + 1) a -> Vec (n + 1) a -> a
dotProduct xs ys = fold (+) (zipWith (*) xs ys)

{-# ANN topEntity
  (Synthesize
    { t_name   = "dotProduct"
    , t_inputs = [ PortName "xs",
                   PortName "ys"
                 ]
    , t_output = PortName "out"
    }) #-}
topEntity ::
  Vec 4 (Unsigned 4) ->
  Vec 4 (Unsigned 4) ->
  (Unsigned 4)
topEntity = dotProduct
{-# NOINLINE topEntity #-}
