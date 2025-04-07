extern crate nalgebra as na;
use na::DMatrix;
use std::fmt::{Display, Formatter, Result};
use std::fs;

#[derive(Debug)]
enum Direction {
    North,
    East,
    South,
    West,
}

#[derive(Debug)]
struct Puzzle {
    height: usize,
    width: usize,
    map: DMatrix<u8>,
    guard_y: usize,
    guard_x: usize,
    guard_dir: Direction,
}

impl Puzzle {
    fn new(data: &str) -> Puzzle {
        let height = data.lines().count();
        let width = data.lines().nth(0).unwrap().chars().count();

        let mut guard_y = 0;
        let mut guard_x = 0;
        let guard_dir = Direction::North;

        let mut map = DMatrix::zeros(height, width);

        for (row, line) in data.lines().enumerate() {
            for (col, c) in line.chars().enumerate() {
                match c {
                    '.' => map[(row, col)] = 0,
                    '#' => map[(row, col)] = 1,
                    '^' => {
                        map[(row, col)] = 2;
                        guard_y = row;
                        guard_x = col;
                    },
                    _ => panic!("Unknown input symbol {}", c)
                }
            }
        }

        Puzzle {
            height,
            width,
            map,
            guard_y,
            guard_x,
            guard_dir,
        }
    }

    fn step(&mut self) -> bool {
        let next_y: i32;
        let next_x: i32;

        match self.guard_dir {
            Direction::North => {
                next_y = self.guard_y as i32 - 1;
                next_x = self.guard_x as i32 + 0;
            },
            Direction::East => {
                next_y = self.guard_y as i32 + 0;
                next_x = self.guard_x as i32 + 1;
            },
            Direction::South => {
                next_y = self.guard_y as i32 + 1;
                next_x = self.guard_x as i32 + 0;
            },
            Direction::West => {
                next_y = self.guard_y as i32 + 0;
                next_x = self.guard_x as i32 - 1;
            },
        };

        if next_x < 0 ||
            next_x >= self.width as i32 ||
            next_y < 0 ||
            next_y >= self.height as i32 {
                self.guard_x = next_x as usize;
                self.guard_y = next_y as usize;
                return true;
            }
        else if self.map[(next_y as usize, next_x as usize)] == 1 {
            self.guard_dir = match self.guard_dir {
                Direction::North => Direction::East,
                Direction::East  => Direction::South,
                Direction::South => Direction::West,
                Direction::West  => Direction::North,
            };
            return false;
        }
        else {
            self.map[(next_y as usize, next_x as usize)] = 2;
            self.guard_y = next_y as usize;
            self.guard_x = next_x as usize;
            return false;
        }
    }

    fn visited(&self) -> u32 {
        self.map.iter().map(|e| if *e == 2 { 1 } else { 0 }).sum()
    }
}

impl Display for Puzzle {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "<Puzzle:\n")?;
        write!(f, "Height: {}, width: {}\n", self.height, self.width)?;
        for row in 0..self.height {
            for col in 0..self.width {
                write!(f, "{}", match self.map[(row, col)] {
                    0 => '.',
                    1 => '#',
                    2 => 'X',
                    _ => panic!("Unknown map symbol"),
                })?;
            }
            write!(f, "\n")?;
        }
        write!(f, "Visited: {}\n", self.visited())?;
        write!(f, "Guard row: {}, col: {}, dir: {:?}>",
               self.guard_y, self.guard_x, self.guard_dir)?;
        Ok(())
    }
}

fn main() {
    let input = fs::read_to_string("../06.input").unwrap();

    let mut p = Puzzle::new(&input);

    while !p.step() { }
    println!("{}", p.visited());
}
