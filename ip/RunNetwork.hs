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
layer1 :: (Fractional a) => Weights 2 3 a
layer1 = Weights (-0.00567927 :> 0.80877954 :> 0.95279896 :> Nil)
  (transpose (
  (0.95994620 :> 0.7030965 :> 0.75115263 :> Nil) :>
  (0.96010226 :> 0.6862250 :> 0.77583410 :> Nil) :>
  Nil))

layer2 :: (Fractional a) => Weights  3 3 a
layer2 = Weights (0.6884502 :> 0.9990541 :> -0.68232316 :> Nil)
  (transpose (
  (-0.15383774 :>  0.62124210 :> 1.1827494 :> Nil) :>
  ( 1.31086090 :> -0.15906326 :> 0.4299545 :> Nil) :>
  ( 1.56196120 :>  0.20728876 :> 0.3584617 :> Nil) :>
  Nil))

layer3 :: (Fractional a) => Weights  3 2 a
layer3 = Weights (0.428222 :> 0.59423786 :> Nil)
  (transpose (
  (-0.30720720 :> -0.26148600 :> Nil) :>
  ( 0.49485013 :>  0.20622185 :> Nil) :>
  ( 0.70307830 :> -0.27332035 :> Nil) :>
  Nil))

outputLayer :: (Fractional a) => Weights 2 1 a
outputLayer = Weights (-0.99977857 :> Nil)
  (transpose (
  (1.1125442 :> Nil) :>
  (1.9488618 :> Nil) :>
  Nil))

exNetwork :: (Fractional a) => Network 2 '[3, 3, 2] 1 a
exNetwork = layer1 :&~ layer2 :&~ layer3 :&~ O outputLayer 

------------------------------------------------------------------------
--                          Running a network                         --
------------------------------------------------------------------------

runLayer :: (KnownNat i, KnownNat o, Num a)
         => (Weights i o a)
         -> Vec i a
         -> Vec o a
runLayer (Weights biases nodes activation) v = map activation $ biases <+> nodes #> v

-- Assumes that the last layer is a pure output layer with no activation
-- function.
runNet :: (KnownNat i, KnownNat o, Num a, Ord a)
       => Network i hs o a
       -> Vec i a
       -> Vec o a
runNet (O w) v = runLayer w v
runNet (w :&~ n) v = runNet n (runLayer w v)


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
topEntity :: Vec 2 (SFixed 7 25) -> Vec 1 (SFixed 7 25)
topEntity = runNet exNetwork
{-# NOINLINE topEntity #-}