primitive Clipper
  fun clip(value: F64): F64 =>
    if value < -1.0 then
      -1.0
    elseif value > 1.0 then
      1.0
    else
      value
    end
