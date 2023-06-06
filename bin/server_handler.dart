import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'services/user_service.dart';

class ServeHandler {
  final UserService _userService = UserService();

  Handler get handler {
    final router = Router();

    // -------------  USER  ----------------

    router.post('/create', (Request req) async {
      final createUser = await _userService.create(req);
      if (createUser == 1) {
        return Response(409, body: 'Email already exists');
      }
      return Response.ok(jsonEncode(createUser));
    });

    router.post('/login', (Request req) async {
      final login = await _userService.login(req);
      return Response.ok(login);
    });

    router.put('/update/<user>', (Request req, String user) async {
      final userUpdated = await _userService.update(req, user);
      return Response.ok(jsonDecode(userUpdated));
    });

    router.get('/listAll', (Request req) async {
      final users = await _userService.getAllUsers();
      return Response.ok(jsonEncode(users));
    });

    router.delete('/delete/<user>', (Request req, String user) async {
      await _userService.delete(user);
      return Response.ok('ok');
    });

    // -------------  ENTES QUERIDOS  ----------------

    router.post('/friend/create/<user>', (Request req, String user) async {
      final createFriend = await _userService.createFriend(req, user);
      return Response.ok(jsonEncode(createFriend));
    });

    router.put('/friend/update/<friend>', (Request req, String friend) async {
      final response = await _userService.updateFriend(req, friend);
      return Response.ok(jsonEncode(response));
    });

    router.get('/friend/listAll/<user>', (Request req, String user) async {
      final response = await _userService.getAllFriends(user);
      return Response.ok(jsonEncode(response));
    });

    router.delete('/friend/delete/<friend>',
        (Request req, String friend) async {
      await _userService.deleteFriend(friend);
      return Response.ok('ok');
    });

    // -------------  REMEDIOS  ----------------

    router.post('/remedy/create/<user>', (Request req, String user) async {
      final response = await _userService.createRemedy(req, user);
      return Response.ok(jsonEncode(response));
    });

    router.put('/remedy/update/<remedy>', (Request req, String remedy) async {
      final response = await _userService.updateRemedy(req, remedy);
      return Response.ok(jsonEncode(response));
    });

    router.get('/remedy/listAll/<user>', (Request req, String user) async {
      final response = await _userService.getAllRemedy(user);
      return Response.ok(jsonEncode(response));
    });

    router.delete('/remedy/delete/<remedy>',
        (Request req, String remedy) async {
      await _userService.deleteRemedy(remedy);
      return Response.ok('ok');
    });

    // -------------  DIARIOS  ----------------

    router.post('/diary/create/<user>', (Request req, String user) async {
      final response = await _userService.createDaily(req, user);
      return Response.ok(jsonEncode(response));
    });

    router.put('/diary/update/<diary>', (Request req, String diary) async {
      final response = await _userService.updateDaily(req, diary);
      return Response.ok(jsonEncode(response));
    });

    router.get('/diary/listAll/<user>', (Request req, String user) async {
      final response = await _userService.getAllDaily(user);
      return Response.ok(jsonEncode(response));
    });

    router.delete('/diary/delete/<diary>', (Request req, String diary) async {
      await _userService.deleteDaily(diary);
      return Response.ok('ok');
    });

    // -------------  ATIVIDADES FISICAS  ----------------

    router.post('/activity/create/<user>', (Request req, String user) async {
      final response = await _userService.createActivity(req, user);
      return Response.ok(jsonEncode(response));
    });

    router.put('/activity/update/<activity>',
        (Request req, String activity) async {
      final response = await _userService.updateActivity(req, activity);
      return Response.ok(jsonEncode(response));
    });

    router.get('/activity/listAll/<user>', (Request req, String user) async {
      final response = await _userService.getAllActivity(user);
      return Response.ok(jsonEncode(response));
    });

    router.delete('/activity/delete/<activity>',
        (Request req, String activity) async {
      await _userService.deleteActivity(activity);
      return Response.ok('ok');
    });

    // -------------  ALIMENTACAO  ----------------

    router.post('/food/create/<user>', (Request req, String user) async {
      final response = await _userService.createFood(req, user);
      return Response.ok(jsonEncode(response));
    });

    router.put('/food/update/<food>', (Request req, String food) async {
      final response = await _userService.updateFood(req, food);
      return Response.ok(jsonEncode(response));
    });

    router.get('/food/listAll/<user>', (Request req, String user) async {
      final response = await _userService.getAllFood(user);
      return Response.ok(jsonEncode(response));
    });

    router.delete('/food/delete/<food>', (Request req, String food) async {
      await _userService.deleteFood(food);
      return Response.ok('ok');
    });

    // -------------  ALARMES  ----------------

    return router;
  }
}
