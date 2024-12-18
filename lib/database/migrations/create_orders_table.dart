import 'package:vania/vania.dart';

class CreateOrdersTable extends Migration {

  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('orders', () {
      bigIncrements('order_num');
      date('order_date');
      bigInt('cust_id', length: 5, unsigned: true);

      timeStamps();

      primary('order_num');
      foreign('cust_id', 'customers', 'cust_id',
          constrained: true, onDelete: 'CASCADE');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('orders');
  }
}
