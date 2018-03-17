import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cleanflutter/model/user.dart';
import 'package:cleanflutter/ui/utils/http/client.dart';

class UserRemoteDataSource {
  Client _client = new Client(baseUrl:"https://randomuser.me/api/");
  String endpoint = "?results=100";

  UserRemoteDataSource({Client client}) {
    _client = client != null ? client : _client;
  }

  Future<List<User>> fetchUsers() async {
    try {
      Uri url = Uri.parse(_client.baseUrl + endpoint);
      var res = await this._client.get(url);
      List<Map<String, dynamic>> items = res["results"];
      List<User> users = items
          .map((r) => new User.fromMap(r))
          .toList();
      return users;
    }  on HttpException catch(e) {
      return [];
    } catch (err) {
      return [];
    }
  }
}

class UserLocalDataSource{

  UserLocalDataSource();

  Future<List<User>> fetchUsers() async {
     var res = await _readFile();
     try {
       List<Map<String, dynamic>> items = JSON.decode(res["results"]);
       List<User> users = items
           .map((r) => new User.fromMap(r))
           .toList();
       return users;
     } catch (err) {
       return [];
     }
  }

  Future<Null> saveUsers(List<User> users) async {
    // write the data as a string to the file
    List<Map<String, dynamic>> userMap = new List<Map<String, dynamic>>();
    users.forEach((user) => userMap.add(user.toMap()));
    Map results = new Map();
    results["results"] = JSON.encode(userMap);
    await (await _getFile()).writeAsString(JSON.encode(results).toString());
  }


  //helpers with files

  Future<File> _getFile() async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/users.json');
  }

  Future<Map> _readFile() async {
    try {
      File file = await _getFile();
      // read the variable as a string from the file.
      String contents = await file.readAsString();
      return JSON.decode(contents);
    } on FileSystemException {
      return JSON.decode("");
    }
  }

}