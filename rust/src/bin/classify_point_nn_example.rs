//! Interact with FPGA quadrant classifier.

use sbtb::resources::Resource;
use sbtb::traits::{ReadOnly, ReadWrite, Session};
use sbtb::{
    take_fpga_session, FpgaApiResult, POINT_NN_INPUT_VECTOR_OFFSET, POINT_NN_OUTPUT_CLASS_OFFSET,
};

use fixed::types::I7F25;

fn run() -> FpgaApiResult<()> {
    // Get the FPGA singleton. Better not try and do this more than once!
    let mut sesh = take_fpga_session();

    // Define the resources.
    let input_point =
        Resource::<(I7F25, I7F25), ReadWrite>::new("Input Points", POINT_NN_INPUT_VECTOR_OFFSET);
    let output_class = Resource::<I7F25, ReadOnly>::new(
        "Output Classification Register",
        POINT_NN_OUTPUT_CLASS_OFFSET,
    );

    // Locations (Fixed point 7/25 values).
    let (pos_x, neg_x) = (I7F25::from_num(1.5), I7F25::from_num(-1.5));
    let (pos_y, neg_y) = (I7F25::from_num(2.5), I7F25::from_num(-2.5));

    // Do some FPGA stuff!
    // Quadrant 1.
    println!("\nQuadrant 1");
    println!("==========\n");
    println!("Writing ({}, {}) to {}", pos_x, pos_y, &input_point);
    sesh.write(&input_point, (pos_x, pos_y))?;
    println!("Reading result from {}", &output_class);
    let q1_actual = sesh.read(&output_class)?;
    let q1_expected = I7F25::from_num(1.0);
    println!("\nActual output:   {}", q1_actual,);
    println!("Expected output: {}", q1_expected,);

    // Quadrant 2.
    println!("\nQuadrant 2");
    println!("==========\n");
    println!("Writing ({}, {}) to {}", neg_x, pos_y, &input_point);
    sesh.write(&input_point, (neg_x, pos_y))?;
    println!("Reading result from {}", &output_class);
    let q2_actual = sesh.read(&output_class)?;
    let q2_expected = I7F25::from_num(-1.0);
    println!("\nActual output:   {}", q2_actual,);
    println!("Expected output: {}", q2_expected,);

    // Quadrant 3.
    println!("\nQuadrant 3");
    println!("==========\n");
    println!("Writing ({}, {}) to {}", neg_x, neg_y, &input_point);
    sesh.write(&input_point, (neg_x, neg_y))?;
    println!("Reading result from {}", &output_class);
    let q3_actual = sesh.read(&output_class)?;
    let q3_expected = q1_expected;
    println!("\nActual output:   {}", q3_actual,);
    println!("Expected output: {}", q3_expected,);

    // Quadrant 4.
    println!("\nQuadrant 4");
    println!("==========\n");
    println!("Writing ({}, {}) to {}", pos_x, neg_y, &input_point);
    sesh.write(&input_point, (pos_x, neg_y))?;
    println!("Reading result from {}", &output_class);
    let q4_actual = sesh.read(&output_class)?;
    let q4_expected = q2_expected;
    println!("\nActual output:   {}", q4_actual,);
    println!("Expected output: {}", q4_expected,);

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
