use std::fs;

fn main() {
    let mut left: Vec<i32> = vec![];
    let mut right: Vec<i32> = vec![];

    for line in fs::read_to_string("01.input")
        .unwrap()
        .lines()
        .map(|l| l.trim()) {
            let parts: Vec<&str> = line.split_whitespace().collect();
            left.push(parts[0].parse().unwrap());
            right.push(parts[1].parse().unwrap());
        }

    left.sort();
    right.sort();

    let diff_sum = left.iter()
        .zip(right.iter())
        .map(|(l, r)| (l - r).abs())
        .reduce(|x, y| x + y).unwrap();

    println!("{diff_sum}");
}
