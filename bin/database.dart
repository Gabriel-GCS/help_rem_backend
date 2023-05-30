import 'package:mongo_dart/mongo_dart.dart';

class MongoDatabase {
  static connect() async {
    var db = await Db.create(
        "mongodb+srv://GabrielTeste:helpRTeste@help-remember.rjh4fbt.mongodb.net/help-remember");
    await db.open();

    var userCollection = db.collection('users');
  }
}
