import 'package:vania/vania.dart';

class CreatePersonalAccessTokens extends Migration {

  @override
  Future<void> up() async{
   super.up();
   await createTableNotExists('personal_access_tokens', () {
      id();
      tinyText('name');
      bigInt('tokenable_id');
      string('token');
      dateTime('last_used_at', nullable: true);
      dateTime('created_at', nullable: true);
      dateTime('deleted _at', nullable: true);

      index(ColumnIndex.unique, 'token', ['token']);
    });
  }
  
  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('personal_access_tokens');
  }
}