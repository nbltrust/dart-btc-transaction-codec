import 'package:bitcoin_trx_codec/bitcoin_trx_codec.dart';
import 'package:convert/convert.dart';

void main() {
  // testnet p2pkh
  var script1 = '76a91456abf7e4fed2a3b58e7b1237ae49af84ebac33f188ac';
  print(scriptToAddress(hex.decode(script1), testNet: true));

  // testnet segwit
  var script2 = '001478867c4b14db1d2dec33c90e5ecf49d772ba1b6f';
  print(scriptToAddress(hex.decode(script2), testNet: true));

  // testnet p2sh
  var script3 = 'a9148f55563b9a19f321c211e9b9f38cdf686ea0784587';
  print(scriptToAddress(hex.decode(script3), testNet: true));
}