use std::fs;
use itertools::Itertools;

#[derive(Debug)]
struct Report {
    levels: Vec<i32>,
}

impl Report {
    fn new(levels: Vec<i32>) -> Report {
        Report {
            levels,
        }
    }

    fn is_safe_levels(levels: &Vec<&i32>) -> bool {
        let mut differences = vec![];
        for i in 0..(levels.len() - 1) {
            differences.push(levels[i + 1] - levels[i]);
        }

        (differences.iter().all(|d| d.is_positive()) ||
         differences.iter().all(|d| d.is_negative())) &&
        differences.iter().all(|d| d.abs() >= 1 && d.abs() <= 3)
    }

    fn is_safe(&self) -> bool {
        self.levels.iter()
            .combinations(self.levels.len() - 1)
            .any(|l| Report::is_safe_levels(&l))
    }
}

fn main() {
    let safe_count =
        fs::read_to_string("../02.input")
        .unwrap()
        .lines()
        .map(|l| {
            l.trim()
                .split_whitespace()
                .map(|s| s.parse::<i32>().unwrap())
        })
        .map(|l| Report::new(l.collect()).is_safe())
        .filter(|safe| *safe)
        .count();

    println!("{safe_count}");
}
