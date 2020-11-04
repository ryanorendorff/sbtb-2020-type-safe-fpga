module DotProduct where

import Clash.Prelude

import ReLU
import NetworkTypes

------------------------------------------------------------------------
--                      Linear algebra primitives                     --
------------------------------------------------------------------------

infixr 7 <+>
(<+>) :: (KnownNat n, Num a) => Vec n a -> Vec n a -> Vec n a
(<+>) = zipWith (+)

dotProduct :: (KnownNat n, Num a) => Vec n a -> Vec n a -> a
dotProduct xs ys = foldr (+) 0 (zipWith (*) xs ys)

{-# ANN topEntity
  (Synthesize
    { t_name   = "dotProduct"
    , t_inputs = [ PortName "xs",
                   PortName "ys"
                 ]
    , t_output = PortName "out"
    }) #-}
topEntity ::
  Vec 4 (SFixed 8 8) ->
  Vec 4 (SFixed 8 8) ->
  SFixed 8 8
topEntity = dotProduct
{-# NOINLINE topEntity #-}
