//! Implementation of FPGA Session API (here for memory-mapped file API).

use crate::traits::{Data, ReadOnlyResource, ReadWriteResource, Session};
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
    fn read<D, R>(&self, reg: &R) -> FpgaApiResult<D>
    where
        D: Data,
        R: ReadOnlyResource<Value = D>,
    {
        let start = reg.byte_offset();
        let stop = start + reg.size_in_bytes();
        let slc = &self.mmap[start..stop];
        D::from_le_bytes(slc)
    }
    fn readw<D, R>(&self, reg: &R) -> FpgaApiResult<D>
    where
        D: Data,
        R: ReadWriteResource<Value = D>,
    {
        let start = reg.byte_offset();
        let stop = start + reg.size_in_bytes();
        let slc = &self.mmap[start..stop];
        D::from_le_bytes(slc)
    }
    fn write<D, R>(&mut self, reg: &R, val: D) -> FpgaApiResult<()>
    where
        D: Data,
        R: ReadWriteResource<Value = D>,
    {
        let start = reg.byte_offset();
        let stop = start + reg.size_in_bytes();
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
