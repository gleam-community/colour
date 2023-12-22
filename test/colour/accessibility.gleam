import gleeunit/should
import gleam_community/colour
import gleam_community/colour/accessibility

pub fn contrast_ratio_test() {
  accessibility.contrast_ratio(colour.white, colour.black)
  |> should.equal(21.0)

  accessibility.contrast_ratio(colour.pink, colour.pink)
  |> should.equal(1.0)

  accessibility.contrast_ratio(colour.pink, colour.black)
  |> should.equal(accessibility.contrast_ratio(colour.black, colour.pink))
}

pub fn luminance_test() {
  accessibility.luminance(colour.black)
  |> should.equal(0.0)

  accessibility.luminance(colour.white)
  |> should.equal(1.0)
}

pub fn maximum_contrast_test() {
  accessibility.maximum_contrast(colour.yellow, [
    colour.white,
    colour.dark_blue,
    colour.green,
  ])
  |> should.equal(Ok(colour.dark_blue))
}
