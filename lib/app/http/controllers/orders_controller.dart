import 'package:vania/vania.dart';

import 'package:project_rest_vania/app/models/customers.dart';
import 'package:project_rest_vania/app/models/orders.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';

class OrdersController extends Controller {
  Future<Response> index() async {
    try {
      final orders = await Orders().query().get();

      return Response.json({
        'status': true,
        'message': 'Data orders berhasil diambil.',
        'data': orders
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> create(Request request) async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      // Memberikan validasi tidak boleh kosong
      request.validate({
        'order_date': 'required',
        'cust_id': 'required',
      }, {
        'order_date.required': 'Tanggal order tidak boleh kosong',
        'cust_id.required': 'ID customers tidak boleh kosong',
      });

      // Jika sudah mendapatkan inputan
      final ordersData = request.input();

      final existingCustomers = await Customers()
          .query()
          .where('cust_id', '=', ordersData['cust_id'])
          .first();

      if (existingCustomers == null) {
        return Response.json(
            {'message': 'Customer dengan ID ini tidak ada.'}, 404);
      }

      // Menambahkan timestamps untuk created_at
      ordersData['created_at'] = DateTime.now().toIso8601String();

      // Masukkan data ke database
      await Orders().query().insert(ordersData);

      return Response.json({
        "message": "Data Customers Berhasil Ditambahkan",
        "data": ordersData,
      }, 201);
    } catch (e) {
      // Tangani ValidationException secara khusus
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400);
      }

      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        "message": "Data Customers Gagal Ditambahkan, Silahkan Coba Lagi",
      }, 500);
    }
  }

  Future<Response> show(int id) async {
    return Response.json({});
  }

  Future<Response> edit(int id) async {
    return Response.json({});
  }

  Future<Response> update(Request request, int id) async {
    try {
      // Validasi input
      request.validate({
        'order_date': 'date',
        'cust_id': 'integer',
      }, {
        'order_date.date': 'Tanggal orders harus berupa tanggal.',
        'cust_id.integer': 'ID customers harus berupa angka.',
      });

      // Ambil data input
      final ordersData = request.input();

      if (ordersData.containsKey('id')) {
        ordersData['order_num'] = ordersData['id'];
        ordersData.remove('id');
      }

      // Periksa apakah pesanan dengan ID yang sama sudah ada
      final existingOrders =
          await Orders().query().where('order_num', '=', id).first();

      if (existingOrders == null) {
        return Response.json(
            {'message': 'Data orders dengan ID ini tidak ada.'}, 404);
      }

      if (ordersData.containsKey('cust_id')) {
        final existingCustomers = await Customers()
            .query()
            .where('cust_id', '=', ordersData['cust_id'])
            .first();

        if (existingCustomers == null) {
          return Response.json(
              {'message': 'Data customers dengan ID ini tidak ada.'}, 404);
        }
      }

      // Menambahkan timestamps untuk updated_at
      ordersData['updated_at'] = DateTime.now().toIso8601String();

      // Update data ke database
      await Orders().query().where('order_num', '=', id).update(ordersData);

      return Response.json({
        'status': true,
        'message': 'Orders berhasil diupdate.',
        'data': ordersData
      }, 200);
    } catch (e) {
      // Menangani Validation Exception
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400);
      }

      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> destroy(int id) async {
    try {
      final existingOrders =
          await Orders().query().where('order_num', '=', id).first();

      if (existingOrders == null) {
        return Response.json(
            {'message': 'Orders dengan ID ini tidak ada.'}, 404);
      }

      // Hapus data dari database
      await Orders().query().where('order_num', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Orders berhasil dihapus.',
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }
}

final OrdersController ordersController = OrdersController();