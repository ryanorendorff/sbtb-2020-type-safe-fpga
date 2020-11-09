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

layer1 :: (Fractional a, Ord a) => Weights 2 3 a
layer1 = Weights
  (0.59075195 :> 0.7959526 :> 0.38218504 :> Nil)
  ((-0.7289600 :>  1.26979710 :> Nil) :>
   ( 1.1520898 :> -0.32037434 :> Nil) :>
   ( 0.9137672 :>  1.06754260 :> Nil) :> Nil)
  reLU

layer2 :: (Fractional a, Ord a) => Weights 3 3 a
layer2 = Weights
  (0.028665015 :> 0.3068945 :> -0.09725595 :> Nil)
  ((-0.67000060 :>  0.87169980 :> -0.34371296 :> Nil) :>
   ( 0.95989394 :> -0.18818283 :> -0.39938320 :> Nil) :>
   ( 1.03449580 :> -0.14215301 :> -0.29492024 :> Nil) :> Nil)
  reLU

layer3 :: (Fractional a, Ord a) => Weights 3 2 a
layer3 = Weights
  (0.4435449 :> -0.09169075 :> Nil)
  ((-0.23531327 :> 0.21636824 :> -0.24308626 :> Nil) :>
   ( 1.82368970 :> 0.99214333 :>  0.63132364 :> Nil) :> Nil)
  reLU

layer4 :: (Fractional a, Ord a) => Weights 2 1 a
layer4 = Weights
  (0.77317786 :> Nil)
  ((0.70241016 :> -0.5099548 :> Nil) :> Nil)
  id

exNetwork :: (Fractional a, Ord a) => Network 2 '[3, 3, 2] 1 a
exNetwork = layer1 :&~ layer2 :&~ layer3 :&~ O layer4


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


classify :: (Fractional a, Ord a) => a -> a
classify x = if x > 0 then 1 else -1

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
topEntity = map classify . runNet exNetwork . map classify
{-# NOINLINE topEntity #-}