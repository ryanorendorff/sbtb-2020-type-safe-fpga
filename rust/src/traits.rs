//! Traits and typestates to represent an FPGA session and resources.

use crate::FpgaApiResult;

/// Trait for FPGA data types.
pub trait Data: Sized {
    /// From little-endian byte slice.
    fn from_le_bytes(bytes: &[u8]) -> FpgaApiResult<Self>;
    /// From big-endian byte slice.
    fn from_be_bytes(bytes: &[u8]) -> FpgaApiResult<Self>;
    /// To little-endian byte `Vec`.
    fn to_le_bytes(self) -> Vec<u8>;
    /// To big-endian byte `Vec`.
    fn to_be_bytes(self) -> Vec<u8>;
}

/// A readable FPGA resource.
pub trait Readable {
    /// Data value type of the resource.
    type Value: Data;
    /// Memory offset.
    fn byte_offset(&self) -> usize;
    /// Size in bytes of data type.
    fn size_in_bytes(&self) -> usize {
        std::mem::size_of::<Self::Value>()
    }
}
/// A writeable FPGA resource.
pub trait Writable {
    /// Data value type of the resource.
    type Value: Data;
    /// Memory offset.
    fn byte_offset(&self) -> usize;
    /// Size in bytes of data type.
    fn size_in_bytes(&self) -> usize {
        std::mem::size_of::<Self::Value>()
    }
}

/// Trait to wrap FPGA hardware with "session" API.
pub trait Session: Drop {
    /// Read a readable resource.
    fn read<R: Readable>(&self, resource: &R) -> FpgaApiResult<R::Value>;
    /// Write to a writable resource.
    fn write<R: Writable>(&mut self, resource: &R, val: R::Value) -> FpgaApiResult<()>;
}

/// Trait to implement typestates for separating read/write entities.
pub trait IOState {}
/// Typestate for read-only entity (runtime uninhabitable).
pub enum ReadOnly {}
impl IOState for ReadOnly {}
/// Typestate for a read/write entity (runtime uninhabitable).
pub enum ReadWrite {}
impl IOState for ReadWrite {}
