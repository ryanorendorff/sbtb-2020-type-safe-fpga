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

The Big Picture -- Safe Control of our FPGA Hardware
----------------------------------------------------

![](./fig/high_level_host_and_fpga.pdf)

Key Concepts
------------

We will build software that abstracts over the FPGA from the host's perspective. We will shoot for all of the following using the Rust type system:

- Encode and enforce HW invariants.
- Push as much as possible to compile-time checks.
- Maintain ergonomics!

Key Concepts
------------

In the end, we want something that looks like this:

```rust
// Write our 2D point to the FPGA for the computation.
sesh.write(&input_point, (x, y))?;
// Read back the classification from the net.
let quad_class = sesh.read(&output_class)?;
```

and has compile-time guarantees so we can sleep well at night!

How Do We Get There?
--------------------

We will build a *Session* API using Rust:

![](./fig/type_system_components.pdf)

The Design
----------

The major components of our Session API:

1. Expressing application-specific resources (*e.g.*, registers).
2. The session that wraps the FPGA and all interaction with it.
3. Linking these together in a way that is ergonomic and safe.

ADD FIG

Generically Modeling FPGA Resources with Traits
-----------------------------------------------

Traits are one of the anchors of the Rust type system. They allow you to define
shared behavior and constraints for sets of types.

They are similar to typeclasses in Haskell and interfaces in Java.

Encoding the Data Type/Primitive with a Trait
---------------------------------------------

```rust
/// Trait for FPGA data types.
pub trait Data: Copy + Clone {
    fn from_le_bytes(bytes: &[u8]) -> FpgaApiResult<Self>;
    fn from_be_bytes(bytes: &[u8]) -> FpgaApiResult<Self>;
    fn to_le_bytes(self) -> Vec<u8>;
    fn to_be_bytes(self) -> Vec<u8>;
}
```

If anyone implements `Data` for any `Copy` type in Rust (including custom types),
then they can plug it into our session API.

Controlling Read/Write with a Typestate
---------------------------------------

Typestates are a great way to encode invariants in the type system. There is no
runtime cost and if it compiles, the encoded invariants are guaranteed.

![](./fig/typestate_depictions.pdf)

*Note*: The common `Builder` pattern in Rust is a form of the latter.

Encoding Resource Allowed I/O with Typestates in Rust
-----------------------------------------------------

```Rust
/// Typestate pattern via empty marker trait.
pub trait IOState {}
/// Uninhabitable `enum` for first typestate.
pub enum ReadOnly {}
impl IOState for ReadOnly {}
/// Uninhabitable `enum` for second typestate.
pub enum ReadWrite {}
impl IOState for ReadWrite {}
```

Putting These Together: Expressing Any FPGA Resource
-----------------------------------------------------

```rust
pub struct Resource<D: Data, I: IOState> {
    name: &'static str,
    offset: usize,
    _ty: PhantomData<D>,
    _st: PhantomData<I>,
}
```

For any resource, the only thing reified in memory at runtime is a `name` and
(byte) `offset`. The `D` and `I` typestates determine the available operations
associated with the FPGA (through the `Session`).

What Does This Give Us?
-----------------------

In application code:

1. (In a type sense) we can't send the wrong bytes to the FPGA or interpret incoming bytes incorrectly.
2. We can't mutate a read-only FPGA resource.

```Rust
let sesh = take_fpga_session();
let input_point = Resource::<(u32, u32), ReadWrite>::new(...);
let output_class = Resource::<u32, ReadOnly>::new(...);
// -- snip --
sesh.write(&input_point, (1.3, -2.7))?; // Comp fail (write wrong type).
let v: f32 = sesh.read(&output_class)?; // Comp fail (read wrong type).
sesh.write(&output_class, 1u32)?;       // Comp fail (write read-only).
```

Now, to the `Session` Type
--------------------------

The opaque `Session` type represents the FPGA and our interaction with it.

We will encode the singular nature of the HW and the importance of maintaining appropriate
state with the help of the type system.

Encode `Session` HW Invariant: Singleton
----------------------------------------

We can't let our devs arbitrarily spawn up or duplicate sessions (there's only
1 piece of HW). We use Rust's version of the singleton pattern for this:

```rust
struct Fpga(Option<MmapSesh>);
impl Fpga {
    fn take(&mut self) -> MmapSesh {
        let sesh = self.0.take();
        sesh.expect("Forbidden to create more than one FPGA session!")
    }
}
pub fn take_fpga_session() -> MmapSesh {
    POINT_NN_FPGA.lock().unwrap().take()
}
// -- snip -- in application code
let mut sesh = take_fpga_session();
```

Encode `Session` HW Invariant: Initialization and Finalization
--------------------------------------------------------------

Rust's RAII and affine type system allows us to ensure FPGA/HW state invariants:

- Can only create a `Session` through constructor that performs proper initialization.
- Must implement `Drop` to finalize state of the FPGA (and any associated HW) when we're done.
- You cannot then forget to `Drop` -- in happy or sad code paths!

Encode `Session` HW Invariant: Initialization
---------------------------------------------

```rust
impl MmapSession {
    // The only way to get an instance of our `Session` type.
    pub fn new(mmap: MmapMut) -> FpgaApiResult<Self> {
        let mut sesh = Self { mmap };
        sesh.initialize()?; // HW initialization here.
        Ok(sesh)
    }
}
```

Encode `Session` HW Invariant: Finalization
-------------------------------------------

```rust
pub trait Session: Drop { // Note **must** implement `Drop`.
// -- snip --
impl Drop for MmapSesh {
    fn drop(&mut self) {
        // Enforce critical FPGA/HW invariants for "final" state.
        // -- snip --
    }
}
```

What Does This Give Us?
-----------------------

With `Drop` implemented, we cannot "forget" to cleanup the FPGA and associated resources:

```Rust
fn main() {
    let sesh = take_fpga_session();
    // -- snip -- do stuff with the FPGA.
    risky_function.expect("Uh oh, hit a panic!");
    // -- snip -- more stuff
    println!("Done!");
}
```

Whether we `panic` or not, our session will be `Drop`ped.

Bringing It All Together: The `Session` Trait
---------------------------------------------

```rust
pub trait Session: Drop {
    fn read<D, R>(&self, resource: &R) -> FpgaApiResult<D>
    where
        D: Data,
        R: ReadOnlyResource<Value = D>;
    fn readw<D, R>(&self, resource: &R) -> FpgaApiResult<D>
    where
        D: Data,
        R: ReadWriteResource<Value = D>;
    fn write<D, R>(&mut self, resource: &R, val: D) -> FpgaApiResult<()>
    where
        D: Data,
        R: ReadWriteResource<Value = D>;
}
```

Implementing `Session` for Memory-Mapped FPGA I/O
-------------------------------------------------

```rust
impl Session for MmapSesh {
    fn read<D, R>(&self, resource: &R) -> FpgaApiResult<D>
    where
        D: Data,
        R: ReadOnlyResource<Value = D>,
    {
        let start = resource.byte_offset();
        let stop = start + resource.size_in_bytes();
        let slc = &self.mmap[start..stop];
        D::from_le_bytes(slc)
    }
    // -- snip --
```

Implementing `Session` for Memory-Mapped FPGA I/O
-------------------------------------------------
```rust
    // -- snip --
    fn write<D, R>(&mut self, resource: &R, val: D) -> FpgaApiResult<()>
    where
        D: Data,
        R: ReadWriteResource<Value = D>,
    {
        let start = resource.byte_offset();
        let stop = start + resource.size_in_bytes();
        self.mmap[start..stop].copy_from_slice(
            val.to_le_bytes().as_slice()
        );
        Ok(())
    }
```

Conclusion
----------

We are awesome.


Questions?
----------

Insert cute animal here
