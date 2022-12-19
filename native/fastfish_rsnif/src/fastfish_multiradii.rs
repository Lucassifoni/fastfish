use rand::seq::SliceRandom;
use rand::{thread_rng, Rng};

#[derive(Copy, Clone)]
pub struct DataCircle {
    pub x: f32,
    pub y: f32,
    pub r: f32,
    pub data: f32,
}

fn random_angle() -> f32 {
    let mut rng = rand::thread_rng();
    return std::f32::consts::PI * 2.0 * rng.gen::<f32>();
}

fn random_coords_around(x: f32, y: f32, r1: f32, r2: f32, distance: f32) -> [f32; 2] {
    let a = random_angle();
    let p = distance * 2.0 + r1 + r2;
    return [x + p * a.cos(), y + p * a.sin()];
}

fn intersects(x1: f32, y1: f32, r1: f32, x2: f32, y2: f32, r2: f32, distance: f32) -> bool {
    let d = r2 + r1 + distance;
    let dx = x1 - x2;
    let dy = y1 - y2;
    return dx * dx + dy * dy < (d * d);
}

fn intersects_any(check: Vec<DataCircle>, x: f32, y: f32, radius: f32, distance: f32) -> bool {
    return check
        .iter()
        .any(|cur| intersects(x, y, radius, cur.x, cur.y, cur.r, distance));
}

fn circles_to_check(
    all_circles: &Vec<DataCircle>,
    x: f32,
    y: f32,
    r1: f32,
    r2: f32,
    distance: f32,
) -> Vec<DataCircle> {
    let res: Vec<DataCircle> = all_circles.clone()
        .into_iter()
        .filter(|c| {
            intersects(
                c.x,
                c.y,
                c.r,
                x,
                y,
                r1 + distance * 2.0 + 2.0 * r2,
                distance,
            )
        })
        .collect();
    return res;
}

pub fn place(items: Vec<f32>, distance: f32, k: i32) -> Vec<DataCircle> {
    let mut list = items.clone();
    let mut rng = thread_rng();
    list.shuffle(&mut rng);
    if items.len() == 0 {
        return vec![];
    } else {
        match list.pop() {
            None => {
                return vec![];
            }
            Some(item) => {
                let cur: DataCircle = DataCircle {
                    data: item,
                    x: 0.0,
                    y: 0.0,
                    r: item,
                };
                let mut active_circles: Vec<DataCircle> = vec![cur];
                let mut all_circles: Vec<DataCircle> = vec![cur];
                let mut active_index: usize = 0;
                let rad = cur.r;

                while active_circles.len() > 0 && list.len() > 0 {
                    let a = active_circles[active_index];
                    let current_coords = [a.x, a.y];
                    match list.pop() {
                        None => {
                            return all_circles;
                        }
                        Some(c) => {
                            let mut kk = k;
                            let mut inter = true;
                            let mut new_coords = current_coords;
                            let to_check = circles_to_check(
                                &all_circles,
                                current_coords[0],
                                current_coords[1],
                                rad,
                                c,
                                distance,
                            );
                            while inter && kk > 0 {
                                new_coords = random_coords_around(
                                    current_coords[0],
                                    current_coords[1],
                                    rad,
                                    c,
                                    distance,
                                );
                                inter = intersects_any(
                                    to_check.clone(),
                                    new_coords[0],
                                    new_coords[1],
                                    c,
                                    distance,
                                );
                                kk = kk - 1;
                            }
                            if kk == 0 {
                                active_circles.remove(active_index);
                                active_index = (rng.gen::<f32>() * active_circles.len() as f32).trunc() as usize;
                                list.push(c);
                            } else {
                                let f = DataCircle {
                                    x: new_coords[0],
                                    y: new_coords[1],
                                    r: c,
                                    data: c,
                                };
                                active_circles.push(f);
                                all_circles.push(f);
                            }
                        }
                    }
                }
                return all_circles;
            }
        }
    }
}
