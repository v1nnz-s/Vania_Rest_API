import 'package:vania/vania.dart';

import 'package:project_rest_vania/app/models/orderitems.dart';
import 'package:project_rest_vania/app/models/orders.dart';
import 'package:project_rest_vania/app/models/products.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';

class OrderitemsController extends Controller {
  Future<Response> index() async {
    return Response.json({'message': 'Hello World'});
  }

  Future<Response> create(Request request) async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      // Memberikan validasi tidak boleh kosong
      request.validate({
        'order_num': 'required',
        'prod_id': 'required',
        'quantity': 'required',
        'size': 'required',
      }, {
        'order_num.required': 'Num Order tidak boleh kosong',
        'prod_id.required': 'ID Prod tidak boleh kosong',
        'quantity.required': 'Quantity tidak boleh kosong',
        'size.required': ' Size tidak boleh kosong',
      });

      // Jika sudah mendapatkan inputan
      final orderItemsData = request.input();

      // Periksa apakah pesanan dengan ID yang sama sudah ada
      final existingOrderItems = await Orderitems()
          .query()
          .where('order_num', '=', orderItemsData['order_num'])
          .first();

      if (existingOrderItems == null) {
        return Response.json(
            {'message': 'Order items dengan ID ini tidak ada.'}, 404);
      }

      // Menambahkan timestamps untuk created_at
      orderItemsData['created_at'] = DateTime.now().toIso8601String();

      // Masukkan data ke database
      await Orderitems().query().insert(orderItemsData);

      return Response.json({
        'status': true,
        "message": "Data order items berhasil Ditambahkan",
        "data": orderItemsData,
      }, 201);
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
        "message": "Terjadi kesalahan di sisi server. Harap coba lagi nanti.",
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
        'order_num': 'integer',
        'prod_id': 'integer',
        'quantity': 'integer',
        'size': 'integer',
      }, {
        'order_num.integer': 'Nomor pesanan harus berupa angka.',
        'prod_id.integer': 'ID produk harus berupa angka.',
        'quantity.integer': 'Jumlah harus berupa angka.',
        'size.integer': 'Ukuran harus berupa angka.',
      });

      // Ambil data input
      final orderItemsData = request.input();

      if (orderItemsData.containsKey('id')) {
        orderItemsData['order_item'] = orderItemsData['id'];
        orderItemsData.remove('id');
      }

      // Periksa apakah item pesanan dengan ID yang sama sudah ada
      final existingOrderItems =
          await Orderitems().query().where('order_item', '=', id).first();

      if (existingOrderItems == null) {
        return Response.json(
            {'message': 'Item pesanan dengan ID ini tidak ada.'}, 404);
      }

      // Periksa apakah pesanan dengan ID yang sama sudah ada
      if (orderItemsData.containsKey('order_num')) {
        final existingOrders = await Orders()
            .query()
            .where('order_num', '=', orderItemsData['order_num'])
            .first();

        if (existingOrders == null) {
          return Response.json(
              {'message': 'Pesanan dengan ID ini tidak ada.'}, 404);
        }
      }

      // Periksa apakah produk dengan ID yang sama sudah ada
      if (orderItemsData.containsKey('prod_id')) {
        final existingProduct = await Products()
            .query()
            .where('prod_id', '=', orderItemsData['prod_id'])
            .first();

        if (existingProduct == null) {
          return Response.json(
              {'message': 'Produk dengan ID ini tidak ada.'}, 404);
        }
      }

      // Tambahkan timestamp untuk updated_at
      orderItemsData['updated_at'] = DateTime.now().toIso8601String();

      // Update data ke database
      await Orderitems()
          .query()
          .where('order_item', '=', id)
          .update(orderItemsData);

      // Response jika berhasil
      return Response.json({
        'status': true,
        'message': 'Item pesanan berhasil diupdate.',
        'data': orderItemsData
      }, 200);
    } catch (e) {
      // Tangani ValidationException secara khusus
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'errors': errorMessages,
        }, 400);
      }

      // Log error ke konsol untuk debugging
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      // Tangani error lainnya
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> destroy(int id) async {
    try {
      // Periksa apakah item pesanan dengan ID yang sama sudah ada
      final existingOrderItems =
          await Orderitems().query().where('order_item', '=', id).first();

      if (existingOrderItems == null) {
        return Response.json(
            {'message': 'Item pesanan dengan ID ini tidak ada.'}, 404);
      }

      // Hapus data dari database
      await Orderitems().query().where('order_item', '=', id).delete();

      // Response jika berhasil
      return Response.json({
        'status': true,
        'message': 'Item pesanan berhasil dihapus.',
      }, 200);
    } catch (e) {
      // Log error ke konsol untuk debugging
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      // Tangani error lainnya
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }
}

final OrderitemsController orderitemsController = OrderitemsController();