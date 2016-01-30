part of stagexl_gaf.utils;

class ByteBufferReader {

  ByteData _data;
  Endianness endian = Endianness.LITTLE_ENDIAN;
  int position = 0;

  ByteBufferReader(ByteBuffer bytes) : _data = new ByteData.view(bytes);

  int get length => _data.lengthInBytes;

  //---------------------------------------------------------------------------

  int readInt() {
    var value = _data.getInt32(position, this.endian);
    position += 4;
    return value;
  }

  int readByte() {
    var value = _data.getUint8(position);
    position += 1;
    return value;
  }

  int readUnsignedInt() {
    var value = _data.getUint32(position, this.endian);
    position += 4;
    return value;
  }

  int readShort() {
    var value = _data.getInt16(position, this.endian);
    position += 2;
    return value;
  }

  double readFloat() {
    var value = _data.getFloat32(position, this.endian);
    position += 4;
    return value;
  }

  bool readbool() {
    var value = _data.getInt8(position);
    position += 1;
    return value != 0;
  }

  String readUTF() {
    var length = _data.getUint16(position, this.endian);
    var string = new Uint8List.view(_data.buffer, position + 2, length);
    position = position + 2 + length;
    return UTF8.decode(string);
  }

  Uint8List readBytes(int length) {
    var value = new Uint8List.view(_data.buffer, position, length);
    position += length;
    return value;
  }

  int readUnsignedShort() {
    var value = _data.getUint16(position, this.endian);
    position += 2;
    return value;
  }

}
