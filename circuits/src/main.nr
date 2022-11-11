/// Xorshift random number generator
use dep::std;

struct XorShift {
    next: u32
}

impl XorShift {
    fn new(seed: Field) -> XorShift {
        let rand_seed = std::hash::pedersen([seed]);
        let next = rand_seed[0] as u32;
        
        XorShift {
            next
        }
    }

    fn check_next(self: Self) -> u32 {        
        self.next as u32
    }

    fn get_next(self: Self) -> u32 {
      let mut x = self.next;
      x = x ^ x << 13;
      x = x ^ x >> 17;
      x = x ^ x << 5;
      x
    }
}

// Return 5 random numbers to test against
fn main(seed : Field) -> pub [u32;5] {
    let mut random = XorShift::new(seed);

    // TODO: Currently using this method as mutating self in impl defs is currently broken
    let mut rands: [u32; 5] = [0; 5];
    for i in 0..5 {
        rands[i] = XorShift::get_next(random);
        random.next = rands[i];    
    };
    
    rands
}



// TODO Make an issue to highlight this behaviour
// // Does not work
// struct Test {
//     x: Field
// }

// impl Test {
//     fn add(mut self: Self, y: Field) {
//         self.x = self.x + y;
//     }
// }

// fn main() -> pub Field {
//     let mut t = Test {
//         x: 0
//     };

//     t.add(1);

//     t.x
// }

// // Works
// struct Test {
//     x: Field
// }

// fn main() -> pub Field {
//     let mut t = Test {
//         x: 0
//     };

//     t.x = t.x + 1;

//     t.x
// }
