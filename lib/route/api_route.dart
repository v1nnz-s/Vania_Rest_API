import 'package:project_rest_vania/app/http/controllers/auth_controller.dart';
import 'package:vania/vania.dart';
import 'package:project_rest_vania/app/http/controllers/customers_controller.dart';
import 'package:project_rest_vania/app/http/controllers/orderitems_controller.dart';
import 'package:project_rest_vania/app/http/controllers/orders_controller.dart';
import 'package:project_rest_vania/app/http/controllers/productnotes_controller.dart';
import 'package:project_rest_vania/app/http/controllers/products_controller.dart';
import 'package:project_rest_vania/app/http/controllers/vendors_controller.dart';


class ApiRoute implements Route {
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');

    /// Membuat CRUD (GET, POST, PUT, DELETE) Customers
    Router.get('/customers', customersController.index);
    Router.get('/customers/{id}', customersController.show);
    Router.post('/customers', customersController.store);
    Router.put('/customers/{id}', customersController.update);
    Router.delete('/customers/{id}', customersController.destroy);

    /// Membuat CRUD (GET, POST, PUT, DELETE) Orders
    Router.get('/orders', ordersController.show);
    Router.post('/orders', ordersController.store);
    Router.put('/orders/{id}', ordersController.update);
    Router.delete('/orders/{id}', ordersController.destroy);

    /// Membuat CRUD (GET, POST, PUT, DELETE) Vendors
    Router.get('/vendors', vendorsController.show);
    Router.post('/vendors', vendorsController.store);
    Router.put('/vendors/{id}', vendorsController.update);
    Router.delete('/vendors/{id}', vendorsController.destroy);

    /// Membuat CRUD (GET, POST, PUT, DELETE) Products
    Router.get('/products', productsController.show);
    Router.post('/products', productsController.store);
    Router.put('/products/{id}', productsController.update);
    Router.delete('/products/{id}', productsController.destroy);

    /// Membuat CRUD (GET, POST, PUT, DELETE) Product Notes
    Router.get('/productnotes', productnotesController.show);
    Router.post('/productnotes', productnotesController.store);
    Router.put('/productnotes/{id}', productnotesController.update);
    Router.delete('/productnotes/{id}', productnotesController.destroy);

    /// Membuat CRUD (GET, POST, PUT, DELETE) Order Items
    Router.get('/orderitems', orderitemsController.show);
    Router.post('/orderitems', orderitemsController.store);
    Router.put('/orderitems/{id}', orderitemsController.update);
    Router.delete('/orderitems/{id}', orderitemsController.destroy);

    
    Router.group((){
      Router.post('/register', authController.register);
      Router.post('/login', authController.login);
    }, prefix: 'auth');
  }
}