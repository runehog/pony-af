use "collections"
use "debug"

class SineOsc is Producer
  let two_pi: F64 = F64.pi() * 2.0

  let _as: AudioSettings
  let _freq: F64
  let _freq_buffer: Buffer
  let _scale: F64
  let _freq_mod: Producer
  var _phasor: F64

  new create(audio_settings: AudioSettings,
             freq: F64,
             scale: F64 = 1.0,
             freq_mod: Producer = ConstantValue(0.0)) =>
    _as = audio_settings
    _freq = freq
    _scale = scale
    _freq_mod = freq_mod
    _freq_buffer = _as.create_buffer()
    _phasor = 0.0

  fun ref produce(buf: Buffer) =>
    _freq_mod.produce(_freq_buffer)

    try
      for i in Range[USize](0, buf.size()) do
        buf.update(i, _scale * _phasor.sin())
        // Calculate instantaneous frequency at this frame, convert to phase
        // delta, and apply offset to _phasor.
        let d_phase = ((_freq + _freq_buffer(i)) * two_pi) * _as.inverse_frame_rate
        _phasor = _phasor + d_phase
        // ...with wraparound at 2 * pi.
        if _phasor >= two_pi then
          _phasor = _phasor - two_pi
        end
      end
    end
