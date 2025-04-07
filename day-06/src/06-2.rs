extern crate nalgebra as na;
use na::DMatrix;
use rayon::prelude::*;
use std::fmt::{Display, Formatter, Result};
use std::fs;

#[derive(Debug,PartialEq)]
enum Res {
    Again,
    Loop,
    Leave,
}

#[derive(Debug,Clone,PartialEq)]
enum Direction {
    North,
    East,
    South,
    West,
}

#[derive(Debug,Clone)]
struct Puzzle {
    height: usize,
    width: usize,
    map: DMatrix<u8>,
    init_guard_y: usize,
    init_guard_x: usize,
    init_guard_dir: Direction,
    guard_y: usize,
    guard_x: usize,
    guard_dir: Direction,
}

impl Puzzle {
    fn new(data: &str) -> Puzzle {
        let height = data.lines().count();
        let width = data.lines().nth(0).unwrap().chars().count();

        let mut init_guard_y = 0;
        let mut init_guard_x = 0;
        let mut guard_y = 0;
        let mut guard_x = 0;
        let init_guard_dir = Direction::North;
        let guard_dir = init_guard_dir.clone();

        let mut map = DMatrix::zeros(height, width);

        for (row, line) in data.lines().enumerate() {
            for (col, c) in line.chars().enumerate() {
                match c {
                    '.' => map[(row, col)] = 0,
                    '#' => map[(row, col)] = 1,
                    '^' => {
                        map[(row, col)] = 2;
                        init_guard_y = row;
                        guard_y = init_guard_y;
                        init_guard_x = col;
                        guard_x = init_guard_x;
                    },
                    _ => panic!("Unknown input symbol {}", c)
                }
            }
        }

        Puzzle {
            height,
            width,
            map,
            init_guard_y,
            init_guard_x,
            init_guard_dir,
            guard_y,
            guard_x,
            guard_dir,
        }
    }

    fn reset(&mut self) {
        self.guard_y = self.init_guard_y;
        self.guard_x = self.init_guard_x;
        self.guard_dir = self.init_guard_dir.clone();
    }

    fn add_obstacle(&mut self, y: usize, x: usize) {
        self.map[(y, x)] = 1;
    }

    fn walk(&mut self) -> u32 {
        let mut visited: Vec<(usize, usize, Direction)> = vec![];

        let mut res: Res = Res::Again;
        while res == Res::Again {
            match visited.iter()
                .find(|c| **c == (self.guard_y, self.guard_x, self.guard_dir.clone())) {
                    Some(_) => {
                        res = Res::Loop;
                        continue;
                    },
                    None => {},
                }

            visited.push((self.guard_y, self.guard_x, self.guard_dir.clone()));

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
                    res = Res::Leave;
                }
            else if self.map[(next_y as usize, next_x as usize)] == 1 {
                self.guard_dir = match self.guard_dir {
                    Direction::North => Direction::East,
                    Direction::East  => Direction::South,
                    Direction::South => Direction::West,
                    Direction::West  => Direction::North,
                };
                res = Res::Again;
            }
            else {
                self.map[(next_y as usize, next_x as usize)] = 2;
                self.guard_y = next_y as usize;
                self.guard_x = next_x as usize;
                res = Res::Again;
            }
        }

        match res {
            Res::Loop  => 1,
            Res::Leave => 0,
            _          => panic!("Unknown exit status"),
        }
    }

    fn route(&self) -> Vec<(usize, usize)> {
        let mut route = vec![];
        for y in 0..self.height {
            for x in 0..self.width {
                if self.map[(y, x)] == 2 {
                    route.push((y, x));
                }
            }
        }
        route
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

    p.walk();

    let score: u32 = p.route()
        .par_iter()
        .map(|candidate_obstacle| {
            let mut simulation = p.clone();
            simulation.reset();
            simulation.add_obstacle(candidate_obstacle.0,
                                    candidate_obstacle.1);
            simulation.walk()
        })
        .sum();
    println!("{}", score);
}
