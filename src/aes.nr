use crate::utils::{byte_to_bits, bits_to_byte, Block, word_xor};


// Input Block   Initial Round Key          Round Key             Final Round Key
//     │                │                       │                       │
//     ▼                ▼                       ▼                       ▼
//  ┌─────────┐    ┌──────────┐ ┌────────┐ ┌──────────┐ ┌────────┐ ┌──────────┐
//  │ Block   │──► │   Add    │ │  Sub   │ │   Mix    │ │  Sub   │ │   Add    │
//  │         │    │  Round   │ │ Bytes  │ │ Columns  │ │ Bytes  │ │  Round   │
//  │         │    │   Key    │ │        │ │          │ │        │ │   Key    │
//  └─────────┘    └────┬─────┘ └───┬────┘ └────┬─────┘ └───┬────┘ └────┬─────┘
//                      │           │           │           │           │
//                      ▼           ▼           ▼           ▼           ▼
//                 ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
//                 │ Round 0 │ │ Round 1 │ │ Round 2 │ │ Round   │ │  Final  │
//                 │         │ │   to    │ │   to    │ │ Nr - 1  │ │  Round  │
//                 │         │ │ Nr - 2  │ │ Nr - 1  │ │         │ │         │
//                 └─────────┘ └─────────┘ └─────────┘ └─────────┘ └────┬────┘
//                                                                      │
//                                                                      ▼
//                                                                 Ciphertext
// pub(crate) fn aes(block: Block, key: Stream) -> Block {
//     // TODO(WJ 2024-10-09): implement Key Expansion
//     let state = add_round_key(block, key);
//     state
// }


// @param nk: number of keys can be 4, 6, or 8
// @param nr: number of rounds which can be 10, 12, 14 for AES 128, 192, 256
// @inputs key: array of nk*4 bytes representing the key
// @outputs keyExpanded: array of (nr+1)*4 words i.e for AES 128, 192, 256 it will be  44, 52, 60 words
pub(crate) fn key_expansion(key: [u8; 16]) -> [[u8; 4]; 44] {
    // assert(nk = 4 | nk = 6 | nk = 8);
    // fix nk to 4 and nr to 10 for AES 128
    let nk = 4;
    let nr = 10;

    let total_words = 44;
    let effective_rounds = 10;

    let mut key_expanded: [[u8; 4]; 44] = [[0; 4]; 44];

    // first nk words are the key divided into 4 byte words
    for i in 0..nk {
        let mut temp = [0; 4];
        for j in 0..4 {
            temp[j] = key[i * 4 + j];
        }
        key_expanded[i] = temp;
    }

    // while i ≤ 4 ∗Nr +3 do
    for round in 4..(nr +2) {
        println("round");
        println(round);
        // temp ← w[i−1]
        let mut temp = key_expanded[round - 1];

        // if i mod Nk = 0 then
        if round % nk == 0 {
            // temp ← SUBWORD(ROTWORD(temp))⊕Rcon[i/Nk]
            temp = sub_word(rot_word(temp));
            temp = word_xor(temp, round_constant((round / nk) - 1));
            println("temp after round constant");
            println(temp);
        }
        // else if Nk > 6 and i mod Nk = 4 then
        // } else if nk > 6 & round % nk == 4 {
        //     // temp ← SUBWORD(temp)
        //     temp = sub_word(temp);
        // }

        //  w[i] ← w[i−Nk]⊕temp
        println("key_expanded before word xor");
        println(key_expanded[round - nk]);
        key_expanded[round] = word_xor(key_expanded[round - nk], temp);
        println("key_expanded after word xor");
        println(key_expanded[round]);
        //  i ← i+1 
    }

    key_expanded
}

#[test]
fn tkey_expansion(){
    let key = [0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c];
    let keyExpanded = [
      [0x2b, 0x7e, 0x15, 0x16], // got this
      [0x28, 0xae, 0xd2, 0xa6], // got this
      [0xab, 0xf7, 0x15, 0x88], // got this
      [0x09, 0xcf, 0x4f, 0x3c], // got this
      [0xa0, 0xfa, 0xfe, 0x17], // got this
      [0x88, 0x54, 0x2c, 0xb1], // got this
      [0x23, 0xa3, 0x39, 0x39], // got this
      [0x2a, 0x6c, 0x76, 0x05], // got this
      [0xf2, 0xc2, 0x95, 0xf2], // got this
      [0x7a, 0x96, 0xb9, 0x43], // got this
      [0x59, 0x35, 0x80, 0x7a], // got this
      [0x73, 0x59, 0xf6, 0x7f], // got this
      [0x3d, 0x80, 0x47, 0x7d],
      [0x47, 0x16, 0xfe, 0x3e],
      [0x1e, 0x23, 0x7e, 0x44],
      [0x6d, 0x7a, 0x88, 0x3b],
      [0xef, 0x44, 0xa5, 0x41],
      [0xa8, 0x52, 0x5b, 0x7f],
      [0xb6, 0x71, 0x25, 0x3b],
      [0xdb, 0x0b, 0xad, 0x00],
      [0xd4, 0xd1, 0xc6, 0xf8],
      [0x7c, 0x83, 0x9d, 0x87],
      [0xca, 0xf2, 0xb8, 0xbc],
      [0x11, 0xf9, 0x15, 0xbc],
      [0x6d, 0x88, 0xa3, 0x7a],
      [0x11, 0x0b, 0x3e, 0xfd],
      [0xdb, 0xf9, 0x86, 0x41],
      [0xca, 0x00, 0x93, 0xfd],
      [0x4e, 0x54, 0xf7, 0x0e],
      [0x5f, 0x5f, 0xc9, 0xf3],
      [0x84, 0xa6, 0x4f, 0xb2],
      [0x4e, 0xa6, 0xdc, 0x4f],
      [0xea, 0xd2, 0x73, 0x21],
      [0xb5, 0x8d, 0xba, 0xd2],
      [0x31, 0x2b, 0xf5, 0x60],
      [0x7f, 0x8d, 0x29, 0x2f],
      [0xac, 0x77, 0x66, 0xf3],
      [0x19, 0xfa, 0xdc, 0x21],
      [0x28, 0xd1, 0x29, 0x41],
      [0x57, 0x5c, 0x00, 0x6e],
      [0xd0, 0x14, 0xf9, 0xa8],
      [0xc9, 0xee, 0x25, 0x89],
      [0xe1, 0x3f, 0x0c, 0xc8],
      [0xb6, 0x63, 0x0c, 0xa6],
    ];
    println("actual \n");
    println(key_expansion(key));
    assert(key_expansion(key) == keyExpanded);
}

fn sub_word(mut word: [u8; 4]) -> [u8; 4] {
    for i in 0..4 {
        word[i] = sbox(word[i]);
    }
    word
}

#[test]
fn test_sub_word() {
    assert(sub_word([0x00, 0x10, 0x20, 0x30]) == [0x63, 0xca, 0xb7, 0x04]);
}

fn rot_word(word: [u8; 4]) -> [u8; 4] {
    [word[1], word[2], word[3], word[0]]
}

#[test]
fn test_rot_word() {
    assert(rot_word([0x01, 0x12, 0x02, 0x30]) ==[0x12, 0x02, 0x30, 0x01]);
}



fn round_constant(round: u8) -> [u8; 4] {
    let constants = [
        [0x01, 0x00, 0x00, 0x00],
        [0x02, 0x00, 0x00, 0x00],
        [0x04, 0x00, 0x00, 0x00],
        [0x08, 0x00, 0x00, 0x00],
        [0x10, 0x00, 0x00, 0x00],
        [0x20, 0x00, 0x00, 0x00],
        [0x40, 0x00, 0x00, 0x00],
        [0x80, 0x00, 0x00, 0x00],
        [0x1b, 0x00, 0x00, 0x00],
        [0x36, 0x00, 0x00, 0x00]
    ];
    constants[round]
}

#[test]
fn test_round_constant() {
    assert(round_constant(0) == [0x01, 0x00, 0x00, 0x00]);
    assert(round_constant(1) == [0x02, 0x00, 0x00, 0x00]);
    assert(round_constant(2) == [0x04, 0x00, 0x00, 0x00]);
    assert(round_constant(3) == [0x08, 0x00, 0x00, 0x00]);
    assert(round_constant(4) == [0x10, 0x00, 0x00, 0x00]);
    assert(round_constant(5) == [0x20, 0x00, 0x00, 0x00]);
    assert(round_constant(6) == [0x40, 0x00, 0x00, 0x00]);
    assert(round_constant(7) == [0x80, 0x00, 0x00, 0x00]);
    assert(round_constant(8) == [0x1b, 0x00, 0x00, 0x00]);
    assert(round_constant(9) == [0x36, 0x00, 0x00, 0x00]);
}

fn add_round_key(state: Block, key: Block) -> Block {
    let mut new_state: Block = [[0; 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            new_state[i][j] = state[i][j] ^ key[j][i];
        }
    }
    new_state
}


// where the multiplication is done in GF(2^8) mod the irreducible polynomial x^8 + x^4 + x^3 + x + 1
// the multiplaction of 1 is multipication by 1, (binary 00000001)
// the multiplaction of 2 is multipication by x, (binary 00000010)
// the multiplaction of 3 is multipication by x + 1, (binary 00000011)

// MixColumns: Applies the equation for each column:
// [s'0,c]   [2 3 1 1][s0,c]
// [s'1,c] = [1 2 3 1][s1,c]
// [s'2,c]   [1 1 2 3][s2,c]
// [s'3,c]   [3 1 1 2][s3,c]
// todo this can certainly be done with a few for loops
fn mix_columns(state: Block) -> Block {
    let mut new_state: Block = state;
    let c1 = [state[0][0], state[1][0], state[2][0], state[3][0]];
    let c2 = [state[0][1], state[1][1], state[2][1], state[3][1]];
    let c3 = [state[0][2], state[1][2], state[2][2], state[3][2]];
    let c4 = [state[0][3], state[1][3], state[2][3], state[3][3]];

    let c1_new = mix_column(c1);
    let c2_new = mix_column(c2);
    let c3_new = mix_column(c3);
    let c4_new = mix_column(c4);

    new_state = [[c1_new[0], c2_new[0], c3_new[0], c4_new[0]],
                  [c1_new[1], c2_new[1], c3_new[1], c4_new[1]],
                  [c1_new[2], c2_new[2], c3_new[2], c4_new[2]],
                  [c1_new[3], c2_new[3], c3_new[3], c4_new[3]]];
    new_state
}



fn mix_column(column: [u8; 4]) -> [u8; 4] {
    let mut new_column = [0; 4];
    new_column[0] = s0(column); // s0
    new_column[1] = s1(column); // s1
    new_column[2] = s2(column); // s2
    new_column[3] = s3(column); // s3
    new_column
}

fn s0(column: [u8; 4]) -> u8 {
    gfmulx(column[0]) ^ gfmul3(column[1]) ^ column[2] ^ column[3]
}

fn s1(column: [u8; 4]) -> u8 {
    column[0] ^ gfmulx(column[1]) ^ gfmul3(column[2]) ^ column[3]
}

fn s2(column: [u8; 4]) -> u8 {
    column[0] ^ column[1] ^ gfmulx(column[2]) ^ gfmul3(column[3])
}

fn s3(column: [u8; 4]) -> u8 {
    gfmul3(column[0]) ^ column[1] ^ column[2] ^ gfmulx(column[3])
}

fn gfmul3(byte: u8) -> u8 {
    gfmulx(byte) ^ byte
}

/// should left shift the bits by one then if the first bit (before the shift) is 1, then xor with 0x1b
fn gfmulx(byte: u8) -> u8 {
    let bits = byte_to_bits(byte);
    let mut result = [0; 8];
    for i in 0..7 {
        result[i] = bits[i + 1];
    }
    let mut result_byte = bits_to_byte(result);
    if bits[0] == 1 {
        result_byte = result_byte ^ 0x1b;
    }
    result_byte
}


// ShiftRows: Performs circular left shift on each row
// 0, 1, 2, 3 shifts for rows 0, 1, 2, 3 respectively
fn shift_rows(state: Block) -> Block {
    let mut new_state = state;
    new_state[1] = [state[1][1], state[1][2], state[1][3], state[1][0]];
    new_state[2] = [state[2][2], state[2][3], state[2][0], state[2][1]];
    new_state[3] = [state[3][3], state[3][0], state[3][1], state[3][2]];
    new_state
}


/// Sbox first
/// the sbox is a 16x16 array of bytes used to looks up values
/// Note: how can i ensure that we use a lookup table here under the hood?
fn sbox(byte: u8) -> u8 {
    let sbox = [
        0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
        0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
        0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
        0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
        0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
        0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
        0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
        0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
        0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
        0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
        0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
        0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
        0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
        0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
        0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
        0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
    ];
    sbox[byte]
}

#[test]
fn ts0() {
    assert(s0([0xd4, 0xbf, 0x5d, 0x30]) == 0x04);
}

#[test]
fn ts1() {
    assert(s1([0xd4, 0xbf, 0x5d, 0x30]) == 0x66);
}

#[test]
fn ts2() {
    assert(s2([0xd4, 0xbf, 0x5d, 0x30]) == 0x81);
}

#[test]
fn ts3() {
    assert(s3([0xd4, 0xbf, 0x5d, 0x30]) == 0xe5);
}

#[test]
fn tmix_column() {
    let column = [0xd4, 0xbf, 0x5d, 0x30];
    let expected = [0x04, 0x66, 0x81, 0xe5];
    assert(mix_column(column) == expected);
}
#[test]
fn tmix_columns() {
    let state = [
      [0xd4, 0xe0, 0xb8, 0x1e],
      [0xbf, 0xb4, 0x41, 0x27],
      [0x5d, 0x52, 0x11, 0x98],
      [0x30, 0xae, 0xf1, 0xe5],
    ];

    let out = [
      [0x04, 0xe0, 0x48, 0x28],
      [0x66, 0xcb, 0xf8, 0x06],
      [0x81, 0x19, 0xd3, 0x26],
      [0xe5, 0x9a, 0x7a, 0x4c],
    ];
    assert(mix_columns(state) == out);
}


#[test]
fn gfmulx_aes() {
    assert(gfmulx(0x01) == 0x02);
    assert(gfmulx(0x02) == 0x04);
    assert(gfmulx(0x03) == 0x06);
    assert(gfmulx(0xbf) == 0x65);
}


#[test]
fn test_shift_rows() {
    let state: Block = [
          [212, 224, 184, 30],
          [39, 191, 180, 65],
          [17, 152, 93, 82],
          [174, 241, 229, 48],
        ];
    let expected: Block = [
          [212, 224, 184, 30],
          [191, 180, 65, 39],
          [93, 82, 17, 152],
          [48, 174, 241, 229],
        ];
    assert(shift_rows(state) == expected);
}


#[test]
fn test_sbox() {
    assert(sbox(0x53) == 0xed);
    assert(sbox(0x00) == 0x63);
}


#[test]
fn test_add_round_key() {

    let state: Block = [
        [4, 224, 72, 40],
        [102, 203, 248, 6],
        [129, 25, 211, 38],
        [229, 154, 122, 76],
    ];
    let roundKey: Block = [
        [160, 250, 254, 23],
        [136, 84, 44, 177],
        [35, 163, 57, 57],
        [42, 108, 118, 5],
    ];

    let newState: Block = [
        [164, 104, 107, 2],
        [156, 159, 91, 106],
        [127, 53, 234, 80],
        [242, 43, 67, 73],
    ];
    assert(add_round_key(state, roundKey) == newState);
}