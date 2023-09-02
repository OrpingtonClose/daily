//https://doc.rust-lang.org/book/ch02-00-guessing-game-tutorial.html

use std::io;
use std::cmp::Ordering;
use rand::Rng;

fn main() {
  println!("guess the number!");

  let secret_number = rand::thread_rng().gen_range(1..=100);

  println!("secret is {secret_number}");

  loop {
    let mut guess = String::new();
    io::stdin().read_line(&mut guess).expect("failed to read a line!");
    let guess: u32 = match guess.trim().parse() {
      Ok(num) => num,
      Err(_) => continue,
    };

    println!("you guessed {guess}");

    match guess.cmp(&secret_number) {
      Ordering::Less => { println!("Too small"); }
      Ordering::Greater => { println!("Too big"); }
      Ordering::Equal => {
        println!("you win");
        break;
      }
    }
  }
}
