mod fastfish;
mod fastfish_multiradii;
mod utils;
use rustler::{Encoder, Env, NifResult, Term};

#[rustler::nif]
fn sample(
    width: i32,
    height: i32,
    distance: f32,
    k_samples: i32,
    positions: i32,
) -> Vec<(f32, f32)> {
    return fastfish::sample(width, height, distance, k_samples, positions);
}

#[rustler::nif]
fn sample_multiradii(items: Vec<f32>, a: f32, b: i32) -> Vec<(f32, f32, f32)> {
    let placed = fastfish_multiradii::place(items.into_iter().map(|i| i as f32).collect(), a, b);
    return placed.into_iter().map(|c| (c.x, c.y, c.r)).collect();
}

rustler::init!("Elixir.Fastfish.Rsnif", [sample, sample_multiradii]);
