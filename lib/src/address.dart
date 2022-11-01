import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:cryptography/cryptography.dart';
import 'package:bs58/bs58.dart' show base58;
import 'package:hash/hash.dart';

import 'opcodes.dart';
import 'segwit_addr.dart' as segwit;

Future doubleSha256(Uint8List input) async{
  final sink = Sha256().newHashSink();
  sink.add(input.toList());
  sink.close();
  final hash = await sink.hash();
  final sink2 = Sha256().newHashSink();
  sink2.add(hash.bytes);
  sink2.close();
  final hash2 = await sink2.hash();
  return Uint8List.fromList(hash2.bytes);
}

Future<String> base58CheckEncode(Uint8List data, {int addressType = 0}) async{
  var payload = [addressType] + data;
  var checksum = await doubleSha256(Uint8List.fromList(payload));
  return base58.encode(Uint8List.fromList(payload + checksum.sublist(0, 4)));
}

Future<String> scriptToAddress(Uint8List outScript, {bool testNet: false}) async{
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

    return await base58CheckEncode(addrHash, addressType: testNet ? 0x6f : 0x00);
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
    return await base58CheckEncode(addrHash, addressType: testNet ? 0xc4 : 0x05);
  } else {
    throw Exception("unsupported address format");
  }
}

Future<String> publicKeyToAddress(String hexX, String hexY, {bool testNet: false, bool compressed: true}) async{
  var plainKey;
  if(!compressed) {
    plainKey = [0x4] + hex.decode(hexX) + hex.decode(hexY);
  } else {
    plainKey = [BigInt.parse(hexY, radix: 16) & BigInt.from(1) == BigInt.zero ? 0x2 : 0x03] + hex.decode(hexX);
  }
  final sink = Sha256().newHashSink();
  sink.add(plainKey);
  sink.close();
  final hash = await sink.hash();
  var sha160 = RIPEMD160().update(hash.bytes).digest();
  return await base58CheckEncode(sha160, addressType: testNet ? 0x6f : 0x00);
}