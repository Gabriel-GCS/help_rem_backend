import 'package:shelf/shelf.dart';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class SecurityService {

  Future<String> generateJWT(String userID) async {
    dotenv.load();
    var jwt = JWT({
      'iat': DateTime.now().millisecondsSinceEpoch,
      'userID': userID
    });
    final key = dotenv.env['JWT_SECRET'];
    String token = jwt.sign(SecretKey('$key'));
    return token;
  }

  Future<JWT?> validateJWT(String token) async {
    dotenv.load();

    final key = dotenv.env['JWT_SECRET'];

    try {
      return JWT.verify(token, SecretKey('$key'));
    } catch (e) {
      return null;
    }
  }

  Middleware get authorization {
    return (Handler handler) {
      return (Request req) async {
        String? authorizationHeader = req.headers['Authorization'];

        JWT? jwt;

        if (authorizationHeader != null) {
          if (authorizationHeader.startsWith('Bearer ')) {
            String token = authorizationHeader.substring(7);
            jwt = await validateJWT(token);
          }
        }
        var request = req.change(context: {'jwt': jwt});
        return handler(request);
      };
    };
  }

  Middleware get verifyJwt => createMiddleware(
        requestHandler: (Request req) {
          if (req.context['jwt'] == null) {
            return Response.forbidden('Not Authorized');
          }
          return null;
        },
      );
}
