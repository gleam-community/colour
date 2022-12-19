// IMPORTS --------------------------------------------------------------------

import gleam/bitwise
import gleam/int
import gleam/float
import gleam/result
import gleam/string
import gleam/list

// TYPES ----------------------------------------------------------------------

pub opaque type Colour {
  Rgba(r: Float, g: Float, b: Float, a: Float)
  Hsla(h: Float, s: Float, l: Float, a: Float)
}

pub type Color =
  Colour

// UTILITY --------------------------------------------------------------------

fn valid_colour_value(c: Float) -> Result(Float, Nil) {
  case c >. 1.0 || c <. 0.0 {
    True -> Error(Nil)
    False -> Ok(c)
  }
}

fn hue_to_rgb(hue: Float, m1: Float, m2: Float) -> Float {
  let h = case hue {
    _ if hue <. 0.0 -> hue +. 1.0
    _ if hue >. 1.0 -> hue -. 1.0
    _ -> hue
  }

  let h_t_6 = h *. 6.0
  let h_t_2 = h *. 2.0
  let h_t_3 = h *. 3.0

  case h {
    _ if h_t_6 <. 1.0 -> m1 +. { m2 -. m1 } *. h *. 6.0
    _ if h_t_2 <. 1.0 -> m2
    _ if h_t_3 <. 2.0 -> m1 +. { m2 -. m1 } *. { 2.0 /. 3.0 -. h } *. 6.0
    _ -> m1
  }
}

fn hex_string_to_int(hex_string: String) -> Result(Int, Nil) {
  let hex = case hex_string {
    "#" <> hex_number -> hex_number
    "0x" <> hex_number -> hex_number
    _ -> hex_string
  }

  hex
  |> string.lowercase()
  |> string.to_graphemes()
  |> list.reverse()
  |> list.index_fold(
    Ok(0),
    fn(total, char, index) {
      case total {
        Error(Nil) -> Error(Nil)
        Ok(v) -> {
          use
            num
          <- result.then(case char {
              "f" -> Ok(15)
              "e" -> Ok(14)
              "d" -> Ok(13)
              "c" -> Ok(12)
              "b" -> Ok(11)
              "a" -> Ok(10)
              _ -> int.parse(char)
            })
          use base <- result.then(int.power(16, int.to_float(index)))
          Ok(v + float.round(int.to_float(num) *. base))
        }
      }
    },
  )
}

fn hsla_to_rgba(
  h: Float,
  s: Float,
  l: Float,
  a: Float,
) -> #(Float, Float, Float, Float) {
  let m2 = case l <=. 0.5 {
    True -> l *. { s +. 1.0 }
    False -> l +. s -. l *. s
  }

  let m1 = l *. 2.0 -. m2

  let r = hue_to_rgb(h +. 1.0 /. 3.0, m1, m2)
  let g = hue_to_rgb(h, m1, m2)
  let b = hue_to_rgb(h -. 1.0 /. 3.0, m1, m2)

  #(r, g, b, a)
}

fn rgba_to_hsla(
  r: Float,
  g: Float,
  b: Float,
  a: Float,
) -> #(Float, Float, Float, Float) {
  let min_colour = float.min(r, float.min(g, b))

  let max_colour = float.max(r, float.max(g, b))

  let h1 = case True {
    _ if max_colour == r -> float.divide(g -. b, max_colour -. min_colour)
    _ if max_colour == g ->
      float.divide(b -. r, max_colour -. min_colour)
      |> result.then(fn(d) { Ok(2.0 +. d) })
    _ ->
      float.divide(r -. g, max_colour -. min_colour)
      |> result.then(fn(d) { Ok(4.0 +. d) })
  }

  let h2 = case h1 {
    Ok(v) -> Ok(v *. { 1.0 /. 6.0 })
    _ -> h1
  }

  let h3 = case h2 {
    Ok(v) if v <. 0.0 -> v +. 1.0
    Ok(v) -> v
    _ -> 0.0
  }

  let l = { min_colour +. max_colour } /. 2.0

  let s = case True {
    _ if min_colour == max_colour -> 0.0
    _ if l <. 0.5 ->
      { max_colour -. min_colour } /. { max_colour +. min_colour }
    _ -> { max_colour -. min_colour } /. { 2.0 -. max_colour -. min_colour }
  }

  #(h3, s, l, a)
}

// CONSTRUCTORS ---------------------------------------------------------------

pub fn rgb255(r red: Int, g green: Int, b blue: Int) -> Result(Colour, Nil) {
  use
    r
  <- result.then(
      red
      |> int.to_float()
      |> float.divide(255.0)
      |> result.then(valid_colour_value),
    )

  use
    g
  <- result.then(
      green
      |> int.to_float()
      |> float.divide(255.0)
      |> result.then(valid_colour_value),
    )

  use
    b
  <- result.then(
      blue
      |> int.to_float()
      |> float.divide(255.0)
      |> result.then(valid_colour_value),
    )

  Ok(Rgba(r: r, g: g, b: b, a: 1.0))
}

pub fn rgb(r red: Float, g green: Float, b blue: Float) -> Result(Colour, Nil) {
  use r <- result.then(valid_colour_value(red))
  use g <- result.then(valid_colour_value(green))
  use b <- result.then(valid_colour_value(blue))

  Ok(Rgba(r: r, g: g, b: b, a: 1.0))
}

pub fn from_rgba(
  r red: Float,
  g green: Float,
  b blue: Float,
  a alpha: Float,
) -> Result(Colour, Nil) {
  use r <- result.then(valid_colour_value(red))
  use g <- result.then(valid_colour_value(green))
  use b <- result.then(valid_colour_value(blue))
  use a <- result.then(valid_colour_value(alpha))

  Ok(Rgba(r: r, g: g, b: b, a: a))
}

pub fn from_hsla(
  h hue: Float,
  s saturation: Float,
  l lightness: Float,
  a alpha: Float,
) -> Result(Colour, Nil) {
  use h <- result.then(valid_colour_value(hue))
  use s <- result.then(valid_colour_value(saturation))
  use l <- result.then(valid_colour_value(lightness))
  use a <- result.then(valid_colour_value(alpha))

  Ok(Hsla(h: h, s: s, l: l, a: a))
}

pub fn hsl(
  h hue: Float,
  s saturation: Float,
  l lightness: Float,
) -> Result(Colour, Nil) {
  from_hsla(hue, saturation, lightness, 1.0)
}

pub fn from_rgb_hex(hex: Int) -> Result(Colour, Nil) {
  case hex > 0xffffff || hex < 0 {
    True -> Error(Nil)
    False -> {
      let r =
        bitwise.shift_right(hex, 16)
        |> bitwise.and(0xff)
      let g =
        bitwise.shift_right(hex, 8)
        |> bitwise.and(0xff)
      let b = bitwise.and(hex, 0xff)
      rgb255(r, g, b)
    }
  }
}

pub fn from_rgb_hex_string(hex_string: String) -> Result(Colour, Nil) {
  use hex_int <- result.then(hex_string_to_int(hex_string))

  from_rgb_hex(hex_int)
}

pub fn from_rgba_hex_string(hex_string: String) -> Result(Colour, Nil) {
  use hex_int <- result.then(hex_string_to_int(hex_string))

  from_rgba_hex(hex_int)
}

pub fn from_rgba_hex(hex: Int) -> Result(Colour, Nil) {
  case hex > 0xffffffff || hex < 0 {
    True -> Error(Nil)
    False -> {
      // This won't fail because we are always dividing by 255.0
      assert Ok(r) =
        bitwise.shift_right(hex, 24)
        |> bitwise.and(0xff)
        |> int.to_float()
        |> float.divide(255.0)
      // This won't fail because we are always dividing by 255.0
      assert Ok(g) =
        bitwise.shift_right(hex, 16)
        |> bitwise.and(0xff)
        |> int.to_float()
        |> float.divide(255.0)
      // This won't fail because we are always dividing by 255.0
      assert Ok(b) =
        bitwise.shift_right(hex, 8)
        |> bitwise.and(0xff)
        |> int.to_float()
        |> float.divide(255.0)
      // This won't fail because we are always dividing by 255.0
      assert Ok(a) =
        bitwise.and(hex, 0xff)
        |> int.to_float()
        |> float.divide(255.0)
      from_rgba(r, g, b, a)
    }
  }
}

// ---------------------------------------------------------------

pub fn to_css_rgba_string(colour: Colour) -> String {
  let #(r, g, b, a) = to_rgba(colour)

  let percent = fn(x: Float) -> Float {
    // This won't fail because we are always dividing by 100.0
    assert Ok(p) =
      x
      |> float.multiply(10_000.0)
      |> float.round()
      |> int.to_float()
      |> float.divide(100.0)

    p
  }

  let round_to = fn(x: Float) -> Float {
    // This won't fail because we are always dividing by 1000.0
    assert Ok(r) =
      x
      |> float.multiply(1000.0)
      |> float.round()
      |> int.to_float()
      |> float.divide(1000.0)

    r
  }

  string.join(
    [
      "rgba(",
      float.to_string(percent(r)) <> "%,",
      float.to_string(percent(g)) <> "%,",
      float.to_string(percent(b)) <> "%,",
      float.to_string(round_to(a)),
      ")",
    ],
    "",
  )
}

// CONVERSIONS ----------------------------------------------------------------

pub fn to_rgba(colour: Colour) -> #(Float, Float, Float, Float) {
  case colour {
    Rgba(r, g, b, a) -> #(r, g, b, a)
    Hsla(h, s, l, a) -> hsla_to_rgba(h, s, l, a)
  }
}

pub fn to_hsla(colour: Colour) -> #(Float, Float, Float, Float) {
  case colour {
    Hsla(h, s, l, a) -> #(h, s, l, a)
    Rgba(r, g, b, a) -> rgba_to_hsla(r, g, b, a)
  }
}

// COLOURS --------------------------------------------------------------------

/// (239, 41, 41, 1.0)
pub const light_red = Rgba(
  r: 0.9372549019607843,
  g: 0.1607843137254902,
  b: 0.1607843137254902,
  a: 1.0,
)

/// (204, 0, 0, 1.0)
pub const red = Rgba(r: 0.8, g: 0.0, b: 0.0, a: 1.0)

/// (164, 0, 0, 1.0)
pub const dark_red = Rgba(r: 0.6431372549019608, g: 0.0, b: 0.0, a: 1.0)

/// (252, 175, 62, 1.0)
pub const light_orange = Rgba(
  r: 0.9882352941176471,
  g: 0.6862745098039216,
  b: 0.24313725490196078,
  a: 1.0,
)

/// (245, 121, 0, 1.0)
pub const orange = Rgba(
  r: 0.9607843137254902,
  g: 0.4745098039215686,
  b: 0.0,
  a: 1.0,
)

/// (206, 92, 0, 1.0)
pub const dark_orange = Rgba(
  r: 0.807843137254902,
  g: 0.3607843137254902,
  b: 0.0,
  a: 1.0,
)

/// (255, 233, 79, 1.0)
pub const light_yellow = Rgba(
  r: 1.0,
  g: 0.9137254901960784,
  b: 0.30980392156862746,
  a: 1.0,
)

/// (237, 212, 0, 1.0)
pub const yellow = Rgba(
  r: 0.9294117647058824,
  g: 0.8313725490196079,
  b: 0.0,
  a: 1.0,
)

/// (196, 160, 0, 1.0)
pub const dark_yellow = Rgba(
  r: 0.7686274509803922,
  g: 0.6274509803921569,
  b: 0.0,
  a: 1.0,
)

/// (138, 226, 52, 1.0)
pub const light_green = Rgba(
  r: 0.5411764705882353,
  g: 0.8862745098039215,
  b: 0.20392156862745098,
  a: 1.0,
)

/// (115, 210, 22, 1.0)
pub const green = Rgba(
  r: 0.45098039215686275,
  g: 0.8235294117647058,
  b: 0.08627450980392157,
  a: 1.0,
)

/// (78, 154, 6, 1.0)
pub const dark_green = Rgba(
  r: 0.3058823529411765,
  g: 0.6039215686274509,
  b: 0.023529411764705882,
  a: 1.0,
)

/// (114, 159, 207, 1.0)
pub const light_blue = Rgba(
  r: 0.4470588235294118,
  g: 0.6235294117647059,
  b: 0.8117647058823529,
  a: 1.0,
)

/// (52, 101, 164, 1.0)
pub const blue = Rgba(
  r: 0.20392156862745098,
  g: 0.396078431372549,
  b: 0.6431372549019608,
  a: 1.0,
)

/// (32, 74, 135, 1.0)
pub const dark_blue = Rgba(
  r: 0.12549019607843137,
  g: 0.2901960784313726,
  b: 0.5294117647058824,
  a: 1.0,
)

/// (173, 127, 168, 1.0)
pub const light_purple = Rgba(
  r: 0.6784313725490196,
  g: 0.4980392156862745,
  b: 0.6588235294117647,
  a: 1.0,
)

/// (117, 80, 123, 1.0)
pub const purple = Rgba(
  r: 0.4588235294117647,
  g: 0.3137254901960784,
  b: 0.4823529411764706,
  a: 1.0,
)

/// (92, 53, 102, 1.0)
pub const dark_purple = Rgba(
  r: 0.3607843137254902,
  g: 0.20784313725490197,
  b: 0.4,
  a: 1.0,
)

/// (233, 185, 110, 1.0)
pub const light_brown = Rgba(
  r: 0.9137254901960784,
  g: 0.7254901960784313,
  b: 0.43137254901960786,
  a: 1.0,
)

/// (193, 125, 17, 1.0)
pub const brown = Rgba(
  r: 0.7568627450980392,
  g: 0.49019607843137253,
  b: 0.06666666666666667,
  a: 1.0,
)

/// (143, 89, 2, 1.0)
pub const dark_brown = Rgba(
  r: 0.5607843137254902,
  g: 0.34901960784313724,
  b: 0.00784313725490196,
  a: 1.0,
)

/// (0, 0, 0, 1.0)
pub const black = Rgba(r: 0.0, g: 0.0, b: 0.0, a: 1.0)

/// (255, 255, 255, 1.0)
pub const white = Rgba(r: 1.0, g: 1.0, b: 1.0, a: 1.0)

/// (238, 238, 236, 1.0)
pub const light_grey = Rgba(
  r: 0.9333333333333333,
  g: 0.9333333333333333,
  b: 0.9254901960784314,
  a: 1.0,
)

/// (211, 215, 207, 1.0)
pub const grey = Rgba(
  r: 0.8274509803921568,
  g: 0.8431372549019608,
  b: 0.8117647058823529,
  a: 1.0,
)

/// (186, 189, 182, 1.0)
pub const dark_grey = Rgba(
  r: 0.7294117647058823,
  g: 0.7411764705882353,
  b: 0.7137254901960784,
  a: 1.0,
)

/// (238, 238, 236, 1.0)
pub const light_gray = Rgba(
  r: 0.9333333333333333,
  g: 0.9333333333333333,
  b: 0.9254901960784314,
  a: 1.0,
)

/// (211, 215, 207, 1.0)
pub const gray = Rgba(
  r: 0.8274509803921568,
  g: 0.8431372549019608,
  b: 0.8117647058823529,
  a: 1.0,
)

/// (186, 189, 182, 1.0)
pub const dark_gray = Rgba(
  r: 0.7294117647058823,
  g: 0.7411764705882353,
  b: 0.7137254901960784,
  a: 1.0,
)

/// (136, 138, 133, 1.0)
pub const light_charcoal = Rgba(
  r: 0.5333333333333333,
  g: 0.5411764705882353,
  b: 0.5215686274509804,
  a: 1.0,
)

/// (85, 87, 83, 1.0)
pub const charcoal = Rgba(
  r: 0.3333333333333333,
  g: 0.3411764705882353,
  b: 0.3254901960784314,
  a: 1.0,
)

/// (46, 52, 54, 1.0)
pub const dark_charcoal = Rgba(
  r: 0.1803921568627451,
  g: 0.20392156862745098,
  b: 0.21176470588235294,
  a: 1.0,
)

/// (255, 175, 243, 1.0)
pub const pink = Rgba(
  r: 1.0,
  g: 0.6862745098039216,
  b: 0.9529411764705882,
  a: 1.0,
)
