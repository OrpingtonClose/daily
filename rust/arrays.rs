fn main() {
    let a1: [i64; 4] = [-1, 1, 2, 3];
    println!("first element {}", a1[0]);
    println!("len {}", a1.len());
    let s1 = &a1[1 .. 2];
    println!("slice {}", s1[0]);
}