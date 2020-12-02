import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:bs58/bs58.dart' show base58;
import 'package:hash/hash.dart';

import 'opcodes.dart';
import 'segwit_addr.dart' as segwit;

Uint8List doubleSha256(Uint8List input) {
  final sink = sha256.newSink();
  sink.add(input.toList());
  sink.close();
  final hash = sink.hash;
  final sink2 = sha256.newSink();
  sink2.add(hash.bytes);
  sink2.close();
  final hash2 = sink2.hash;
  return Uint8List.fromList(hash2.bytes);
}

String base58CheckEncode(Uint8List data, {int addressType = 0}) {
  var payload = [addressType] + data;
  var checksum = doubleSha256(Uint8List.fromList(payload)).sublist(0, 4);
  return base58.encode(Uint8List.fromList(payload + checksum));
}

String scriptToAddress(Uint8List outScript, {bool testNet: false}) {
  var opCode0 = outScript[0];
  if(opCode0 == OP_DUP) {
    var opCode1 = outScript[1];
    if(opCode1 != OP_HASH160) {
      throw Exception("unsupported address format");
    }
    var dataToPush = outScript[2];
    var addrHash = outScript.sublist(3, 3 + dataToPush);
    var opCode2 = outScript[3 + dataToPush];
    if(opCode2 != OP_EQUALVERIFY) {
      throw Exception("unsupported address format");
    }
    var opCode3 = outScript[4 + dataToPush];
    if(opCode3 != OP_CHECKSIG) {
      throw Exception("unsupported address format");
    }

    return base58CheckEncode(addrHash, addressType: testNet ? 0x6f : 0x00);
  } else if(opCode0 == OP_ZERO) {
    var dataToPush = outScript[1];
    var addrHash = outScript.sublist(2, 2 + dataToPush);
    return segwit.encode(testNet? 'tb': 'bc', 0, addrHash);
  } else if(opCode0 == OP_HASH160) {
    var dataToPush = outScript[1];
    var addrHash = outScript.sublist(2, 2 + dataToPush);
    var opCode1 = outScript[2 + dataToPush];
    if(opCode1 != OP_EQUAL) {
      throw Exception("unsupported address format");
    }
    return base58CheckEncode(addrHash, addressType: testNet ? 0xc4 : 0x05);
  } else {
    throw Exception("unsupported address format");
  }
}

String publicKeyToAddress(String hexX, String hexY, {bool testNet: false, bool compressed: true}) {
  var plainKey;
  if(!compressed) {
    plainKey = [0x4] + hex.decode(hexX) + hex.decode(hexY);
  } else {
    plainKey = [0x2] + hex.decode(hexX);
  }
  final sink = sha256.newSink();
  sink.add(plainKey);
  sink.close();
  final hash = sink.hash;
  var sha160 = RIPEMD160().update(hash.bytes).digest();
  return base58CheckEncode(sha160, addressType: testNet ? 0x6f : 0x00);
}