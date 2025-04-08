use std::fmt::{Display, Formatter, Result};
use std::fs;

#[derive(Debug)]
struct Formula {
    value: i64,
    terms: Vec<i64>,
    opers: Vec<char>,
    possible: bool,
}

impl Formula {
    fn new(line: &str) -> Formula {
        let mut i = line.split(':');
        let val = i.next().unwrap().parse().unwrap();
        let terms: Vec<i64> = i
            .next()
            .unwrap()
            .trim_start()
            .split(' ')
            .map(|s| s.parse::<i64>().unwrap())
            .collect();

        Formula {
            value: val,
            terms,
            opers: vec![],
            possible: false,
        }
    }

    fn solve_tail(&self, result: i64, partial: i64, opers: Vec<char>, terms: &[i64]) -> Vec<char> {
        if partial > result { return vec![] };
        if result == partial && terms.len() == 0 { return opers };
        if terms.len() == 0 { return vec![] };

        let term = terms[0];
        let mut new_opers = opers.clone();
        new_opers.push('+');
        let solution = self.solve_tail(result, partial + term, new_opers, &terms[1..]);
        if solution.len() > 0 { return solution };

        let mut new_opers = opers.clone();
        new_opers.push('*');
        self.solve_tail(result, partial * term, new_opers, &terms[1..])
    }

    fn solve(&mut self) {
        self.opers = self.solve_tail(self.value, self.terms[0], vec![], &self.terms[1..]);
        self.possible = self.opers.len() != 0;
    }
}

impl Display for Formula {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result {
        write!(f, "<Formula: {} = ", self.value)?;
        if self.opers.len() == 0 {
            write!(f, "{:?}", self.terms)?;
        } else {
            for (i, _) in self.opers.iter().enumerate() {
                write!(f, "{} {} ", self.terms[i], self.opers[i])?;
            }
            write!(f, "{}", self.terms.last().unwrap())?;
        }
        if self.possible {
            write!(f, " possible")?;
        }
        write!(f, ">")?;
        Ok(())
    }
}

fn main() {
    let input = fs::read_to_string("../07.input").unwrap();

    let mut formulae: Vec<Formula> = input
        .lines()
        .map(|l| Formula::new(&l))
        .collect();

    formulae.iter_mut().for_each(|f| f.solve());
    let score: i64 = formulae.iter()
        .filter(|f| f.possible )
        .map(|f| f.value )
        .sum();
    println!("{}", score);
}
