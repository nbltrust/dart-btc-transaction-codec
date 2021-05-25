import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:bitcoin_codec/bitcoin_codec.dart';

// "inputs" : [
//     {
//         "_id" : ObjectId("60751c7511118f4b8034102d"),
//         "raw" : "{\"txid\":\"69580291ebd64dcc6ad143bd0b05271fc0494c800054f3bcb038c6bbace14c78\",\"n\":0,\"scriptPubKey\":\"76a914f7c70dad3c5d59d8f3f4a92cce47af4f34fa6acc88ac\"}",
//         "msgToSign" : "d976d72b418d888dbbfe9f9b1141b49c7edcdd632885c50e6c80b6656f49f97a",
//         "wallet" : "test1",
//         "senderAddress" : "n475eumKGX2Rv3FHgJheK6LcdBd4u9Qx4f",
//         "uid" : "69580291ebd64dcc6ad143bd0b05271fc0494c800054f3bcb038c6bbace14c78:0",
//         "originRawTx" : "02000000035f116aac31d9ae42a52bb94321546472bd4527998f88009c7a0e5d7edf55387b010000006a4730440220197445d303fe2fdd50f4595e8e7c098e03ada0d385cd274eacc1341c4a2ec0b7022025dcde4014e51a6dd8ce2ad87a5192d39b992c85ca187c73073605d7d3bd246f0121031f570a7f27f8ccb3cecbc99feb3070ec0614219e1e9b28c61ab5b365ec202e12ffffffffec3b82cd93014a49add7a6447fd823149af38709d71bfb8a6cc7b1d139848c4c000000006b483045022100e15720bb8305debe0d5e6a1ac6b3dda226822daf74a1e70f2758062e9881e69c02204ab8c0392a5bbb3dda95b122a0cd87dc41f81887e2282711f348dd6b508778d90121031f570a7f27f8ccb3cecbc99feb3070ec0614219e1e9b28c61ab5b365ec202e12ffffffffbc29350a8a77f327301c3806c7fe18fd4f91f6a88ae17754d0ba77e0d576a8f7000000006b483045022100a208b400acf2944c163d821581999145cdc4fc804d388cbcfe14b89be9ea774b02201b8a94c10203fcc8e746bf9664b5ca01f272722e5536ac9857376fda9cbd4ecf0121031f570a7f27f8ccb3cecbc99feb3070ec0614219e1e9b28c61ab5b365ec202e12ffffffff02f5415d05000000001976a914f7c70dad3c5d59d8f3f4a92cce47af4f34fa6acc88acffe09700000000001976a9148ef2404b8156d2d6bb54092586c6afc079dd025f88ac00000000",
//         "originIndex" : 0,
//         "algorithm" : "secp256k1"
//     }
// ],

void main() {
  var txid = '69580291ebd64dcc6ad143bd0b05271fc0494c800054f3bcb038c6bbace14c78';
  var originRawTx =
      '02000000035f116aac31d9ae42a52bb94321546472bd4527998f88009c7a0e5d7edf55387b010000006a4730440220197445d303fe2fdd50f4595e8e7c098e03ada0d385cd274eacc1341c4a2ec0b7022025dcde4014e51a6dd8ce2ad87a5192d39b992c85ca187c73073605d7d3bd246f0121031f570a7f27f8ccb3cecbc99feb3070ec0614219e1e9b28c61ab5b365ec202e12ffffffffec3b82cd93014a49add7a6447fd823149af38709d71bfb8a6cc7b1d139848c4c000000006b483045022100e15720bb8305debe0d5e6a1ac6b3dda226822daf74a1e70f2758062e9881e69c02204ab8c0392a5bbb3dda95b122a0cd87dc41f81887e2282711f348dd6b508778d90121031f570a7f27f8ccb3cecbc99feb3070ec0614219e1e9b28c61ab5b365ec202e12ffffffffbc29350a8a77f327301c3806c7fe18fd4f91f6a88ae17754d0ba77e0d576a8f7000000006b483045022100a208b400acf2944c163d821581999145cdc4fc804d388cbcfe14b89be9ea774b02201b8a94c10203fcc8e746bf9664b5ca01f272722e5536ac9857376fda9cbd4ecf0121031f570a7f27f8ccb3cecbc99feb3070ec0614219e1e9b28c61ab5b365ec202e12ffffffff02f5415d05000000001976a914f7c70dad3c5d59d8f3f4a92cce47af4f34fa6acc88acffe09700000000001976a9148ef2404b8156d2d6bb54092586c6afc079dd025f88ac00000000';
  var originIndex = 0;

  var trx = BitcoinTransaction.fromBinary(hex.decode(originRawTx));
  print(jsonEncode(trx));

  assert(trx.getId() == txid);

  var inputValue = trx.outputs[originIndex].value;
  print(inputValue);
  assert(getInputValue(originRawTx, originIndex, txid) == inputValue);
}

BigInt getInputValue(originRawTx, originIndex, txid) {
  var tx = BitcoinTransaction.fromBinary(hex.decode(originRawTx));
  if (tx.getId() == txid) {
    return tx.outputs[originIndex].value;
  } else {
    return BigInt.zero;
  }
}
