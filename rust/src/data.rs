//! Define FPGA data types and primitives.

use fixed::types::I7F25;

use crate::traits::Data;
use crate::{FpgaApiError, FpgaApiResult};

impl Data for u8 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(b[0])
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(b[0])
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for u16 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(u16::from_le_bytes([b[0], b[1]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(u16::from_be_bytes([b[0], b[1]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for u32 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(u32::from_le_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(u32::from_be_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for u64 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(u64::from_le_bytes([
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
            ]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(u64::from_be_bytes([
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
            ]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for i8 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i8::from_le_bytes([b[0]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i8::from_be_bytes([b[0]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for i16 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i16::from_le_bytes([b[0], b[1]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i16::from_be_bytes([b[0], b[1]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for i32 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i32::from_le_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i32::from_be_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for i64 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i64::from_le_bytes([
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
            ]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(i64::from_be_bytes([
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
            ]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for f32 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(f32::from_le_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(f32::from_be_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for f64 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(f64::from_le_bytes([
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
            ]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(f64::from_be_bytes([
                b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7],
            ]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for I7F25 {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(I7F25::from_le_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            Ok(I7F25::from_be_bytes([b[0], b[1], b[2], b[3]]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        Vec::from(self.to_le_bytes())
    }
    fn to_be_bytes(self) -> Vec<u8> {
        Vec::from(self.to_be_bytes())
    }
}
impl Data for (I7F25, I7F25) {
    fn from_le_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        let zero = I7F25::from_num(0);
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            let mut byte_arr = [0; 8];
            for (&b, v) in b.iter().zip(byte_arr.iter_mut()) {
                *v = b;
            }
            let mut data_arr = [zero; 2];
            for (b, v) in byte_arr
                .chunks_exact(4)
                .map(|ch| I7F25::from_le_bytes([ch[0], ch[1], ch[2], ch[3]]))
                .zip(data_arr.iter_mut())
            {
                *v = b;
            }
            Ok((data_arr[0], data_arr[1]))
        }
    }
    fn from_be_bytes(b: &[u8]) -> FpgaApiResult<Self> {
        let zero = I7F25::from_num(0);
        if b.len() != std::mem::size_of::<Self>() {
            Err(FpgaApiError::from("Wrong number of bytes!"))
        } else {
            let mut byte_arr = [0; 8];
            for (&b, v) in b.iter().zip(byte_arr.iter_mut()) {
                *v = b;
            }
            let mut data_arr = [zero; 2];
            for (b, v) in byte_arr
                .chunks_exact(4)
                .map(|ch| I7F25::from_be_bytes([ch[0], ch[1], ch[2], ch[3]]))
                .zip(data_arr.iter_mut())
            {
                *v = b;
            }
            Ok((data_arr[0], data_arr[1]))
        }
    }
    fn to_le_bytes(self) -> Vec<u8> {
        let (v1, v2) = self;
        let mut vec = Vec::with_capacity(8);
        vec.extend_from_slice(&v1.to_le_bytes());
        vec.extend_from_slice(&v2.to_le_bytes());
        vec
    }
    fn to_be_bytes(self) -> Vec<u8> {
        let (v1, v2) = self;
        let mut vec = Vec::with_capacity(8);
        vec.extend_from_slice(&v1.to_be_bytes());
        vec.extend_from_slice(&v2.to_be_bytes());
        vec
    }
}
