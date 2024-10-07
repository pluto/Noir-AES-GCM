use crate::utils::{blocks_to_bits, bits_to_block, bitwise_right_shift};

type Block = [u8; 16];

/// Multiplication of the binary extension field by x
/// right shifts a block by one bit
/// if the msb is one, then the 8 most LSBs are XORed with 0xE1
/// this 0xE1 is the the hex rep of 11100001, which represents 
/// the polynomial 1 + x + x^2 + x^7
fn mulx(block: Block) -> [u8; 16] {
    let mut bits = blocks_to_bits(block);
    let result_bits = bitwise_right_shift(bits);
    let mut bytes = bits_to_block(result_bits);
    if bits[127] == 1 {
        bytes[0] = bytes[0] ^ 0xE1;
    }
    bytes
}

#[test]
fn test_mulx() {
    let input: Block = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01];
    let expected: Block = [0xE1, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
    assert(mulx(input) == expected);
}