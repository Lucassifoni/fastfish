use rand::Rng;
use std::cmp;
use std::f32::consts::PI;

#[derive(Copy, Clone)]
struct Point {
    x: f32,
    y: f32,
}

#[rustler::nif]
fn sample(
    width: i32,
    height: i32,
    distance: f32,
    k_samples: i32,
    positions: i32,
) -> Vec<(f32, f32)> {
    let mut rng = rand::thread_rng();
    let mut grid = vec![-1; width as usize * height as usize];
    let _cell_size = distance as f32 / (2.0_f32).sqrt();
    let mut placed_items: Vec<Point> = Vec::new();
    let mut active_list: Vec<Point> = Vec::new();
    

    let first_point = Point {
        x: width as f32 / 2.0 - (distance as f32) / 2.0,
        y: height as f32 / 2.0 - (distance as f32) / 2.0,
    };

    placed_items.push(first_point);
    active_list.push(first_point);
    insert_point(&mut grid, width, first_point.x, first_point.y, 0);

    while active_list.len() != 0 && placed_items.len() < positions as usize {
        let l = active_list.len();
        let i = (l as f32 * rng.gen::<f32>()).trunc() as i32;
        let base_point = active_list[i as usize];
        let mut found : Option<Point> = None;
        for _k in 0..k_samples {
            let point = generate_point(base_point, distance);
            if is_out_of_bounds(point.x, point.y, width, height) || too_close_to_someone(point.x, point.y, width, height, &grid, &placed_items, distance) {
            } else {
                found = Some(point);
                break;
            }
        }
        match found {
            None => {
                active_list.remove(i as usize);
            }
            Some(p) => {
                active_list.push(p);
                insert_point(&mut grid, width, p.x, p.y, (active_list.len() - 1) as i32);
                placed_items.push(p);
            }
        }
    }
    let f_len = placed_items.len();
    if f_len == positions as usize {
        return placed_items.iter().map(|p| (p.x, p.y)).collect();
    } else {
        return Vec::<(f32, f32)>::new();
    }
}

fn insert_point(grid: &mut Vec<i32>, width: i32, x: f32, y: f32, point_index: i32) {
    let index = y.trunc() as i32 * width + x.trunc() as i32;
    grid[index as usize] = point_index;
}

fn generate_point(base_point: Point, radius: f32) -> Point {
    let mut rng = rand::thread_rng();
    let angle = random_angle();
    let p_radius = rng.gen::<f32>() * 2.0 * radius + radius;
    let x = base_point.x + p_radius * angle.cos();
    let y = base_point.y + p_radius * angle.sin();
    return Point { x: x, y: y };
}

fn too_close_to_someone(
    x: f32,
    y: f32,
    width: i32,
    height: i32,
    grid: &Vec<i32>,
    points: &Vec<Point>,
    radius: f32,
) -> bool {
    let xx = x.trunc() as i32;
    let yy = y.trunc() as i32;
    let lower_x = cmp::max(xx - 2, 0);
    let lower_y = cmp::max(yy - 2, 0);
    let upper_x = cmp::min(xx + 3, width);
    let upper_y = cmp::min(yy + 3, height);

    let mut indices: Vec<i32> = Vec::new();
    for iy in lower_y..upper_y {
        for ix in lower_x..upper_x {
            let index = iy * width + ix;
            let val = grid[index as usize];
            if val != -1 {
                indices.push(val)
            } 
        }
    }
    return indices.iter().fold(false, |acc, index| {
        if acc {
            return acc;
        }
        let point = points[*index as usize];
        let lx = x - point.x;
        let ly = y - point.y;
        return (lx * lx + ly * ly).sqrt() < radius;
    })
}

fn is_out_of_bounds(x: f32, y: f32, width: i32, height: i32) -> bool {
    let xx = x.trunc() as i32;
    let yy = y.trunc() as i32;
    let res = !(xx > 0 && xx < width && yy > 0 && yy < height);
    return res;
}

fn random_angle() -> f32 {
    let mut rng = rand::thread_rng();
    return PI * 2.0 * rng.gen::<f32>();
}

rustler::init!("Elixir.Fastfish.Rsnif", [sample]);
