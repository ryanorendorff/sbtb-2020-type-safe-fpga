module RunNetwork where

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

infixr 8 <.>
(<.>) :: (KnownNat n, Num a) => Vec n a -> Vec n a -> a
(<.>) = dotProduct

matrixVector :: (KnownNat m, KnownNat n, Num a) => Matrix m n a -> Vec n a -> Vec m a
matrixVector m v = map (`dotProduct` v) m

infixr 8 #>
(#>) :: (KnownNat m, KnownNat n, Num a) => Matrix m n a -> Vec n a -> Vec m a
(#>) = matrixVector


------------------------------------------------------------------------
--                  Sample network with random values                 --
------------------------------------------------------------------------

-- Sample layers
ih :: Weights 4 3 (SFixed 8 8)
ih = Weights (1 :> 2 :> 3 :> Nil) (row1 :> row2 :> row3 :> Nil)
  where
    row1 = 1 :> 2 :> 3 :> 10 :> Nil
    row2 = 4 :> 5 :> 6 :> 11 :> Nil
    row3 = 7 :> 8 :> 9 :> 12 :> Nil

hh :: Weights  3 3 (SFixed 8 8)
hh = Weights (1 :> 2 :> 3 :> Nil) (row1 :> row2 :> row3 :> Nil)
  where
    row1 = 1 :> 2 :> 3 :> Nil
    row2 = 4 :> 5 :> 6 :> Nil
    row3 = 7 :> 8 :> 9 :> Nil

ho :: Weights  3 2 (SFixed 8 8)
ho = Weights (1 :> 2 :> Nil) (row1 :> row2 :> Nil)
  where
    row1 = 1 :> 2 :> 3 :> Nil
    row2 = 4 :> 5 :> 6 :> Nil
    row3 = 7 :> 8 :> 9 :> Nil

exNetwork = ih :&~ hh :&~ O ho :: Network 4 '[3, 3] 2 (SFixed 8 8)


------------------------------------------------------------------------
--                          Running a network                         --
------------------------------------------------------------------------

runLayer :: (KnownNat i, KnownNat o, Num a) => (Weights i o a) -> Vec i a -> Vec o a
runLayer (Weights biases nodes) v = biases <+> nodes #> v

runNet :: (KnownNat i, KnownNat o, Num a, Ord a)
       => (a -> a)
       -> Network i hs o a
       -> Vec i a
       -> Vec o a
runNet activation (O w) v = map activation (runLayer w v)
runNet activation (w :&~ n) v = runNet activation n (map activation (runLayer w v))


------------------------------------------------------------------------
--                         Generate FPGA Block                        --
------------------------------------------------------------------------

{-# ANN topEntity
  (Synthesize
    { t_name   = "runNetwork"
    , t_inputs = [ PortName "in"
                 ]
    , t_output = PortName "out"
    }) #-}
topEntity :: Vec 4 (SFixed 8 8) -> Vec 2 (SFixed 8 8)
topEntity = runNet reLU exNetwork
{-# NOINLINE topEntity #-}
