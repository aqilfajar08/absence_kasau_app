import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:absence_kasau_app/core/constants/variables.dart';
import 'package:absence_kasau_app/data/datasources/auth_local_datasource.dart';

class PermissionRemoteDatasource {
  Future<Either<String, String>> addPermission(
      String permission, XFile? image) async {
    final authData = await AuthLocalDatasource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/permission');
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer ${authData?.accessToken}',
    };

    var request = http.MultipartRequest('POST', url);

    request.headers.addAll(headers);
    // request.fields['date'] = date;
    request.fields['permission'] = permission;
    request.files.add(await http.MultipartFile.fromPath('image', image!.path));

    http.StreamedResponse response = await request.send();

    final String body = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return const Right('Permission added successfully');
    } else {
      return const Left('Failed to add permission');
    }
  }
}