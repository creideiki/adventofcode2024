use std::fs;

#[derive(Debug)]
struct Rule {
    from: i32,
    to: i32,
}

impl Rule {
    fn new(data: &str) -> Rule {
        let terms: Vec<i32> = data.split('|').map(|x| x.parse().unwrap()).collect();

        Rule {
            from: terms[0],
            to: terms[1],
        }
    }
}

#[derive(Debug)]
struct Update {
    pages: Vec<i32>,
}

impl Update {
    fn new(data: &str) -> Update {
        let pages: Vec<i32> = data.split(',').map(|x| x.parse().unwrap()).collect();

        Update {
            pages,
        }
    }

    fn satisfies(&self, rule: &Rule) -> bool {
        let first = match self.pages.iter().position(|p| p == &rule.from) {
            None => { return true }
            Some(x) => x
        };

        let last = match self.pages.iter().position(|p| p == &rule.to) {
            None => { return true }
            Some(x) => x
        };

        first < last
    }

    fn score(&self) -> i32 {
        self.pages[self.pages.len() / 2]
    }
}

#[derive(Debug)]
struct Puzzle {
    rules: Vec<Rule>,
    updates: Vec<Update>,
}

impl Puzzle {
    fn new(data: &str) -> Puzzle {
        let (rules, updates): (Vec<_>, Vec<_>) =
            data
            .lines()
            .filter(|l| !l.is_empty())
            .partition(|l| l.contains('|'));

        let rules = rules.iter().map(|r| Rule::new(r)).collect();
        let updates = updates.iter().map(|u| Update::new(u)).collect();

        Puzzle {
            rules,
            updates,
        }
    }

    fn score(&self) -> i32 {
        self.updates
            .iter()
            .map(|u| {
                match self.rules.iter().all(|r| u.satisfies(r)) {
                    true => u.score(),
                    false => 0,
                }
            })
            .sum()
    }
}

fn main() {
    let input = fs::read_to_string("../05.input").unwrap();

    let p = Puzzle::new(&input);

    println!("{}", p.score());
}
