
pub(crate) fn bitwise_right_shift(bits: [u8; 128]) -> [u8; 128] {
    let mut result: [u8; 128] = [0; 128];
    result[0] = 0;
    for i in 1..128 {
        result[i] = bits[i - 1];
    }
    result
}

pub(crate) fn bits_to_block(bits: [u8; 128]) -> [u8; 16] {
    let mut bytes: [u8; 16] = [0; 16];
    for i in 0..16 {
        let mut byte_bits: [u8; 8] = [0; 8];
        for j in 0..8 {
            byte_bits[j] = bits[i * 8 + j];
        }
        bytes[i] = bits_to_byte(byte_bits);
    }
    bytes
}


pub(crate) fn blocks_to_bits(bytes: [u8; 16]) -> [u8; 128] {
    let mut bits: [u8; 128] = [0; 128];
    for i in 0..16 {
        let byte_bits = byte_to_bits(bytes[i]);
        for j in 0..8 {
            bits[i * 8 + j] = byte_bits[j];
        }
    }
    bits
}

pub(crate) fn byte_to_bits(byte: u8) -> [u8; 8] {
    [
        (byte >> 7) & 1,
        (byte >> 6) & 1,
        (byte >> 5) & 1,
        (byte >> 4) & 1,
        (byte >> 3) & 1,
        (byte >> 2) & 1,
        (byte >> 1) & 1,
        byte & 1,
    ]
}
pub(crate) fn bits_to_byte(bits: [u8; 8]) -> u8 {
    let mut byte = 0;
    for j in 0..8 {
        byte |= bits[j] << (7 - j);
    }
    byte
}

#[test]
fn test_bitwise_right_shift() {
    // Test case 1: Simple right shift
    let input1: [u8; 128] = [
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ];
    let expected_output1: [u8; 128] = [
        0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,    ];
    assert(bitwise_right_shift(input1) == expected_output1);

    // Test case 2: All zeros
    let input2 = [0; 128];
    let expected_output2 = [0; 128];
    assert(bitwise_right_shift(input2) == expected_output2);

    // Test case 3: All ones
    let input3 = [1; 128];
    let expected_output3     = [
        0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    ];
    assert(bitwise_right_shift(input3) == expected_output3);
}


#[test]
fn test_blocks_to_bits() {
    assert(blocks_to_bits([0x00; 16]) == [0; 128]);
    assert(bits_to_block([0; 128]) == [0x00; 16]);
    let expected_output1 = [
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1, 
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1, 
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1, 
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1, 
        0, 0, 0, 0, 0, 0, 0, 1, 
        0, 0, 0, 0, 0, 0, 0, 1,
        0, 0, 0, 0, 0, 0, 0, 1, 
        0, 0, 0, 0, 0, 0, 0, 1, 
    ];

    assert(bits_to_block(expected_output1) == [0x01; 16]);
    assert(blocks_to_bits([0x01; 16]) == expected_output1);
    let expected_output2 = [
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
        0, 0, 0, 0, 0, 0, 1, 0,
    ];
    assert(bits_to_block(expected_output2) == [0x02; 16]);
    assert(blocks_to_bits([0x02; 16]) == expected_output2);
    let expected_output3 = [
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
        0, 0, 0, 0, 0, 0, 1, 1,
    ];

    assert(bits_to_block(expected_output3) == [0x03; 16]);
    assert(blocks_to_bits([0x03; 16]) == expected_output3);
    let expected_output4 = [
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
        0, 0, 0, 0, 0, 1, 0, 0,
    ];
    assert(bits_to_block(expected_output4) == [0x04; 16]);
    assert(blocks_to_bits([0x04; 16]) == expected_output4);
    let expected_output5 = [
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
        0, 0, 0, 0, 0, 1, 0, 1,
    ];
    assert(bits_to_block(expected_output5) == [0x05; 16]);
    assert(blocks_to_bits([0x05; 16]) == expected_output5);
}

#[test]
fn test_byte_to_bits() {
    // byte to bits
    assert(byte_to_bits(0x00) == [0, 0, 0, 0, 0, 0, 0, 0]);
    assert(byte_to_bits(0x01) == [0, 0, 0, 0, 0, 0, 0, 1]);
    assert(byte_to_bits(0x02) == [0, 0, 0, 0, 0, 0, 1, 0]);
    assert(byte_to_bits(0x03) == [0, 0, 0, 0, 0, 0, 1, 1]);
    assert(byte_to_bits(0x04) == [0, 0, 0, 0, 0, 1, 0, 0]);
    assert(byte_to_bits(0x05) == [0, 0, 0, 0, 0, 1, 0, 1]);
    assert(byte_to_bits(0x06) == [0, 0, 0, 0, 0, 1, 1, 0]);
    assert(byte_to_bits(0x07) == [0, 0, 0, 0, 0, 1, 1, 1]);
    assert(byte_to_bits(0x08) == [0, 0, 0, 0, 1, 0, 0, 0]);
    assert(byte_to_bits(0x09) == [0, 0, 0, 0, 1, 0, 0, 1]);
    assert(byte_to_bits(0xFF) == [1, 1, 1, 1, 1, 1, 1, 1]);
    assert(byte_to_bits(0x80) == [1, 0, 0, 0, 0, 0, 0, 0]);
    assert(byte_to_bits(0x7F) == [0, 1, 1, 1, 1, 1, 1, 1]);
    assert(byte_to_bits(0xA5) == [1, 0, 1, 0, 0, 1, 0, 1]);
    assert(byte_to_bits(0x5A) == [0, 1, 0, 1, 1, 0, 1, 0]);
    // Bit to bytes
    assert(bits_to_byte([0, 0, 0, 0, 0, 0, 0, 0]) == 0x00);
    assert(bits_to_byte([0, 0, 0, 0, 0, 0, 0, 1]) == 0x01);
    assert(bits_to_byte([0, 0, 0, 0, 0, 0, 1, 0]) == 0x02);
    assert(bits_to_byte([0, 0, 0, 0, 0, 0, 1, 1]) == 0x03);
    assert(bits_to_byte([0, 0, 0, 0, 0, 1, 0, 0]) == 0x04);
    assert(bits_to_byte([0, 0, 0, 0, 0, 1, 0, 1]) == 0x05);
    assert(bits_to_byte([0, 0, 0, 0, 0, 1, 1, 0]) == 0x06);
    assert(bits_to_byte([0, 0, 0, 0, 0, 1, 1, 1]) == 0x07);
    assert(bits_to_byte([0, 0, 0, 0, 1, 0, 0, 0]) == 0x08);
    assert(bits_to_byte([0, 0, 0, 0, 1, 0, 0, 1]) == 0x09);
    assert(bits_to_byte([1, 1, 1, 1, 1, 1, 1, 1]) == 0xFF);
    assert(bits_to_byte([1, 0, 0, 0, 0, 0, 0, 0]) == 0x80);
    assert(bits_to_byte([0, 1, 1, 1, 1, 1, 1, 1]) == 0x7F);
    assert(bits_to_byte([1, 0, 1, 0, 0, 1, 0, 1]) == 0xA5);
    assert(bits_to_byte([0, 1, 0, 1, 1, 0, 1, 0]) == 0x5A);
}