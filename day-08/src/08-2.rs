extern crate nalgebra as na;
use na::DMatrix;
use std::collections::HashMap;
use std::fmt::{Display, Formatter, Result};
use std::fs;
use itertools::Itertools;

#[derive(Debug)]
struct Puzzle {
    height: usize,
    width: usize,
    antennae: HashMap<char, Vec<(usize, usize)>>,
    map: DMatrix<u8>,
    antinodes: DMatrix<u8>,
}

impl Puzzle {
    fn new(data: &str) -> Puzzle {
        let height = data.lines().count();
        let width = data.lines().nth(0).unwrap().chars().count();

        let mut antennae: HashMap<char, Vec<(usize, usize)>> = HashMap::new();
        let mut map = DMatrix::zeros(height, width);
        let antinodes = DMatrix::zeros(height, width);

        for (row, line) in data.lines().enumerate() {
            for (col, c) in line.chars().enumerate() {
                if c == '.' {
                    map[(row, col)] = 0;
                } else {
                    map[(row, col)] = c as u8;
                    let ants = antennae.entry(c).or_insert(vec![]);
                    ants.append(&mut vec![(row, col)]);
                }
            }
        }

        Puzzle {
            height,
            width,
            antennae,
            map,
            antinodes,
        }
    }

    fn find_antinodes(&self, a: &(usize, usize), b: &(usize, usize)) -> Vec<(usize, usize)> {
        let dy = b.0 as i32 - a.0 as i32;
        let dx = b.1 as i32 - a.1 as i32;
        let mut possibles = vec![*a, *b];

        let mut y = a.0 as i32 + dy * 2;
        let mut x = a.1 as i32 + dx * 2;

        while y < self.height as i32 && x < self.width as i32 && y >= 0 && x >= 0 {
            possibles.append(&mut vec![(y as usize, x as usize)]);
            y += dy;
            x += dx;
        }

        let mut y = a.0 as i32 - dy;
        let mut x = a.1 as i32 - dx;

        while y < self.height as i32 && x < self.width as i32 && y >= 0 && x >= 0 {
            possibles.append(&mut vec![(y as usize, x as usize)]);
            y -= dy;
            x -= dx;
        }

        possibles
    }

    fn fill(&mut self) {
        for (_freq, coords) in self.antennae.iter() {
            for pair in coords.iter().combinations(2) {
                for (row, col) in self.find_antinodes(pair[0], pair[1]) {
                    self.antinodes[(row, col)] += 1;
                }
            }
        }
    }

    fn score(&self) -> u32 {
        let mut count = 0;
        for row in 0..self.height {
            for col in 0..self.width {
                if self.antinodes[(row, col)] > 0 {
                    count += 1;
                }
            }
        }
        count
    }
}

impl Display for Puzzle {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "<Puzzle:\n")?;
        write!(f, "Height: {}, width: {}\n", self.height, self.width)?;
        write!(f, "Map:\n")?;
        for row in 0..self.height {
            for col in 0..self.width {
                if self.map[(row, col)] == 0 {
                    write!(f, ".")?;
                } else {
                    write!(f, "{}", self.map[(row, col)] as char)?;
                };
            }
            write!(f, "\n")?;
        }
        write!(f, "Antinodes:\n")?;
        for row in 0..self.height {
            for col in 0..self.width {
                write!(f, "{}", match self.antinodes[(row, col)] {
                    0 => '.',
                    _ => '#',
                })?;
            }
            write!(f, "\n")?;
        }
        write!(f, ">")?;
        Ok(())
    }
}

fn main() {
    let input = fs::read_to_string("../08.input").unwrap();

    let mut p = Puzzle::new(&input);

    p.fill();
    println!("{}", p.score());
}
