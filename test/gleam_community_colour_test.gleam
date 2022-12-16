import gleeunit
import gleeunit/should
import gleam_community/colour.{Hsla, Rgba}
import gleam/int

pub fn main() {
  gleeunit.main()
}

pub fn rgb255_test() {
  colour.rgb255(204, 0, 0)
  |> should.equal(Ok(colour.red))

  colour.rgb255(114, 159, 207)
  |> should.equal(Ok(colour.light_blue))

  colour.rgb255(255, 175, 243)
  |> should.equal(Ok(colour.pink))
}

pub fn negative_rgb255_test() {
  colour.rgb255(-1, 0, 0)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_rgb255_test() {
  colour.rgb255(256, 0, 0)
  |> should.equal(Error(Nil))
}

pub fn rgb_test() {
  colour.rgb(1.0, 0.6862745098039216, 0.9529411764705882)
  |> should.equal(Ok(colour.pink))
}

pub fn negative_from_rgb_test() {
  colour.rgb(-1.0, 0.0, 0.0)
  |> should.equal(Error(Nil))
}

pub fn too_large_rgb_test() {
  colour.rgb(256.0, 0.0, 0.0)
  |> should.equal(Error(Nil))
}

pub fn rgba_test() {
  colour.rgba(1.0, 0.6862745098039216, 0.9529411764705882, 1.0)
  |> should.equal(Ok(colour.pink))

  assert Ok(pink_half_opacity) =
    colour.rgba(1.0, 0.6862745098039216, 0.9529411764705882, 0.5)

  pink_half_opacity
  |> colour.to_rgba()
  |> should.equal(Rgba(1.0, 0.6862745098039216, 0.9529411764705882, 0.5))
}

pub fn negative_rgba_test() {
  colour.rgba(-1.0, 0.0, 0.0, 1.0)
  |> should.equal(Error(Nil))

  colour.rgba(1.0, 0.0, 0.0, -1.0)
  |> should.equal(Error(Nil))
}

pub fn too_large_rgba_test() {
  colour.rgba(1.1, 0.0, 0.0, 1.0)
  |> should.equal(Error(Nil))

  colour.rgba(256.0, 0.0, 0.0, 2.0)
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

pub fn from_rgba_hex_test() {
  colour.from_rgba_hex(0xffaff3ff)
  |> should.equal(Ok(colour.pink))
}

pub fn negative_from_rgba_hex_test() {
  colour.from_rgba_hex(int.multiply(-1, 0xffaff3))
  |> should.equal(Error(Nil))
}

pub fn too_large_from_rgba_hex_test() {
  colour.from_rgba_hex(0xfffaff300)
  |> should.equal(Error(Nil))
}

pub fn from_rgba_hex_string_test() {
  colour.from_rgba_hex_string("#ffaff3ff")
  |> should.equal(Ok(colour.pink))

  colour.from_rgba_hex_string("0xffaff3ff")
  |> should.equal(Ok(colour.pink))

  colour.from_rgba_hex_string("ffaff3ff")
  |> should.equal(Ok(colour.pink))
}

pub fn too_large_from_rgba_hex_string_test() {
  colour.from_rgba_hex_string("#fffaff3fff")
  |> should.equal(Error(Nil))
}

pub fn hsl_test() {
  assert Ok(c) = colour.hsl(0.25, 0.25, 0.5)

  c
  |> colour.to_rgba()
  |> should.equal(Rgba(r: 0.5, g: 0.625, b: 0.375, a: 1.0))
}

pub fn negative_hsl_test() {
  colour.hsl(-0.25, 0.25, 0.5)
  |> should.equal(Error(Nil))
}

pub fn too_large_hsl_test() {
  colour.hsl(25.0, 0.25, 0.5)
  |> should.equal(Error(Nil))
}

pub fn from_hsla_test() {
  let hsla = Hsla(h: 0.25, s: 0.25, l: 0.5, a: 1.0)

  assert Ok(c) = colour.from_hsla(hsla)

  colour.to_rgba(c)
  |> should.equal(Rgba(r: 0.5, g: 0.625, b: 0.375, a: 1.0))
}

pub fn negative_from_hsla_test() {
  let hsla = Hsla(h: -0.25, s: 0.25, l: 0.25, a: 1.0)

  colour.from_hsla(hsla)
  |> should.equal(Error(Nil))
}

pub fn too_large_from_hsla_test() {
  let hsla = Hsla(h: 25.0, s: 0.25, l: 0.25, a: 1.0)

  colour.from_hsla(hsla)
  |> should.equal(Error(Nil))
}

pub fn from_rgba_test() {
  Rgba(r: 1.0, g: 0.6862745098039216, b: 0.9529411764705882, a: 1.0)
  |> colour.from_rgba()
  |> should.equal(Ok(colour.pink))
}

pub fn negative_from_rgba_test() {
  Rgba(r: -1.0, g: 0.6862745098039216, b: 0.9529411764705882, a: 1.0)
  |> colour.from_rgba()
  |> should.equal(Error(Nil))
}

pub fn too_large_from_rgba_test() {
  Rgba(r: 10.0, g: 0.6862745098039216, b: 0.9529411764705882, a: 1.0)
  |> colour.from_rgba()
  |> should.equal(Error(Nil))
}
