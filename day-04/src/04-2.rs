extern crate nalgebra as na;
use na::{DMatrix, Matrix3, matrix};

use std::fs;

#[derive(Debug)]
struct Puzzle {
    height: usize,
    width: usize,
    map: DMatrix<u32>,
    mas_height: usize,
    mas_width: usize,
    xmases: Vec<Matrix3<u32>>,
}

impl Puzzle {
    fn new(data: &str) -> Puzzle {
        let height = data.lines().count();
        let width = data.lines().nth(0).unwrap().chars().count();

        let mut map = DMatrix::zeros(height, width);

        for (row, line) in data.lines().enumerate() {
            for (col, c) in line.chars().enumerate() {
                map[(row, col)] = c as u32;
            }
        }

        let mas1 = matrix!['M' as u32, '.' as u32, 'S' as u32;
                           '.' as u32, 'A' as u32, '.' as u32;
                           'M' as u32, '.' as u32, 'S' as u32];
        let mas2 = matrix![0, 0, 1;
                           0, 1, 0;
                           1, 0, 0] * mas1.transpose();
        let mas3 = matrix![0, 0, 1;
                           0, 1, 0;
                           1, 0, 0] * mas2.transpose();
        let mas4 = matrix![0, 0, 1;
                           0, 1, 0;
                           1, 0, 0] * mas3.transpose();
        let xmases = vec![
            mas1,
            mas2,
            mas3,
            mas4,
        ];

        Puzzle {
            height,
            width,
            map,
            mas_height: 3,
            mas_width: 3,
            xmases,
        }
    }

    fn match_p(&self, y: usize, x: usize) -> bool {
        self.xmases.iter().any(|&xmas| {
            let mut res = true;
            for my in 0..self.mas_height {
                for mx in 0..self.mas_width {
                    if xmas[(my, mx)] == '.' as u32 { continue }

                    if xmas[(my, mx)] != self.map[(y + my, x + mx)] {
                        res = false
                    }
                }
            }
            res
        })
    }

    fn count_matches(&self) -> i32 {
        let mut count = 0;

        for y in 0..=(self.height - self.mas_height) {
            for x in 0..=(self.width - self.mas_width) {
                if self.match_p(y, x) { count += 1 }
            }
        }

        count
    }
}

fn main() {
    let input = fs::read_to_string("../04.input").unwrap();

    let p = Puzzle::new(&input);

    println!("{}", p.count_matches());
}
