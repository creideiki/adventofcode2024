use std::collections::{HashMap, VecDeque};
use std::fmt::{Display, Formatter, Result};
use std::fs;
use regex::Regex;

#[derive(Debug)]
struct CPU {
    regs: HashMap<char, u32>,
    program: Vec<u32>,
    ip: usize,
    output: Vec<u32>,
}

impl CPU {
    fn new() -> CPU {
        CPU {
            regs: HashMap::new(),
            program: vec![],
            ip: 0,
            output: vec![],
        }
    }

    fn load_reg(&mut self, reg: &char, value: u32) {
        self.regs.insert(*reg, value);
    }

    fn load_program(&mut self, program: Vec<u32>) {
        self.program = program;
    }

    fn combo(&self, op: u32) -> u32 {
        match op {
            0..=3 => op,
            4     => self.regs[&'a'],
            5     => self.regs[&'b'],
            6     => self.regs[&'c'],
            _     => panic!("Illegal combo operator: {op}.")
        }
    }

    fn step(&mut self) -> bool {
        if self.ip >= self.program.len() { return false; }

        let insn = self.program[self.ip];
        self.ip += 1;
        let op = self.program[self.ip];
        self.ip += 1;

        match insn {
            0 => { self.regs.insert('a', self.regs[&'a'] / 2_u32.pow(self.combo(op))); },
            1 => { self.regs.insert('b', self.regs[&'b'] ^ op); },
            2 => { self.regs.insert('b', self.combo(op) % 8); },
            3 => { if self.regs[&'a'] != 0 { self.ip = op as usize; }; },
            4 => { self.regs.insert('b', self.regs[&'b'] ^ self.regs[&'c']); },
            5 => { self.output.push(self.combo(op) % 8); },
            6 => { self.regs.insert('b', self.regs[&'a'] / 2_u32.pow(self.combo(op))); },
            7 => { self.regs.insert('c', self.regs[&'a'] / 2_u32.pow(self.combo(op))); },
            _ => { panic!("Illegal opcode: {op}."); },
        };
        true
    }
}

impl Display for CPU {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "<CPU:\n")?;
        for (reg, value) in self.regs.iter() {
            write!(f, "{}={}\n", reg, value)?;
        }
        write!(f, "IP={}", self.ip)?;
        write!(f, "\nProgram: ")?;
        for inst in self.program.iter() {
            write!(f, "{} ", inst)?;
        }
        write!(f, "\nOutput: ")?;
        for out in self.output.iter() {
            write!(f, "{} ", out)?;
        }
        write!(f, "\n>")?;
        Ok(())
    }
}

fn main() {
    let input = fs::read_to_string("../17.input").unwrap();

    let reg_format = Regex::new(r"^Register (?<reg>[[:alpha:]]): (?<val>[0-9]+)$").unwrap();
    let prog_format = Regex::new(r"^Program: (?<insns>[,0-9]+)$").unwrap();

    let mut cpu = CPU::new();

    let mut lines: VecDeque<&str> = VecDeque::from_iter(input.lines());
    loop {
        let line = lines.pop_front()
            .unwrap()
            .trim();
        if line.is_empty() { break; }
        let caps = reg_format.captures(line).unwrap();
        cpu.load_reg(&caps["reg"].to_lowercase().chars().nth(0).unwrap(),
                     (&caps["val"]).parse::<u32>().unwrap());
    }
    let line = lines.pop_front().unwrap().trim();
    let caps = prog_format.captures(line).unwrap();
    cpu.load_program((&caps["insns"])
                     .split(",")
                     .map(|i| i.parse::<u32>().unwrap())
                    .collect());

    while cpu.step() {}
    println!("{}", cpu.output.iter().map(|o| o.to_string()).collect::<Vec<_>>().join(","));
}
