use std::fs;
use regex::Regex;

fn main() {
    let input = fs::read_to_string("../03.input").unwrap();
    let inst = Regex::new(r"do\(\)|don't\(\)|mul\([0-9]+,[0-9]+\)").unwrap();

    let inst_iter = inst.find_iter(&input)
        .map(|m| m.as_str());

    let mut enabled = true;
    let mut sum = 0;

    for inst_str in inst_iter {
        if inst_str.contains(r"don't()") {
            enabled = false;
        } else if inst_str.contains(r"do()") {
            enabled = true;
        } else if enabled {
            let l = inst_str.len();
            let nums = inst_str[4..l-1]
                .split(",")
                .map(|num| num.parse::<i64>().unwrap())
                .collect::<Vec<_>>();
            sum += nums[0] * nums[1];
        }
    }

    println!("{sum}");
}
