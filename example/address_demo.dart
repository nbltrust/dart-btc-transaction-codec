import 'dart:typed_data';

import 'package:bitcoin_codec/bitcoin_codec.dart';
import 'package:convert/convert.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() async{

test("testnet p2pkh", () async{
  var script1 = '76a91456abf7e4fed2a3b58e7b1237ae49af84ebac33f188ac';
  final address = await scriptToAddress(Uint8List.fromList(hex.decode(script1)), testNet: true);
  expect(address, "moRER7yQ3CbtNcWoT2fqvjzaWX9hd6j1zD");
});

test("testnet segwit", () async{
  var script2 = '001478867c4b14db1d2dec33c90e5ecf49d772ba1b6f';
  final address = await scriptToAddress(Uint8List.fromList(hex.decode(script2)),testNet: true);
  expect(address, "tb1q0zr8cjc5mvwjmmpney89an6f6aet5xm052j3mp");
});


test("testnet p2sh", () async{
  var script3 = 'a9148f55563b9a19f321c211e9b9f38cdf686ea0784587';
  final address = await scriptToAddress(Uint8List.fromList(hex.decode(script3)), testNet: true);
      expect(address, "2N6K6r2LEitDWRtYY2reSLcSQm2e2W9xEjB");
});


test("testnet pubkey to address", () async{
  var hexX = 'a4f1c4eab7bd4023f49daf8f8409111febde636e5c4631d036f220c830c0544e';
  var hexY = 'c7fc4c9e07979d151c47941cc20eb6a880aaabe83c7567f5b00743c11f2f2e36';
  final address = await publicKeyToAddress(hexX, hexY, testNet: true, compressed: false);
  expect(address, "n3WzzDxiGbtoJo7mp8A4g7cHoTat8ktaWS");
});

  //

test("testnet pubkey to address 2 compressed", () async{
  var hexX2 = '2c24a9c7b1391263af3b62673b611f2c85799c87fcdb6b99756491521cd53463';
  var hexY2 = 'f6a563e6e51623a7c7c779d49dfbab5d82e8552563cf538a8a298af17332f859';
  final address = await publicKeyToAddress(hexX2, hexY2, testNet: true, compressed: true);
  expect(address, "mn8m4vUtmJKr9dE6VEPHCAGLPPeQroKUuk");
});

}