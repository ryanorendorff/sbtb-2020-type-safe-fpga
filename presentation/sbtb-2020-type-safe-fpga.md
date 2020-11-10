---
title: Programming ML algorithms in hardware, sanely 
subtitle: using Haskell and Rust! 
author: |
  Daniel Hensley and Ryan Orendorff (https://git.io/JkTzb)
date: November 13th, 2020
theme: metropolis
header-includes: |
  \definecolor{BerkeleyBlue}{RGB}{0,50,98}
  \definecolor{FoundersRock}{RGB}{59,126,161}
  \definecolor{Medalist}{RGB}{196,130,14}

  \setbeamercolor{frametitle}{fg=white,bg=FoundersRock}
  \setbeamercolor{title separator}{fg=Medalist,bg=white}

  \usepackage{fontspec}
  \setmonofont{Iosevka}
  \usefonttheme[onlymath]{serif}

  \newcommand{\undovspacepause}{\vspace*{-0.9em}}
---


Outline
-------

<!--
TODO: Figure out how to add newline with the presentation URL in the author
      section.
-->

In this talk, we will go through

- Basics of how to implement a neural network using Clash.
- How to make accessing the FPGA safe using Rust.


Architecture
------------

We will be implementing a dense neural network on an Intel Cyclone V chip, which
has both an ARM processor and FPGA on one chip (SoC).

![](./fig/chip.pdf)


How is a neural network implemented?
------------------------------------

A neural network is usually shown as a series of nodes with connections between
them. But what does that mean?

<!--
TODO: Make our own figure so that we are not copying anyone without permission.
-->

![](./fig/nn.png)


Neural network basics: how to go from one layer to another
----------------------------------------------------------

Going from one layer ($x$) to the next ($y$) is implemented using the equation
$y = g(Mx + b)$.

![](./fig/network-x.pdf)

Neural network basics: how to go from one layer to another
----------------------------------------------------------

Going from one layer ($x$) to the next ($y$) is implemented using the equation
$y = g(Mx + b)$.

![](./fig/network-M.pdf)

Neural network basics: how to go from one layer to another
----------------------------------------------------------

Going from one layer ($x$) to the next ($y$) is implemented using the equation
$y = g(Mx + b)$.

![](./fig/network-b.pdf)

Neural network basics: how to go from one layer to another
----------------------------------------------------------

Going from one layer ($x$) to the next ($y$) is implemented using the equation
$y = g(Mx + b)$.

![](./fig/network-gy.pdf)

Neural network basics: how to go from one layer to another
----------------------------------------------------------

Going from one layer ($x$) to the next ($y$) is implemented using the equation
$y = g(Mx + b)$.

![](./fig/network-all.pdf)


Let's implement the linear algebra basics
-----------------------------------------

For the equation $y = g(Mx + b)$, we need to be able to add two vectors
together and perform matrix-vector multiply.

. . .

```haskell
-- Add two vectors: x + y
(<+>) :: (KnownNat n, Num a)
      => Vec n a -> Vec n a -> Vec n a
(<+>) = zipWith (+)
```

Let's implement the linear algebra basics
-----------------------------------------

For the equation $y = g(Mx + b)$, we need to be able to add two vectors
together and perform matrix-vector multiply.

```haskell
-- Dot product: ⟨x, y⟩
(<.>) :: (KnownNat n, Num a)
      => Vec n a -> Vec n a -> a
(<.>) xs ys = foldr1 (+) (zipWith (*) xs ys)

-- Matrix vector multiply: Mx
(#>) :: (KnownNat m, KnownNat n, Num a)
     => Matrix m n a -> Vec n a -> Vec m a
(#>) m v = map (<.> v) m
```

Compiling just the matrix vector multiply
-----------------------------------------

If we compile just the dot product:

```haskell
(<.>) xs ys = foldr (+) 0 (zipWith (*) xs ys)
```

We can see what Clash will generate for a simple case (4 element vector).

![](./fig/dotproduct-foldr1.pdf)


With the basics down, let's define the neural network type
----------------------------------------------------------

Now that we have the basic linear algebra operators down, lets store everything
we need for the $y = g(Mx + b)$.

```haskell
-- Transition of size m to size n
data LayerTransition (m :: Nat) (n :: Nat) a =
  LayerTransition
          { b :: Vec n a      -- Bias b
          , m :: Matrix n m a -- Connections M
          , g :: a -> a       -- Activation function g
          }
```

We can compose layers using a dependently typed list
----------------------------------------------------

Now we will create a list of layers by making a list of `LayerTransition`s.

```haskell
data Network (i :: Nat) (hs :: [Nat]) (o :: Nat) a where
    OutputLayer :: (LayerTransition i o a) -> Network i '[] o a
```

. . .

```haskell
    (:>>) :: (KnownNat i, KnownNat o, KnownNat h)
          => (LayerTransition i h a)
          -> (Network h hs o a)
          -> Network i (h ': hs) o a
```

Running a `LayerTransition`
---------------------------

We can now run a layer transition by applying our equation $y = g(Mx + b)$ to
some input vector $x$ to output vector $y$.

```haskell
runLayer :: (KnownNat i, KnownNat o, Num a)
         => (LayerTransition i o a)
         -> Vec i a
         -> Vec o a
runLayer (LayerTransition b m g) x =
  map g $ m #> x <+> b
-- Precisely y = g(Mx + b) from before!
```

Clash Run Network
-----------------

Now we can run our network by moving data from one layer to the nxt

```haskell
runNet :: (KnownNat i, KnownNat o, Num a, Ord a)
       => Network i hs o a -- ^ Dense neural network
       -> Vec i a -- ^ Input vector
       -> Vec o a -- ^ Result vector
runNet (OutputLayer l) v = runLayer l v
runNet (l :>> n) v = runNet n (runLayer l v)
```


Composing Layers
----------------

Let's suppose we have the following four layer neural network.

```haskell
layer1 :: (Fractional a, Ord a) => Weights 2 3 a
layer2 :: (Fractional a, Ord a) => Weights 3 3 a
layer3 :: (Fractional a, Ord a) => Weights 3 2 a
layer4 :: (Fractional a, Ord a) => Weights 2 1 a
```

. . .

Now combine them using our `Network` type.

```haskell
network :: (Fractional a, Ord a)
        => Network 2 '[3, 3, 2] 1 a
network = layer1 :>> layer2 :>> layer3 :>> OutputLayer layer4
```

The type level numbers force us to make a network where the sizes of the output
of one layer match the input to the next!


Clash Synthesize
----------------

We can now synthesize what we have into something the FPGA can understand using
`clash File.hs --verilog`.

```haskell
topEntity :: Vec 2 (SFixed 7 25) -> Vec 1 (SFixed 7 25)
topEntity = map classify . runNet exNetwork . map classify
```

. . .

Note that

::: incremental

- We had to specify the specific number type we were using. Clash must know this
  to layout the hardware correctly.
- We don't have access to floating point numbers, so we use fixed point numbers
  instead.
:::

Meeting timing constraints
--------------------------

Experienced FPGA developers will notice that networks above a certain size
cannot be synthesized.

. . .

```haskell
fold (+) (zipWith (*) xs ys)
```

![](./fig/dotproduct-no-register.pdf)


Meeting timing constraints
--------------------------

But we can add a register between the zip and the fold to reduce the critical
path.

```haskell
fold (+) $ unbundle $ register (repeat 0) $ zipWith (*) <$> xs <*> *ys)
```

![](./fig/dotproduct-register.pdf)



Other benefits to Clash
-----------------------

Blah blah

- Simple to test the base functions (just Haskell! Can use quickcheck)
- State machines are modeled in a convenient form using Mealy machines. Enabled
  pipelining.
- 


Rust program to interact with the FPGA
======================================

Example slide
-------------

Example Rust code.

```rust
fn hello() {
  println!("Hello World!");
}
```

Conclusion
----------

We are awesome.


Questions?
----------

Insert cute animal here
