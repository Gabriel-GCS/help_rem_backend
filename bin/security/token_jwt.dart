import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JWTService {
  Future<String> generateJWT(String userID) async {
    dotenv.load();
    var jwt =
        JWT({'iat': DateTime.now().millisecondsSinceEpoch, 'userID': userID});
    final key = dotenv.env['JWT_SECRET'];
    String token = jwt.sign(SecretKey('$key'));
    return token;
  }

  Future validateJWT(String token) async {
    dotenv.load();

    final key = dotenv.env['JWT_SECRET'];
    try {
      return JWT.verify(token, SecretKey('$key'));
    } on JWTInvalidException {
      return null;
    } on JWTExpiredException {
      return null;
    } on JWTNotActiveException {
      return null;
    } on JWTUndefinedException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future verifyJWT(Request req) async {
    String? authorizationHeader = req.headers['Authorization'];
    JWT? jwt;

    if (authorizationHeader != null) {
      if (authorizationHeader.startsWith('Bearer ')) {
        String token = authorizationHeader.substring(7);
        jwt = await validateJWT(token);
      }
    }
    final id = ObjectId.parse(jwt?.payload['userID'].substring(10, 34));
    final ObjectId result = id;
    return result;
  }
}
