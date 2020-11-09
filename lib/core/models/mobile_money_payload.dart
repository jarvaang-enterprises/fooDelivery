import 'dart:convert';
import 'package:tripledes/tripledes.dart';
import 'package:crypto/crypto.dart' as crypto;

class MobileMoneyPayload {
  String PBFPubKey,
      currency,
      payment_type,
      country,
      amount,
      email,
      phonenumber,
      network,
      firstname,
      lastname,
      txRef,
      orderRef,
      is_mobile_money_ug,
      device_fingerprint,
      redirect_url;

  MobileMoneyPayload(
      {this.PBFPubKey,
      this.currency,
      this.payment_type,
      this.country,
      this.amount,
      this.email,
      this.phonenumber,
      this.network,
      this.firstname,
      this.lastname,
      this.txRef,
      this.orderRef,
      this.is_mobile_money_ug,
      this.device_fingerprint,
      this.redirect_url});

  Map<String, dynamic> toJson() => {
        'PBFPubKey': PBFPubKey,
        'currency': currency,
        'payment_type': payment_type,
        'country': country,
        'amount': amount,
        'email': email,
        'phonenumber': phonenumber,
        'network': network,
        'firstname': firstname,
        'lastname': lastname,
        'txRef': txRef,
        'orderRef': orderRef,
        'is_mobile_money_ug': is_mobile_money_ug,
        'device_fingerprint': device_fingerprint,
        'redirect_url': redirect_url,
      };

  Map<String, String> encryptJsonPayload(
      String encryptionKey, String publicKey) {
    String encoded = jsonEncode(this);
    String encrypted = getEncryptedData(encoded, encryptionKey);

    final encryptedPayload = {
      "PBFPubKey": publicKey,
      "client": encrypted,
      "alg": "3DES-24"
    };

    return encryptedPayload;
  }

  String generateMd5(String input) {
    var md5 = crypto.md5;
    return md5.convert(utf8.encode(input)).toString();
  }

  String getKey(String seckey) {
    var hashedkey = generateMd5(seckey);
    var hashedkeylast12 = hashedkey.substring(hashedkey.length - 12);

    var seckeyadjusted = seckey.replaceAll("FLWSECK_", "");
    var seckeyadjustedfirst12 = seckeyadjusted.substring(0, 12);

    var encryptionkey = seckeyadjustedfirst12 + hashedkeylast12;
    return encryptionkey;
  }

  String getEncryptedData(encoded, encryptionKey) {
    return encrypt(encryptionKey, encoded);
  }

  String encrypt(key, text) {
    var blockCipher = BlockCipher(TripleDESEngine(), key);
    var i = blockCipher.encodeB64(text);
    return i;
  }
}
