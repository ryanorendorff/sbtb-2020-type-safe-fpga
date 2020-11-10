//! Interact with FPGA quadrant classifier.

use sbtb::resources::Resource;
use sbtb::traits::{ReadOnly, ReadWrite, Session};
use sbtb::{
    take_fpga_session, FpgaApiResult, POINT_NN_INPUT_VECTOR_OFFSET, POINT_NN_OUTPUT_CLASS_OFFSET,
};

use fixed::types::I7F25;

fn fx_to_u32(fx: I7F25) -> u32 {
    u32::from_le_bytes(fx.to_le_bytes())
}

fn run() -> FpgaApiResult<()> {
    // Get the FPGA singleton. Better not try and do this more than once!
    let mut sesh = take_fpga_session();

    // Define the resources.
    let input_point_regs = Resource::<(I7F25, I7F25), ReadWrite>::new(
        "Input Point Registers(X, Y)",
        POINT_NN_INPUT_VECTOR_OFFSET,
    );
    let out_class_reg = Resource::<I7F25, ReadOnly>::new(
        "Output Classification Register",
        POINT_NN_OUTPUT_CLASS_OFFSET,
    );

    // Locations (Fixed point 7/25 values).
    let pos_x = I7F25::from_num(1.5);
    let neg_x = I7F25::from_num(-1.5);
    let pos_y = I7F25::from_num(2.5);
    let neg_y = I7F25::from_num(-2.5);

    let pos_x_hex_literal = fx_to_u32(pos_x);
    let neg_x_hex_literal = fx_to_u32(neg_x);
    let pos_y_hex_literal = fx_to_u32(pos_y);
    let neg_y_hex_literal = fx_to_u32(neg_y);

    let zero = I7F25::from_num(0);
    let zero_hex_literal = fx_to_u32(zero);

    // Do some FPGA stuff!
    // Quadrant 1.
    println!("\nQuadrant 1");
    println!("++++++++++\n");
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        zero, zero, zero_hex_literal, zero_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (zero, zero))?;
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        pos_x, pos_y, pos_x_hex_literal, pos_y_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (pos_x, pos_y))?;
    let (px, py) = sesh.readw(&input_point_regs)?;
    println!(
        "Read ({}, {}) hex ({:#X}, {:#X}) from {}",
        px,
        py,
        fx_to_u32(px),
        fx_to_u32(py),
        &input_point_regs
    );
    println!("\nReading result from {}", &out_class_reg);
    println!("==============\n");
    let q1_actual = sesh.read(&out_class_reg)?;
    let q1_expected = I7F25::from_num(1.0);
    println!(
        "Actual output:   {} hex {:#X}",
        q1_actual,
        fx_to_u32(q1_actual)
    );
    println!(
        "Expected output: {} hex {:#X}",
        q1_expected,
        fx_to_u32(q1_expected)
    );

    // Quadrant 2.
    println!("\nQuadrant 2");
    println!("++++++++++\n");
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        zero, zero, zero_hex_literal, zero_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (zero, zero))?;
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        neg_x, pos_y, neg_x_hex_literal, pos_y_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (neg_x, pos_y))?;
    let (px, py) = sesh.readw(&input_point_regs)?;
    println!(
        "Read ({}, {}) hex ({:#X}, {:#X}) from {}",
        px,
        py,
        fx_to_u32(px),
        fx_to_u32(py),
        &input_point_regs
    );
    println!("\nReading result from {}", &out_class_reg);
    println!("==============\n");
    let q2_actual = sesh.read(&out_class_reg)?;
    let q2_expected = I7F25::from_num(-1.0);
    println!(
        "Actual output:   {} hex {:#X}",
        q2_actual,
        fx_to_u32(q2_actual)
    );
    println!(
        "Expected output: {} hex {:#X}",
        q2_expected,
        fx_to_u32(q2_expected)
    );

    // Quadrant 3.
    println!("\nQuadrant 3");
    println!("++++++++++\n");
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        zero, zero, zero_hex_literal, zero_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (zero, zero))?;
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        neg_x, neg_y, neg_x_hex_literal, neg_y_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (neg_x, neg_y))?;
    let (px, py) = sesh.readw(&input_point_regs)?;
    println!(
        "Read ({}, {}) hex ({:#X}, {:#X}) from {}",
        px,
        py,
        fx_to_u32(px),
        fx_to_u32(py),
        &input_point_regs
    );
    println!("\nReading result from {}", &out_class_reg);
    println!("==============\n");
    let q3_actual = sesh.read(&out_class_reg)?;
    let q3_expected = q1_expected;
    println!(
        "Actual output:   {} hex {:#X}",
        q3_actual,
        fx_to_u32(q3_actual)
    );
    println!(
        "Expected output: {} hex {:#X}",
        q3_expected,
        fx_to_u32(q3_expected)
    );

    // Quadrant 4.
    println!("\nQuadrant 4");
    println!("++++++++++\n");
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        zero, zero, zero_hex_literal, zero_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (zero, zero))?;
    println!(
        "Writing ({}, {}) hex ({:#X}, {:#X}) to {}",
        pos_x, neg_y, pos_x_hex_literal, neg_y_hex_literal, &input_point_regs
    );
    sesh.write(&input_point_regs, (pos_x, neg_y))?;
    let (px, py) = sesh.readw(&input_point_regs)?;
    println!(
        "Read ({}, {}) hex ({:#X}, {:#X}) from {}",
        px,
        py,
        fx_to_u32(px),
        fx_to_u32(py),
        &input_point_regs
    );
    println!("\nReading result from {}", &out_class_reg);
    println!("==============\n");
    let q4_actual = sesh.read(&out_class_reg)?;
    let q4_expected = q2_expected;
    println!(
        "Actual output:   {} hex {:#X}",
        q4_actual,
        fx_to_u32(q4_actual)
    );
    println!(
        "Expected output: {} hex {:#X}",
        q4_expected,
        fx_to_u32(q4_expected)
    );

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
