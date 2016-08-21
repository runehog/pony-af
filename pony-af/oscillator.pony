use "collections"

class Oscillator is Producer
  var _phasor: F64
  var _phasor_inc: F64

  new create(freq: F64) =>
    _phasor = 0
    _phasor_inc = freq / 44100.0

  fun ref produce(buf: Buffer) =>
    for i in Range[USize](0, buf.size()) do
      try
        buf.update(i, _phasor)
      end
      _phasor = _phasor + _phasor_inc
      if _phasor >= 0.5 then
        _phasor = _phasor - 1.0
      end
    end
