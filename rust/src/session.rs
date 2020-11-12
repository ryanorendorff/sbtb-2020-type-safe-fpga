//! Implementation of FPGA Session API (here for memory-mapped file API).

use crate::traits::{Data, Readable, Session, Writable};
use crate::FpgaApiResult;

use memmap::MmapMut;

/// Session for FPGA I/O through a memory-mapped file.
pub struct MmapSesh {
    mmap: MmapMut,
}
impl MmapSesh {
    pub fn new(mmap: MmapMut) -> FpgaApiResult<Self> {
        let mut sesh = Self { mmap };
        sesh.initialize()?;
        Ok(sesh)
    }
    /// Enforce critical FPGA/HW invariants for "initial" state.
    pub fn initialize(&mut self) -> FpgaApiResult<()> {
        // -- snip --
        Ok(())
    }
}
impl Session for MmapSesh {
    fn read<R: Readable>(&self, resource: &R) -> FpgaApiResult<R::Value> {
        let start = resource.byte_offset();
        let stop = start + resource.size_in_bytes();
        let slc = &self.mmap[start..stop];
        R::Value::from_le_bytes(slc)
    }
    fn write<R: Writable>(&mut self, resource: &R, val: R::Value) -> FpgaApiResult<()> {
        let start = resource.byte_offset();
        let stop = start + resource.size_in_bytes();
        self.mmap[start..stop].copy_from_slice(val.to_le_bytes().as_slice());
        Ok(())
    }
}
impl Drop for MmapSesh {
    fn drop(&mut self) {
        // Enforce critical FPGA/HW invariants for "final" or dropped state.
        // -- snip --
    }
}
