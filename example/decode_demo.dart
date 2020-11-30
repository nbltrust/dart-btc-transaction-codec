import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:bitcoin_codec/bitcoin_codec.dart';

void main(List<String> args) {
  var trx_bytes = args[0];

  var trx = BitcoinTransaction.fromBinary(hex.decode(trx_bytes));
  print(jsonEncode(trx));
  print(hex.encode(trx.rawData));
  print(hex.encode(trx.hashToSign));
  trx.outputs.forEach((out) {
    print(out.getAddress('test'));
    print(out.value.toInt());
  });
}