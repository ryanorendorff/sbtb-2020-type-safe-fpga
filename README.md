# Programming Machine Learning Algorithms in Hardware, Sanely, using Haskell and Rust!

![Presentation PDF](https://github.com/ryanorendorff/sbtb-2020-type-safe-fpga/workflows/Presentation%20PDF/badge.svg)
[![Download PDF](https://img.shields.io/badge/-Download%20PDF-blue)](https://github.com/ryanorendorff/sbtb-2020-type-safe-fpga/raw/gh-pages/SBTB-2020-Type-Safe-FPGA.pdf)

Using Dependent and Affine Types for robust FPGA programming.

Presented at [Scale by the Bay 2020 (SBTB
2020)](https://scalebythebay2020.sched.com/event/e55t/programming-machine-learning-algorithms-in-hardware-sanely-using-haskell-and-rust).


## Abstract

We’re all used to programming software. But what about programming
reconfigurable hardware? That’s exactly what we can do with Field Programmable
Gate Arrays (FPGAs). Programming hardware opens up a whole new dimension to
optimizing performance and resource utilization. However, programming FPGAs is
challenging and requires esoteric tooling.

We can do better! In this talk, we will show how we can use the Clash language
to safely program FPGAs and Rust to correctly use them in a machine learning
application.

Our first step is converting a functional machine learning program into
computer hardware. How do we do that? We use Clash! Clash is a Haskell like
language that allows programmers to define hardware structurally. It does this
by compiling functional programs into logic gates that are then turned into
circuits on the FPGA. Clash includes a dependent type system, which allows
Clash to guarantee that the circuits are wired up correctly on the FPGA,
leading to fewer errors.  We will demonstrate how a simple machine learning
algorithm can be sped up by the hardware parallelism afforded to FPGAs, and
highlight how Clash’s type system provides compile time guarantees that the
hardware circuits are implemented correctly.

OK, so we’ve got our FPGA hardware wired up correctly using Clash, but how do
we make sure we use it correctly? What if we’re using it to run powerful and
dangerous magnets in an imaging scanner? Well, we better do it right. We’ll
talk about how we can use Rust to build a safe session interface over our
hardware machine learning algorithm that provides important compile-time
guarantees on how the hardware is accessed in software. Rust’s borrow checker
ensures that we cannot access resources such as FIFO buffers outside of the
scope of the hardware they refer to; additionally we also cannot forget to
perform important hardware clean up when these resources go out of scope. This
application will demonstrate how Rust’s unique type system enables both an
ergonomic and compile time-validated interface to the Clash validated FPGA
hardware.


## File layout

This repo is broken out into the following directories:

- `examples/`: Examples of specific type-level Clash features.
- `ip/`: Basic Clash blocks. For example, this contains the dot product, the
  neural network, and a few other blocks.
- `nixos/`: A description of how to get a nixos VM started with Quartus installed.
- `presentation/`: Presentation code. Can be compiled with `nix-build presentation`.
- `quartus-project/`: Instructions for how to copy the results of the Clash
  `ip` folder onto the DE10 nano, as well as a quickstart Quartus project.
- `rust/`: Type safe access to the FPGA.

## Tutorials for using Quartus

Tutorials for using Quartus can be found at the following URL:

https://github.com/intel-iot-devkit/terasic-de10-nano-kit/

All three tutorials mentioned are great reading for getting started with
programming the FPGA and interfacing with it through Linux.

Additionally, there is a [tutorial for embedded
linux](https://bitlog.it/20170820_building_embedded_linux_for_the_terasic_de10-nano.html)
applications. It describes how to build a simple LED component from the Golden
Hardware Reference Design (GHRD) and build a Linux kernel around it.


<!-- References -->
[quartus]: https://fpgasoftware.intel.com/?edition=lite
[vmware-fusion]: https://www.vmware.com/products/fusion/fusion-evaluation.html
