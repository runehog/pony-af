// External sample format: 32-bit float.
type OutBuffer is Array[F32]

// Internal sample format: 64-bit float.
type Buffer is Array[F64]

interface Producer
  fun ref produce(buf: Buffer)
