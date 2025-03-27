use std::fs;

#[derive(Debug)]
struct Report {
    levels: Vec<i32>,
    differences: Vec<i32>,
}

impl Report {
    fn new(levels: Vec<i32>) -> Report {
        let mut r = Report {
            levels,
            differences: vec![],
        };
        r.gen_differences();
        r
    }

    fn gen_differences(&mut self) {
        self.differences = vec![];
        for i in 0..(self.levels.len() - 1) {
            self.differences.push(self.levels[i + 1] - self.levels[i]);
        }
    }

    fn is_safe(&self) -> bool {
        (self.differences.iter().all(|d| d.is_positive()) ||
         self.differences.iter().all(|d| d.is_negative())) &&
        self.differences.iter().all(|d| d.abs() >= 1 && d.abs() <= 3)
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
