use std::fs;

fn find_dir(
    haystack: &Vec<Vec<u32>>,
    needle: &[u32],
    x: i32,
    y: i32,
    dx: i32,
    dy: i32,
) -> bool {
    if needle.len() == 0 { return true; }

    if x < 0 ||
        x >= haystack[0].len() as i32 ||
        y < 0 ||
        y >= haystack.len() as i32 {
            return false;
        }

    if haystack[y as usize][x as usize] != needle[0] { return false; }

    find_dir(&haystack, &needle[1..], x + dx, y + dy, dx, dy)
}

fn find(
    haystack: &Vec<Vec<u32>>,
    x: usize,
    y: usize,
) -> usize {
    let needle = ['X', 'M', 'A', 'S'].map(|c| c as u32);

    let mut count = 0;
    for dx in -1..=1 {
        for dy in -1..=1 {
            if dx == 0 && dy == 0 { continue; }

            if find_dir(&haystack, &needle, x as i32, y as i32, dx, dy) {
                count += 1
            }
        }
    }

    count
}

fn main() {
    let haystack: Vec<Vec<u32>> = fs::read_to_string("../04.input")
        .unwrap()
        .lines()
        .map(|l| l.chars().map(|c| c as u32).collect())
        .collect();

    let mut count: usize = 0;

    for y in 0..haystack.len() {
        for x in 0..haystack[0].len() {
            count += find(&haystack, x, y);
        }
    }

    println!("{}", count);
}
