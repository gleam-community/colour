import gleeunit/should
import gleam_community/colour

pub fn from_rgb255_test() {
  colour.from_rgb255(204, 0, 0)
  |> should.equal(Ok(colour.red))

  colour.from_rgb255(114, 159, 207)
  |> should.equal(Ok(colour.light_blue))

  colour.from_rgb255(255, 175, 243)
  |> should.equal(Ok(colour.pink))
}

pub fn negative_from_rgb255_test() {
  colour.from_rgb255(-1, 0, 0)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_from_rgb255_test() {
  colour.from_rgb255(256, 0, 0)
  |> should.equal(Error(Nil))
}

pub fn from_rgb_test() {
  colour.from_rgb(1.0, 0.6862745098039216, 0.9529411764705882)
  |> should.equal(Ok(colour.pink))
}

pub fn negative_from_rgb_test() {
  colour.from_rgb(-1.0, 0.0, 0.0)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_rgb_test() {
  colour.from_rgb(256.0, 0.0, 0.0)
  |> should.equal(Error(Nil))
}

pub fn from_rgba_test() {
  colour.from_rgba(1.0, 0.6862745098039216, 0.9529411764705882, 1.0)
  |> should.equal(Ok(colour.pink))

  assert Ok(pink_half_opacity) =
    colour.from_rgba(1.0, 0.6862745098039216, 0.9529411764705882, 0.5)

  pink_half_opacity
  |> colour.to_rgba()
  |> should.equal(#(1.0, 0.6862745098039216, 0.9529411764705882, 0.5))
}

pub fn negative_from_rgba_test() {
  colour.from_rgba(-1.0, 0.0, 0.0, 1.0)
  |> should.equal(Error(Nil))

  colour.from_rgba(1.0, 0.0, 0.0, -1.0)
  |> should.equal(Error(Nil))
}

pub fn too_large_rgba_test() {
  colour.from_rgba(1.1, 0.0, 0.0, 1.0)
  |> should.equal(Error(Nil))

  colour.from_rgba(256.0, 0.0, 0.0, 2.0)
  |> should.equal(Error(Nil))
}

pub fn from_rgb_hex_test() {
  colour.from_rgb_hex(0xffaff3)
  |> should.equal(Ok(colour.pink))
}

pub fn negative_from_rgb_hex_test() {
  colour.from_rgb_hex(-1 * 0xffaff3)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_rgb_hex_test() {
  colour.from_rgb_hex(0xfffaff3)
  |> should.equal(Error(Nil))
}

pub fn from_rgb_hex_string_test() {
  colour.from_rgb_hex_string("#ffaff3")
  |> should.equal(Ok(colour.pink))

  colour.from_rgb_hex_string("0xffaff3")
  |> should.equal(Ok(colour.pink))

  colour.from_rgb_hex_string("ffaff3")
  |> should.equal(Ok(colour.pink))
}

pub fn too_large_from_rgb_hex_string_test() {
  colour.from_rgb_hex_string("#fffaff3")
  |> should.equal(Error(Nil))
}

pub fn from_hsl_test() {
  assert Ok(c) = colour.from_hsl(0.25, 0.25, 0.5)

  c
  |> colour.to_rgba()
  |> should.equal(#(0.5, 0.625, 0.375, 1.0))
}

pub fn negative_from_hsl_test() {
  colour.from_hsl(-0.25, 0.25, 0.5)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_hsl_test() {
  colour.from_hsl(25.0, 0.25, 0.5)
  |> should.equal(Error(Nil))
}

pub fn from_hsla_test() {
  assert Ok(c) = colour.from_hsla(h: 0.25, s: 0.25, l: 0.5, a: 1.0)

  colour.to_rgba(c)
  |> should.equal(#(0.5, 0.625, 0.375, 1.0))
}

pub fn negative_from_hsla_test() {
  colour.from_hsla(h: -0.25, s: 0.25, l: 0.25, a: 1.0)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_hsla_test() {
  colour.from_hsla(h: 25.0, s: 0.25, l: 0.25, a: 1.0)
  |> should.equal(Error(Nil))
}
