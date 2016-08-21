use "collections"

class MixerChannel
  let _buffers: Array[Buffer]
  var _read_index: USize
  var _write_index: USize
  var _producer: Producer

  new create(producer: Producer) =>
    _buffers = recover Array[Buffer] end
    _read_index = 0
    _write_index = 0
    _producer = producer

  fun ref adopt(audio_settings: AudioSettings) =>
    for i in Range[USize](0, audio_settings.buffer_count) do
      _buffers.push(recover
        audio_settings.create_silent_buffer()
      end)
    end
    try
      for i in Range[USize](0, audio_settings.buffer_count) do
        pull()
      end
    end

  fun ref next(): (None | Buffer) ? =>
    if _read_index == _write_index then
      None
    else
      let result =_buffers(_read_index)
      _read_index = _read_index + 1
      if _read_index == _buffers.size() then
        _read_index = 0
      end
      result
    end

  fun ref pull(): Bool ? =>
    // Figure out what the next buffer is, or if we're full.
    var next_write_index: USize = _write_index + 1
    if next_write_index == _buffers.size() then
      next_write_index = 0
    end
    if next_write_index == _read_index then
      return false
    end
    // Fill the next buffer.
    _producer.produce(_buffers(_write_index))
    _write_index = next_write_index
    true

class Mixer
  """A very basic pull-model audio mixer."""
  let _audio_settings: AudioSettings
  let _channels: Array[MixerChannel]
  let _mixbuf: Buffer
  var _channel_gain: F64

  new create(audio_settings: AudioSettings) =>
    _audio_settings = audio_settings
    _channels = Array[MixerChannel]
    _mixbuf = Buffer.init(0.0, _audio_settings.frames_per_buffer)
    _channel_gain = 1.0 / 16

  fun ref add_channel(channel: MixerChannel) =>
    channel.adopt(_audio_settings)
    _channels.push(channel)

  fun ref remove_channel(channel: MixerChannel) ? =>
    let i = _channels.find(channel)
    _channels.remove(i, 1)

  fun ref produce(buf: OutBuffer) =>
    try
      for i in Range[USize](0, _audio_settings.frames_per_buffer) do
        _mixbuf.update(i, 0.0)
      end
      for c in _channels.values() do
        match c.next()
        | let ch_buf: Buffer =>
          for i in Range[USize](0, _audio_settings.frames_per_buffer) do
            _mixbuf.update(i, _mixbuf(i) + ch_buf(i))
          end
        end
      end
      for i in Range[USize](0, _audio_settings.frames_per_buffer) do
        buf.update(i, Clipper.clip(_mixbuf(i) * _channel_gain).f32())
      end
    end

  fun ref pull() =>
    for c in _channels.values() do
      try
        let result = c.pull()
      end
    end
