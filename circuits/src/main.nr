/// Xorshift random number generator
use dep::std;

struct XorShift {
    next: u64    
}

impl XorShift {
    fn new(seed: Field) -> XorShift {
        let rand_seed = std::hash::pedersen([seed]);
        let next = rand_seed[0] as u64;
        
        XorShift {
            next
        }
    }

    fn check_next(self: Self) -> u64 {        
        self.next as u64
    }

    fn get_next(self: Self) -> u64 {
      let mut x = self.next;
      x = x ^ x << 13;
      x = x ^ x >> 17;
      x = x ^ x << 5;
      x
    }
}

// Return 10 random numbers to test against
fn main(seed : Field) -> pub [u64;5] {
    let mut random = XorShift::new(seed);

    // TODO: Currently using this method as mutating self in impl defs is currently broken
    let rand_num = XorShift::get_next(random);
    random.next = rand_num;
    let rand_num2 = XorShift::get_next(random);
    random.next = rand_num2;
    let rand_num3 = XorShift::get_next(random);
    random.next = rand_num3;
    let rand_num4 = XorShift::get_next(random);
    random.next = rand_num4;
    let rand_num5 = XorShift::get_next(random);
    
    [rand_num, rand_num2, rand_num3, rand_num4, rand_num5]
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
