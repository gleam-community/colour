// IMPORTS --------------------------------------------------------------------

import gleam/float
import gleam/list
import gleam_community/colour.{Colour}

// UTILITIES ------------------------------------------------------------------

fn intensity(colour_value: Float) -> Float {
  case True {
    _ if colour_value <=. 0.03928 -> colour_value /. 12.92
    _ -> {
      // Is this guaranteed to be `OK`?
      assert Ok(i) = float.power({ colour_value +. 0.055 } /. 1.055, 2.4)
      i
    }
  }
}

// ACCESSIBILITY --------------------------------------------------------------

pub fn luminance(colour: Colour) -> Float {
  let #(r, g, b, _) = colour.to_rgba(colour)

  let r_intensity = intensity(r)
  let g_intensity = intensity(g)
  let b_intensity = intensity(b)

  0.2126 *. r_intensity +. 0.7152 *. g_intensity +. 0.0722 *. b_intensity
}

/// Formula based on: <https://www.w3.org/TR/WCAG20/#relativeluminancedef>
pub fn contrast_ratio(between colour_a: Colour, and colour_b: Colour) -> Float {
  let luminance_a = luminance(colour_a) +. 0.05
  let luminance_b = luminance(colour_b) +. 0.05

  case luminance_a >. luminance_b {
    True -> luminance_a /. luminance_b
    False -> luminance_b /. luminance_a
  }
}

pub fn maximum_contrast(
  base: Colour,
  options: List(Colour),
) -> Result(Colour, Nil) {
  options
  |> list.sort(fn(colour_a, colour_b) {
    let contrast_a = contrast_ratio(base, colour_a)
    let contrast_b = contrast_ratio(base, colour_b)

    float.compare(contrast_b, contrast_a)
  })
  |> list.first()
}
