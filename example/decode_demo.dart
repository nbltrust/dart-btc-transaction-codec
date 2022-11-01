import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:bitcoin_codec/bitcoin_codec.dart';

// usage:
// dart decode_demo.dart trx_hex input_script_hex1 input_script_hex2 ...
void main(List<String> args) async{
  var trx_bytes = args[0];

  List<Uint8List> inputScripts = [];
  for(var i = 1; i < args.length; i++) {
    inputScripts.add(Uint8List.fromList(hex.decode(args[i])));
  }

  var trx = BitcoinTransaction.fromBinary(Uint8List.fromList(hex.decode(trx_bytes)));
  print(jsonEncode(trx));
  print(hex.encode(trx.rawData));

  var hashToSign = await trx.getHashToSign(inputScripts);
  print('Hash to sign: ');
  hashToSign.forEach((element) {
    print(hex.encode(element));
  });

  trx.outputs.forEach((out) {
    print(out.getAddress('test'));
    print(out.value.toInt());
  });
}