//! Interact with FPGA quadrant classifier.

use rand::prelude::*;

use sbtb::resources::Resource;
use sbtb::traits::{ReadOnly, ReadWrite, Session};
use sbtb::{
    take_fpga_session, FpgaApiResult, POINT_NN_INPUT_VECTOR_OFFSET, POINT_NN_OUTPUT_CLASS_OFFSET,
};

use fixed::types::I7F25;

const NUM_POINTS: usize = 100;

fn run() -> FpgaApiResult<()> {
    // Get the FPGA singleton. Better not try and do this more than once!
    let mut sesh = take_fpga_session();

    // Make some data.
    let mut rng = rand::thread_rng();
    let mut point_vec: Vec<(I7F25, I7F25)> = Vec::with_capacity(NUM_POINTS);
    for _ in 0..NUM_POINTS {
        let (x, y): (f32, f32) = (rng.gen_range(-10.0, 10.0), rng.gen_range(-10.0, 10.0));
        let (x_fx, y_fx) = (I7F25::from_num(x), I7F25::from_num(y));
        point_vec.push((x_fx, y_fx));
    }

    // Define the resources.
    let input_point =
        Resource::<(I7F25, I7F25), ReadWrite>::new("Input Points", POINT_NN_INPUT_VECTOR_OFFSET);
    let output_class = Resource::<I7F25, ReadOnly>::new(
        "Output Classification Register",
        POINT_NN_OUTPUT_CLASS_OFFSET,
    );

    // Classify the points using the FPGA and write to CSV.
    let mut wtr = csv::Writer::from_path("fpga_classified_points.csv")?;
    // Write header.
    wtr.write_record(&["x", "y", "class"])?;
    for point in point_vec {
        sesh.write(&input_point, point)?;
        let classification = sesh.read(&output_class)?;
        let (x, y) = point;
        wtr.serialize((
            x.to_num::<f32>(),
            y.to_num::<f32>(),
            classification.to_num::<f32>(),
        ))?;
    }
    Ok(())
}

fn main() {
    std::process::exit(match run() {
        Ok(_) => 0,
        Err(e) => {
            eprintln!("ERROR: {:?}", e);
            1
        }
    });
}
