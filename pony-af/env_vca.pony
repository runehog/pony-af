use "collections"
use "promises"

primitive EnvAttack
primitive EnvDecay
primitive EnvSustain
primitive EnvRelease
primitive EnvDone
type EnvStage is (EnvAttack | EnvDecay | EnvSustain | EnvRelease | EnvDone)

class EnvVCA is Producer
  let _attack_delta: F64
  let _decay_level: F64
  let _decay_delta: F64
  let _sustain_level: F64
  let _release_delta: F64
  let _release_level: F64
  var _gain: F64
  var _stage: EnvStage
  let _producer: Producer
  let _done: (None | Promise[None])

  new create(audio_settings: AudioSettings,
             producer: Producer,
             initial_level: F64,
             attack_time: F64,
             decay_level: F64,
             decay_time: F64,
             sustain_level: F64,
             release_time: F64,
             release_level: F64,
             done: (None | Promise[None])) =>
    _attack_delta = (decay_level - initial_level) / (attack_time * audio_settings.frame_rate)
    _decay_level = decay_level
    _decay_delta = (sustain_level - decay_level) / (decay_time * audio_settings.frame_rate)
    _sustain_level = sustain_level
    _release_level = release_level
    _release_delta = (release_level - sustain_level) / (release_time * audio_settings.frame_rate)
    _gain = initial_level
    _stage = EnvAttack
    _producer = producer
    _done = done

  fun ref release() =>
    match _stage
    | EnvAttack =>
      _stage = EnvRelease
    | EnvDecay =>
      _stage = EnvRelease
    | EnvSustain =>
      _stage = EnvRelease
    end

  fun ref produce(buf: Buffer) =>
    // Pull buffer from input.
    _producer.produce(buf)

    // Apply envelope in place.
    try
      for i in Range[USize](0, buf.size()) do
        buf.update(i, buf(i) * _gain)
        match _stage
        | EnvAttack =>
          _gain = _gain + _attack_delta
          if ((_attack_delta > 0.0) and (_gain >= _decay_level)) or
             ((_attack_delta < 0.0) and (_gain <= _decay_level)) then
            _stage = EnvDecay
          end
        | EnvDecay =>
          _gain = _gain + _decay_delta
          if ((_decay_delta > 0.0) and (_gain >= _sustain_level)) or
             ((_decay_delta < 0.0) and (_gain <= _sustain_level)) then
            _stage = EnvSustain
          end
        | EnvSustain =>
          None
        | EnvRelease =>
          _gain = _gain + _release_delta
          if ((_release_delta > 0.0) and (_gain >= _release_level)) or
             ((_release_delta < 0.0) and (_gain <= _release_level)) then
            _stage = EnvDone
            match _done
            | let done: Promise[None] =>
              done(None)
            end
          end
        end
      end
    end
