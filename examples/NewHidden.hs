{-# LANGUAGE RankNTypes #-}

module Adder where

import Clash.Class.HasDomain (WithSpecificDomain)
import Clash.Prelude
import Clash.Intel.ClockGen
import Clash.Annotations.SynthesisAttributes

createDomain vSystem{vName="Input", vPeriod=20000}

type HiddenAddress dom = Hidden "address" (Address dom)
type HiddenClockResetAddress dom = (HiddenClock dom, HiddenReset dom, HiddenAddress dom)

data Address (dom :: Domain) = Address (Signal dom (Unsigned 32))

exposeAddress :: forall dom r. WithSpecificDomain dom r => (HiddenAddress dom => r) -> (KnownDomain dom => Address dom -> r)
exposeAddress = \f addr -> expose @"address" f addr
{-# INLINE exposeAddress #-} 

adder :: (Num a, Ord a) => (a, a) -> a
adder (x, y) = x + (reLU y)

myAdder ::
  (HiddenClockResetAddress dom, Num a, Ord a) =>
  Signal dom (a, a) ->
  Signal dom a
myAdder vals = adder <$> (vals)

{-# ANN topEntity
  (Synthesize
    { t_name   = "new_hidden_signal"
    , t_inputs = [ PortName "clk"
                 , PortName "reset"
                 , PortName "address"
                 , PortName "xy"
                 ]
    , t_output = PortName "result"
    }) #-}
topEntity ::
  Clock Input `Annotate` 'StringAttr "chip_pin" "V11" `Annotate` 'StringAttr "altera_attribute" "-name IO_STANDARD \"3.3-V LVTTL\"" ->
  Reset Input ->
  Address Input -> 
  Signal Input (SFixed 8 8, SFixed 8 8) ->
  Signal Input (SFixed 8 8)
topEntity clk reset address = exposeAddress (exposeReset (exposeClock myAdder clk) reset) address
{-# NOINLINE topEntity #-}
