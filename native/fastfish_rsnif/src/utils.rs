use rand::Rng;
use std::f32::consts::PI;

#[derive(Copy, Clone)]
pub struct Point {
    pub x: f32,
    pub y: f32,
}

pub fn is_out_of_bounds(x: f32, y: f32, width: i32, height: i32) -> bool {
    let xx = x.trunc() as i32;
    let yy = y.trunc() as i32;
    let res = !(xx > 0 && xx < width && yy > 0 && yy < height);
    return res;
}

pub fn random_angle() -> f32 {
    let mut rng = rand::thread_rng();
    return PI * 2.0 * rng.gen::<f32>();
}

pub fn generate_point(base_point: Point, radius: f32) -> Point {
    let mut rng = rand::thread_rng();
    let angle = random_angle();
    let p_radius = rng.gen::<f32>() * 2.0 * radius + radius;
    let x = base_point.x + p_radius * angle.cos();
    let y = base_point.y + p_radius * angle.sin();
    return Point { x: x, y: y };
}