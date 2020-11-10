//! FPGA interaction library for 2020 Scale by the Bay talk.

use std::fs::OpenOptions;
use std::path::Path;
use std::sync::Mutex;

use lazy_static::lazy_static;
use memmap::MmapOptions;

pub type FpgaApiError = Box<dyn std::error::Error>;
pub type FpgaApiResult<T> = std::result::Result<T, FpgaApiError>;

pub mod data;
pub mod resources;
pub mod session;
pub mod traits;

use session::MmapSesh;

struct Fpga(Option<MmapSesh>);
impl Fpga {
    fn take(&mut self) -> MmapSesh {
        let sesh = self.0.take();
        sesh.expect("It is forbidden to create more than one FPGA session!")
    }
}

const POINT_NN_BASE: u64 = 0xC002_0000;
const POINT_NN_SPAN: usize = 64;
const POINT_NN_END: u64 = POINT_NN_BASE + POINT_NN_SPAN as u64 - 1;

pub const POINT_NN_INPUT_VECTOR_OFFSET: usize = 0;
pub const POINT_NN_OUTPUT_CLASS_OFFSET: usize = 8;

lazy_static! {
    /// Global FPGA handle to be accessed through singleton pattern.
    static ref POINT_NN_FPGA: Mutex<Fpga> = {
        let path = Path::new("/dev/mem");
        let file = match OpenOptions::new()
            .read(true)
            .write(true)
            .create(false)
            .open(&path)
        {
            Ok(f) => f,
            Err(e) => panic!(
                "ERROR trying to open memory-mapped file: {:?}: {}",
                &path, e
            ),
        };
        let fpga_map = match unsafe { MmapOptions::new().offset(POINT_NN_BASE).len(POINT_NN_SPAN).map_mut(&file) } {
            Ok(map) => map,
            Err(e) => panic!("ERROR trying to initialize memory-mapped file: {}", e),
        };
        let session = match MmapSesh::new(fpga_map) {
            Ok(s) => s,
            Err(e) => panic!("ERROR trying to initialize FPGA session: {}", e),
        };
        Mutex::new(Fpga(Some(session)))
    };
}
/// Take FPGA session singleton. User must uphold invariant to only call once
/// to avoid a runtime panic.
pub fn take_fpga_session() -> MmapSesh {
    POINT_NN_FPGA.lock().unwrap().take()
}
