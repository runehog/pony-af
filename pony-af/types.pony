// External sample format: 32-bit float.
type OutBuffer is Array[F32]

// Internal sample format: 64-bit float.
type Buffer is Array[F64]

interface Producer
  fun ref produce(buf: Buffer)

class val AudioSettings
  let frame_rate: F64
  let inverse_frame_rate: F64
  let frames_per_buffer: USize
  let buffer_count: USize

  new val create(frame_rate': F64,
                 frames_per_buffer': USize,
                 buffer_count': USize) =>
    frame_rate = frame_rate'
    inverse_frame_rate = 1.0 / frame_rate
    frames_per_buffer = frames_per_buffer'
    buffer_count = buffer_count'

  fun val create_buffer(): Buffer =>
    Buffer.init(0.0, frames_per_buffer)

  fun val create_silent_buffer(): Buffer =>
    Buffer.init(0.0, frames_per_buffer)
