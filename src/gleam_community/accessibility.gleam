// IMPORTS --------------------------------------------------------------------

import gleam/float
import gleam/list
import gleam_community/colour.{Colour}

// UTILITIES ------------------------------------------------------------------

fn intensity(colour_value: Float) -> Float {
  // Calculation taken from https://www.w3.org/TR/WCAG20/#relativeluminancedef
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

/// Returns the relative brightness of the given `Colour` as a `Float` between
/// 0.0, and 1.0 with 0.0 being the darkest possible colour and 1.0 being the lightest.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// fn example() {
///   luminance(colour.white) // 1.0
/// }
/// ```
/// </details>
///
/// <div style="position: relative;">
///     <a style="position: absolute; left: 0;" href="https://github.com/gleam-community/colour/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
///     <a style="position: absolute; right: 0;" href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn luminance(colour: Colour) -> Float {
  // Calculation taken from https://www.w3.org/TR/WCAG20/#relativeluminancedef
  let #(r, g, b, _) = colour.to_rgba(colour)

  let r_intensity = intensity(r)
  let g_intensity = intensity(g)
  let b_intensity = intensity(b)

  0.2126 *. r_intensity +. 0.7152 *. g_intensity +. 0.0722 *. b_intensity
}

/// Returns the contrast between two `Colour` values as a `Float` between 1.0,
/// and 21.0 with 1.0 being no contrast and, 21.0 being the highest possible contrast.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// fn example() {
///   contrast_ratio(between: colour.white, and: colour.black) // 21.0
/// }
/// ```
/// </details>
///
/// <div style="position: relative;">
///     <a style="position: absolute; left: 0;" href="https://github.com/gleam-community/colour/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
///     <a style="position: absolute; right: 0;" href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn contrast_ratio(between colour_a: Colour, and colour_b: Colour) -> Float {
  // Calculation taken from https://www.w3.org/TR/WCAG20/#contrast-ratiodef
  let luminance_a = luminance(colour_a) +. 0.05
  let luminance_b = luminance(colour_b) +. 0.05

  case luminance_a >. luminance_b {
    True -> luminance_a /. luminance_b
    False -> luminance_b /. luminance_a
  }
}

/// Returns the `Colour` with the highest contrast between the base `Colour`,
/// and and the other provided `Colour` values.
///
/// <details>
/// <summary>Example:</summary>
///
/// ```gleam
/// fn example() {
///   maximum_contrast(
///    colour.yellow,
///    [colour.white, colour.dark_blue, colour.green],
///  )
/// }
/// ```
/// </details>
///
/// <div style="position: relative;">
///     <a style="position: absolute; left: 0;" href="https://github.com/gleam-community/colour/issues">
///         <small>Spot a typo? Open an issue!</small>
///     </a>
///     <a style="position: absolute; right: 0;" href="#">
///         <small>Back to top ↑</small>
///     </a>
/// </div>
///
pub fn maximum_contrast(
  base: Colour,
  colours: List(Colour),
) -> Result(Colour, Nil) {
  colours
  |> list.sort(fn(colour_a, colour_b) {
    let contrast_a = contrast_ratio(base, colour_a)
    let contrast_b = contrast_ratio(base, colour_b)

    float.compare(contrast_b, contrast_a)
  })
  |> list.first()
}
