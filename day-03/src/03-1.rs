use std::fs;
use regex::Regex;

fn main() {
    let input = fs::read_to_string("../03.input").unwrap();
    let inst = Regex::new(r"mul\([0-9]+,[0-9]+\)").unwrap();

    let score = inst.find_iter(&input)
        .map(|m| m.as_str())
        .map(|m| {
            let l = m.len();
            &m[4..l-1]
        })
        .map(|m| m.split(",")
             .map(|num| num.parse::<i64>().unwrap())
             .collect::<Vec<_>>())
        .map(|m| m[0] * m[1])
        .reduce(|a, b| a + b).unwrap();

    println!("{score}");
}
