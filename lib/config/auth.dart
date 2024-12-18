import 'package:project_rest_vania/app/models/user.dart';

Map<String, dynamic> authConfig = {
  'guards': {
    'default': {
      'provider': User(),
    }
  }
};
