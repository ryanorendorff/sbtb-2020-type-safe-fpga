{-# LANGUAGE GADTs #-}

module NetworkTypes (
  Matrix,
  Weights(..),
  Network(..)
) where

import Clash.Prelude

type Matrix m n a = Vec m (Vec n a)

data Weights (m :: Nat) (n :: Nat) a =
  Weights { biases :: Vec n a
          , mapping :: Matrix n m a
          , activation :: a -> a
          }

data Network (i :: Nat) (hs :: [Nat]) (o :: Nat) a where
    OutputLayer :: (Weights i o a) -> Network i '[] o a
    (:>>) :: (KnownNat i, KnownNat o, KnownNat h)
          => (Weights i h a)
          -> (Network h hs o a)
          -> Network i (h ': hs) o a

infixr 5 :>>