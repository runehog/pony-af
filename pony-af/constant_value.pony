use "collections"
use "debug"

class ConstantValue is Producer
  let _v: F64

  new create(v: F64) =>
    _v = v

  fun ref produce(buf: Buffer) =>
    try
      for i in Range[USize](0, buf.size()) do
        buf.update(i, _v)
      end
    end
