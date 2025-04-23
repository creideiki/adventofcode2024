use std::fmt::{Display, Formatter, Result};
use std::fs;

#[derive(Debug,PartialEq)]
enum RunType {
    File,
    Empty,
}

#[derive(Debug)]
struct Run {
    run_type: RunType,
    base: usize,
    length: usize,
    file_num: usize,
}

impl Run {
    fn new_file(base: usize, length: usize, file_num: usize) -> Run {
        Run {
            run_type: RunType::File,
            base,
            length,
            file_num,
        }
    }

    fn new_empty(base: usize, length: usize) -> Run {
        Run {
            run_type: RunType::Empty,
            base,
            length,
            file_num: 0,
        }
    }
}

#[derive(Debug)]
struct Disk {
    runs: Vec<Run>,
}

impl Disk {
    fn new(data: &str) -> Disk {
        let mut file_num: usize = 0;
        let mut block_num: usize = 0;

        let mut runs = vec![];

        for (pos, c) in data.trim().chars().enumerate() {
            let length = c.to_digit(10).unwrap();
            let length = length as usize;
            if pos % 2 == 0 {
                runs.push(Run::new_file(block_num, length, file_num));
                file_num += 1;
            } else {
                runs.push(Run::new_empty(block_num, length));
            }

            block_num += length;
        }

        Disk {
            runs,
        }
    }

    fn find_first_free_index(&self) -> usize {
        self.runs.iter().position(|r| r.run_type == RunType::Empty).unwrap()
    }

    fn find_last_file_index(&self) -> usize {
        self.runs.iter().rposition(|r| r.run_type == RunType::File).unwrap()
    }

    fn compact_one_run(&mut self, free_index: usize, file_index: usize) {
        let run;
        let free_length;
        let file_length;
        {
            let (left, right) = self.runs.split_at_mut(free_index + 1);
            let free = &mut left[free_index];
            let file = &mut right[file_index - free_index - 1];
            let size = *vec![free.length, file.length].iter().min().unwrap();

            run = Run::new_file(free.base, size, file.file_num);

            free.length -= size;
            free_length = free.length;
            free.base += size;

            file.length -= size;
            file_length = file.length;
        }
        self.runs.insert(free_index, run);

        let free_index = free_index + 1;
        let mut file_index = file_index + 1;

        if free_length == 0 {
            self.runs.remove(free_index);
            file_index -= 1;
        }

        if file_length == 0 {
            self.runs.remove(file_index);
        }
    }

    fn compact(&mut self) {
        loop {
            let free_index = self.find_first_free_index();
            let file_index = self.find_last_file_index();

            if file_index < free_index { break; }

            self.compact_one_run(free_index, file_index);
        }
    }

    fn checksum(&self) -> usize {
        let mut checksum = 0;
        let mut index = 0;
        for r in self.runs.iter() {
            if r.run_type == RunType::Empty {
                index += r.length;
                continue;
            } else {
                for i in 0..r.length {
                    checksum += (index + i) * r.file_num;
                }
                index += r.length;
            }
        }
        checksum
    }
}

impl Display for Disk {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "<Disk: ")?;
        for run in self.runs.iter() {
            let c;
            if run.run_type == RunType::File {
                c = run.file_num.to_string();
            } else {
                c = String::from(".")
            }
            write!(f, "{}", c.repeat(run.length))?;
        }
        write!(f, ">")?;
        Ok(())
    }
}

fn main() {
    let input = fs::read_to_string("../09.input").unwrap();

    let mut disk = Disk::new(&input);

    disk.compact();

    println!("{}", disk.checksum());
}
