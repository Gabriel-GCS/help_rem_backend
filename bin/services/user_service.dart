import 'dart:convert';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:password_dart/password_dart.dart';
import '../security/security_service_imp.dart';
import '../security/token_jwt.dart';

class UserService {
  final SecurityService _securityService = SecurityService();
  final JWTService _jwtService = JWTService();
  late DbCollection _collection;

  UserService() {
    _init();
  }

  void _init() async {
    try {
      dotenv.load();

      final mongodbUri = dotenv.env['MONGODB_URI'];

      var db = await Db.create('$mongodbUri');
      await db.open();
      _collection = db.collection('users');
    } catch (e) {
      print(e);
    }
  }
  
  // -------------  USER  ----------------

  Future create(Request req) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final userFound = await _collection.findOne({'email' : json['email']});

      if(userFound != null){
        return 1;
      }
      
      final hash = Password.hash(json['password']!, PBKDF2());
      json['password'] = hash;

      await _collection.insertOne(json);

      final pipeline = [
        {
          '\$match': {'email': json['email']}
        },
        {
          '\$project': {
            'name': 1,
            'email': 1,
            'idade': 1
          }
        }
      ];

      final userCreate = await _collection.aggregateToStream(pipeline).toList();
      return userCreate;
    } catch (e) {
      print(e);
    }
  }

  Future login(Request req) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final user = await _collection.findOne({'email': json['email']});

      if (user != null && Password.verify(json['password'], user['password'])) {
        var jwt = await _securityService.generateJWT(user['_id'].toString());
        return jsonEncode({'nome': user['name'],'email': user['email'],'token': jwt});
      }
    } catch (e) {
      print(e);
    }
  }

  Future getAllUsers() async {
    try {
      final users = await _collection.find().toList();

      return users;
    } catch (e) {
      print(e);
    }
  }

  Future update(Request req) async {
    try {
      var result = await req.readAsString();
      final user = await _jwtService.verifyJWT(req);
      Map<String, dynamic> json = jsonDecode(result);
      var users = await _collection.findOne(where.eq("_id", user));
      if (json['nome']) users?['nome'] = json['nome'];
      if (json['email']) users?['email'] = json['email'];
      if (json['idade']) users?['idade'] = json['idade'];

      return users;
    } catch (e) {
      print(e);
    }
  }

  Future delete(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      await _collection.remove(where.eq("_id", user));
    } catch (e) {
      print(e);
    }
  }

  // -------------  ENTES QUERIDOS  ----------------

  Future createFriend(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final friend = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': user
      }, {
        '\$addToSet': {"entes_queridos": friend}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future getAllFriends(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final pipeline = [
        {
          '\$match': {'_id': user}
        },
        {
          '\$project': {
            'entes_queridos': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      return result;
    } catch (e) {
      print(e);
    }
  }

  Future updateFriend(Request req, String friend) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final obId = 'ObjectId("$friend")';
      await _collection.updateMany({
        'entes_queridos.id': obId
      }, {
        '\$push': {"entes_queridos.\$.data": json}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future deleteFriend(String friend) async {
    try {
      final obId = 'ObjectId("$friend")';
      await _collection.updateMany({
        'entes_queridos.id': obId
      }, {
        '\$unset': {"entes_queridos.\$": ""}
      });
    } catch (e) {
      print(e);
    }
  }

  // -------------  REMEDIOS  ----------------

  Future createRemedy(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final remedio = {'id': customId, 'data': json};
      print(user);
      await _collection.updateOne({
        '_id': user
      }, {
        '\$addToSet': {"remedios": remedio}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future getAllRemedy(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final pipeline = [
        {
          '\$match': {'_id': user}
        },
        {
          '\$project': {
            'remedios': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      return result;

    } catch (e) {
      print(e);
    }
  }

   Future testjwt(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);

      final pipeline = [
        {
          '\$match': {'_id': user}
        },
        {
          '\$project': {
            'remedios': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      return result;

    } catch (e) {
      print(e);
    }
  }

  Future updateRemedy(Request req, String remedy) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final obId = 'ObjectId("$remedy")';
      await _collection.updateMany({
        'remedios.id': obId
      }, {
        '\$set': {"remedios.\$.data": json}
      });
      
      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future deleteRemedy(String remedy) async {
    try {
      final obId = 'ObjectId("$remedy")';
      await _collection.updateMany({
        'remedios.id': obId
      }, {
        '\$unset': {"remedios.\$": ""}
      });
    } catch (e) {
      print(e);
    }
  }

  // -------------  DIARIOS  ----------------

  Future createDaily(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final diario = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': user
      }, {
        '\$addToSet': {"diarios": diario}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future getAllDaily(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final pipeline = [
        {
          '\$match': {'_id': user}
        },
        {
          '\$project': {
            'diarios': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      return result;

    } catch (e) {
      print(e);
    }
  }

  Future updateDaily(Request req, String diary) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final obId = 'ObjectId("$diary")';
      await _collection.updateMany({
        'diarios.id': obId
      }, {
        '\$set': {"diarios.\$.data": json}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future deleteDaily(String diary) async {
    try {
      final obId = 'ObjectId("$diary")';
      await _collection.updateMany({
        'diarios.id': obId
      }, {
        '\$unset': {"diarios.\$": ""}
      });
    } catch (e) {
      print(e);
    }
  }

  // -------------  ATIVIDADES FISICAS  ----------------

  Future createActivity(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final atividade = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': user
      }, {
        '\$addToSet': {"atividades_fisicas": atividade}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future getAllActivity(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final pipeline = [
        {
          '\$match': {'_id': user}
        },
        {
          '\$project': {
            'atividades_fisicas': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      return result;

    } catch (e) {
      print(e);
    }
  }

  Future updateActivity(Request req, String activity) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final obId = 'ObjectId("$activity")';
      await _collection.updateMany({
        'atividades_fisicas.id': obId
      }, {
        '\$set': {"atividades_fisicas.\$.data": json}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future deleteActivity(String activity) async {
    try {
      final obId = 'ObjectId("$activity")';
      await _collection.updateMany({
        'atividades_fisicas.id': obId
      }, {
        '\$unset': {"atividades_fisicas.\$": ""}
      });
    } catch (e) {
      print(e);
    }
  }

  // -------------  ALIMENTACAO  ----------------

  Future createFood(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final alimento = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': user
      }, {
        '\$addToSet': {"alimentacao": alimento}
      });

      return 'ok';

    } catch (e) {
      print(e);
    }
  }

  Future getAllFood(Request req) async {
    try {
      final user = await _jwtService.verifyJWT(req);
      final pipeline = [
        {
          '\$match': {'_id': user}
        },
        {
          '\$project': {
            'alimentacao': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      return result;

    } catch (e) {
      print(e);
    }
  }

  Future updateFood(Request req, String food) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final obId = 'ObjectId("$food")';
      await _collection.updateMany({
        'alimentacao.id': obId
      }, {
        '\$set': {"alimentacao.\$.data": json}
      });

      return 'ok';
      
    } catch (e) {
      print(e);
    }
  }

  Future deleteFood(String food) async {
    try {
      final obId = 'ObjectId("$food")';
      await _collection.updateMany({
        'alimentacao.id': obId
      }, {
        '\$unset': {"alimentacao.\$": ""}
      });
    } catch (e) {
      print(e);
    }
  }

  // -------------  ALARMES  ----------------
}
