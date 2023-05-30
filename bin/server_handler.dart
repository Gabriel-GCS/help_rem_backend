import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'services/user_service.dart';

class ServeHandler {

  final UserService _userService = UserService();

  Handler get handler {

    final router = Router();

    // -------------  USER  ----------------

    router.post('/create', (Request req) async{
      await _userService.create(req);
      return Response.ok('ok');
    });

    router.post('/login', (Request req) async{
      await _userService.login(req);
      return Response.ok('ok');
    });

    router.put('/update/<user>', (Request req, String user) async {
      await _userService.update(req, user);
      return Response.ok('ok');
    });

    router.get('/listAll', (Request req) async{
      final users = await _userService.getAllUsers();
      print(users);
      return Response(200, body : 'ok');
    });

    router.delete('/delete/<user>', (Request req,String user) async {
      await _userService.delete(user);
      return Response.ok('ok');
    });

    // -------------  ENTES QUERIDOS  ----------------

    router.post('/friend/create/<user>', (Request req, String user) async{
      await _userService.createFriend(req, user);
      return Response.ok('ok');
    });

    router.put('/friend/update/<friend>', (Request req, String friend) async {
      await _userService.updateFriend(req, friend);
      return Response.ok('ok');
    });


    router.get('/friend/listAll/<user>', (Request req, String user) async{
      final users = await _userService.getAllFriends(user);
      print(users);
      return Response(200, body : 'ok');
    });

    router.delete('/friend/delete/<friend>', (Request req, String friend) async {
      await _userService.deleteFriend(friend);
      return Response.ok('ok');
    });

    // -------------  REMEDIOS  ----------------

    router.post('/remedy/create/<user>', (Request req, String user) async{
      await _userService.createRemedy(req, user);
      return Response.ok('ok');
    });

    router.put('/remedy/update/<remedy>', (Request req, String remedy) async {
      await _userService.updateRemedy(req, remedy);
      return Response.ok('ok');
    });


    router.get('/remedy/listAll/<user>', (Request req,String user) async{
      final users = await _userService.getAllRemedy(user);
      print(users);
      return Response(200, body : 'ok');
    });

    router.delete('/remedy/delete/<remedy>', (Request req,String remedy) async {
      await _userService.deleteRemedy(remedy);
      return Response.ok('ok');
    });

    // -------------  DIARIOS  ----------------

    router.post('/diary/create/<user>', (Request req, String user) async{
      await _userService.createDaily(req, user);
      return Response.ok('ok');
    });

    router.put('/diary/update/<diary>', (Request req, String diary) async {
      await _userService.updateDaily(req, diary);
      return Response.ok('ok');
    });


    router.get('/diary/listAll/<user>', (Request req,String user) async{
      final users = await _userService.getAllDaily(user);
      print(users);
      return Response(200, body : 'ok');
    });

    router.delete('/diary/delete/<diary>', (Request req,String diary) async {
      await _userService.deleteDaily(diary);
      return Response.ok('ok');
    });

    // -------------  ATIVIDADES FISICAS  ----------------

    router.post('/activity/create/<user>', (Request req, String user) async{
      await _userService.createActivity(req, user);
      return Response.ok('ok');
    });

    router.put('/activity/update/<activity>', (Request req, String activity) async {
      await _userService.updateActivity(req, activity);
      return Response.ok('ok');
    });


    router.get('/activity/listAll/<user>', (Request req,String user) async{
      final users = await _userService.getAllActivity(user);
      print(users);
      return Response(200, body : 'ok');
    });

    router.delete('/activity/delete/<activity>', (Request req,String activity) async {
      await _userService.deleteActivity(activity);
      return Response.ok('ok');
    });

    // -------------  ALIMENTACAO  ----------------

    router.post('/food/create/<user>', (Request req, String user) async{
      await _userService.createFood(req, user);
      return Response.ok('ok');
    });

    router.put('/food/update/<food>', (Request req, String food) async {
      await _userService.updateFood(req, food);
      return Response.ok('ok');
    });

    router.get('/food/listAll/<user>', (Request req,String user) async{
      final users = await _userService.getAllFood(user);
      print(users);
      return Response(200, body : 'ok');
    });

    router.delete('/food/delete/<food>', (Request req,String food) async {
      await _userService.deleteFood(food);
      return Response.ok('ok');
    });

    // -------------  ALARMES  ----------------
    
    return router;
  }
}