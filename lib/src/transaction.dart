import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'address.dart';

class ByteReader {
  Uint8List data;
  int currentPos;
  ByteReader(this.data):
    currentPos = 0;

  Uint8List read(int len, {reverse = false}) {
    var ret = data.sublist(currentPos, currentPos + len);
    currentPos += len;
    if(reverse) {
      return Uint8List.fromList(ret.reversed.toList());
    } else {
      return ret;
    }
  }

  BigInt readAsInt(int len) {
    var i = read(len, reverse: true);
    return BigInt.parse(hex.encode(i), radix: 16);
  }

  bool get hasReadToEnd => currentPos == data.length;
}

class ByteWriter {
  List<int> data;
  ByteWriter(): data = [];

  void write(Uint8List inputs, {reverse = false}) {
    if(reverse) {
      data.addAll(inputs.reversed);
    } else {
      data.addAll(inputs);
    }
  }

  void writeInt(dynamic val, int len) {
    String hexStr;
    if(val is BigInt) {
      hexStr = val.toRadixString(16);
    } else {
      hexStr = (val as int).toRadixString(16);
    }
    if(hexStr.length.isOdd) {
      hexStr = '0' + hexStr;
    }

    List<int> bytes = [];
    bytes.addAll(hex.decode(hexStr).reversed);
    if(bytes.length > len) {
      throw Exception('Integer value overflow');
    }

    for(var i = len - bytes.length - 1; i >= 0; i--) {
      bytes.add(0);
    }

    data.addAll(bytes);
  }

  Uint8List get packedData => Uint8List.fromList(data);
}

class BitcoinInput {
  Uint8List prevOutHash;
  int prevOutIndex;
  Uint8List script;
  int sequence;

  BitcoinInput.fromBinary(ByteReader reader) {
    prevOutHash = reader.read(32, reverse: true);
    prevOutIndex = reader.readAsInt(4).toInt();
    var scriptLen = reader.readAsInt(1).toInt();
    script = reader.read(scriptLen);
    sequence = reader.readAsInt(4).toInt();
  }

  void setScript(Uint8List s) {
    script = s;
  }

  void clearScript() {
    script = Uint8List.fromList([]);
  }

  void toBinary(ByteWriter writer) {
    writer.write(prevOutHash, reverse: true);
    writer.writeInt(prevOutIndex, 4);
    writer.writeInt(script.length, 1);
    writer.write(script);
    writer.writeInt(sequence, 4);
  }

  Map<String, dynamic> toJson() => {
    'prevOutHash': '0x' + hex.encode(prevOutHash),
    'prevOutIndex': prevOutIndex,
    'script': hex.encode(script),
    'sequence': sequence
  };
}

class BitcoinOutput {
  Uint8List script;
  BigInt value;

  BitcoinOutput.fromBinary(ByteReader reader) {
    value = reader.readAsInt(8);
    var b_len = reader.readAsInt(1).toInt();
    script = reader.read(b_len);
  }

  void toBinary(ByteWriter writer) {
    writer.writeInt(value, 8);
    writer.writeInt(script.length, 1);
    writer.write(script);
  }

  Map<String, dynamic> toJson() => {
    'script': hex.encode(script),
    'value': value.isValidInt ? value.toInt():value.toString()
  };

  String getAddress([String net= 'main']) => scriptToAddress(script, testNet: net != 'main');
}

class BitcoinTransaction {
  int version;
  List<BitcoinInput> inputs;
  List<BitcoinOutput> outputs;
  int lockTime;

  BitcoinTransaction.fromBinary(Uint8List data) {
    var reader = ByteReader(data);
    version = reader.readAsInt(4).toInt();
    inputs = new List();
    var inputLen = reader.readAsInt(1).toInt();
    for(var i = 0; i < inputLen; i++) {
      inputs.add(BitcoinInput.fromBinary(reader));
    }

    outputs = new List();
    var outputLen = reader.readAsInt(1).toInt();
    for(var i = 0; i < outputLen; i++) {
      outputs.add(BitcoinOutput.fromBinary(reader));
    }

    lockTime = reader.readAsInt(4).toInt();

    if(!reader.hasReadToEnd) {
      throw Exception('Has unread bytes');
    }
  }

  Uint8List get rawData {
    var writer = ByteWriter();
    writer.writeInt(version, 4);
    writer.writeInt(inputs.length, 1);
    inputs.forEach((i) {
      i.toBinary(writer);
    });
    writer.writeInt(outputs.length, 1);
    outputs.forEach((i) {
      i.toBinary(writer);
    });
    writer.writeInt(lockTime, 4);
    return writer.packedData;
  }

  // add hash type 1 to end of data
  Uint8List get hashToSign => doubleSha256(Uint8List.fromList(rawData.toList() + [1, 0, 0, 0]));

  Uint8List getHash() {
    return doubleSha256(Uint8List.fromList(rawData.toList()));
  }

  String getId() {
    return hex.encode(getHash().reversed.toList());
  }

  List<Uint8List> getHashToSign(List<Uint8List> inputScripts) {
    List<Uint8List> ret = [];
    if(inputScripts.length != inputs.length) {
      throw Exception("unmatched input length and input script length");
    }

    inputs.forEach((element) {element.clearScript();});

    for(var i = 0; i < inputScripts.length; i++) {
      inputs[i].setScript(inputScripts[i]);
      ret.add(hashToSign);
      inputs[i].clearScript();
    }
    return ret;
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'inputs': inputs,
    'outputs': outputs,
    'lockTime': lockTime
  };
}