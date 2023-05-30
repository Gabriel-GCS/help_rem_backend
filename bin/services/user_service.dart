import 'dart:convert';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../database.dart';



class UserService {
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

      await _collection.insertOne(json);
    } catch (e) {
      print(e);
    }
  }

  Future login(Request req) async {
    try {
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);

      final user = await _collection.findOne({'email': json['email']});

      if (user != null && user['password'] == json['password']){
        final jwtSecret = dotenv.env['jwtSecret'];
        final token = JwtDecoder.encode({'email': user['email'],'_id' : user['_id']}, jwtSecret);
        return token;
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

  Future update(Request req, String user) async {
    try {
      var result = await req.readAsString();
      var obId = ObjectId.parse(user);
      Map<String, dynamic> json = jsonDecode(result);
      var users = await _collection.findOne(where.eq("_id", obId));
      if (json['nome']) users?['nome'] = json['nome'];
      if (json['email']) users?['email'] = json['email'];
      if (json['idade']) users?['idade'] = json['idade'];
    } catch (e) {
      print(e);
    }
  }

  Future delete(String user) async {
    try {
      await _collection.remove(where.eq("_id", user));
    } catch (e) {
      print(e);
    }
  }

  // -------------  ENTES QUERIDOS  ----------------

  Future createFriend(Request req, String user) async {
    try {
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final friend = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': ObjectId.parse(user)
      }, {
        '\$addToSet': {"entes_queridos": friend}
      });
    } catch (e) {
      print(e);
    }
  }

  Future getAllFriends(String user) async {
    try {
      final pipeline = [
        {
          '\$match': {'_id': ObjectId.parse(user)}
        },
        {
          '\$project': {
            'entes_queridos': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      print(result);
      // var users = await _collection.find({'_id': ObjectId.parse(user)});
      // return users;
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

  Future createRemedy(Request req, String user) async {
    try {
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final remedio = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': ObjectId.parse(user)
      }, {
        '\$addToSet': {"remedios": remedio}
      });
    } catch (e) {
      print(e);
    }
  }

  Future getAllRemedy(String user) async {
    try {
      final pipeline = [
        {
          '\$match': {'_id': ObjectId.parse(user)}
        },
        {
          '\$project': {
            'remedios': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      print(result);
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

  Future createDaily(Request req, String user) async {
    try {
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final diario = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': ObjectId.parse(user)
      }, {
        '\$addToSet': {"diarios": diario}
      });
    } catch (e) {
      print(e);
    }
  }

  Future getAllDaily(String user) async {
    try {
      final pipeline = [
        {
          '\$match': {'_id': ObjectId.parse(user)}
        },
        {
          '\$project': {
            'diarios': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      print(result);
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

  Future createActivity(Request req, String user) async {
    try {
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final atividade = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': ObjectId.parse(user)
      }, {
        '\$addToSet': {"atividades_fisicas": atividade}
      });
    } catch (e) {
      print(e);
    }
  }

  Future getAllActivity(String user) async {
    try {
      final pipeline = [
        {
          '\$match': {'_id': ObjectId.parse(user)}
        },
        {
          '\$project': {
            'atividades_fisicas': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      print(result);
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

  Future createFood(Request req, String user) async {
    try {
      final customId = ObjectId().toString();
      var result = await req.readAsString();
      Map<String, dynamic> json = jsonDecode(result);
      final alimento = {'id': customId, 'data': json};
      await _collection.updateOne({
        '_id': ObjectId.parse(user)
      }, {
        '\$addToSet': {"alimentacao": alimento}
      });
    } catch (e) {
      print(e);
    }
  }

  Future getAllFood(String user) async {
    try {
      final pipeline = [
        {
          '\$match': {'_id': ObjectId.parse(user)}
        },
        {
          '\$project': {
            'alimentacao': 1, // Include the specific field
          }
        }
      ];

      final result = await _collection.aggregateToStream(pipeline).toList();

      print(result);
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
