//! Implementation of FPGA resources.

use crate::traits::{Data, IOState, ReadOnly, ReadOnlyResource, ReadWrite, ReadWriteResource};

use std::marker::PhantomData;

/// Representation of FPGA resource with associated data type and I/O state as
/// part of the type.
pub struct Resource<D: Data, I: IOState> {
    name: &'static str,
    offset: usize,
    _ty: PhantomData<D>,
    _st: PhantomData<I>,
}
impl<D: Data, I: IOState> Resource<D, I> {
    pub fn new(name: &'static str, offset: usize) -> Self {
        Self {
            name,
            offset,
            _ty: PhantomData,
            _st: PhantomData,
        }
    }
}
impl<D: Data, I: IOState> std::fmt::Display for Resource<D, I> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{} at byte offset {}", self.name, self.offset)
    }
}
impl<D: Data> ReadOnlyResource for Resource<D, ReadOnly> {
    type Value = D;
    fn byte_offset(&self) -> usize {
        self.offset
    }
}
impl<D: Data> ReadWriteResource for Resource<D, ReadWrite> {
    type Value = D;
    fn byte_offset(&self) -> usize {
        self.offset
    }
}
