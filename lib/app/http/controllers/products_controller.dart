import 'package:vania/vania.dart';

import 'package:project_rest_vania/app/models/products.dart';
import 'package:project_rest_vania/app/models/vendors.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';


class ProductsController extends Controller {
  Future<Response> index() async {
    return Response.json({'message': 'Hello World'});
  }

  Future<Response> create(Request request) async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      /// Validasi input dari pengguna
      request.validate({
        'vend_id': 'required',
        'prod_name': 'required',
        'prod_price': 'required',
        'prod_desc': 'required',
      }, {
        'vend_id.required': 'ID Vendors wajib diisi',
        'prod_name.required': 'Nama Produk wajib diisi',
        'prod_price.required': 'Harga Produk wajib diisi',
        'prod_desc.required': 'Deskripsi Produk wajib diisi',
      });

      // Ambil data dari input
      final productsData = request.input();
      final vendId = productsData['vend_id'];

      final vendorsCount =
          await Vendors().query().where('vend_id', '=', vendId).count();

      final vendorsExists = vendorsCount > 0;

      if (!vendorsExists) {
        return Response.json(
            {'message': 'Vendor dengan ID ini tidak ditemukan.'}, 400);
      }

      // Periksa apakah produk dengan nama yang sama sudah ada
      final existingProducts = await Products()
          .query()
          .where('prod_name', '=', productsData['prod_name'])
          .first();

      if (existingProducts != null) {
        return Response.json(
            {'message': 'Data produk dengan nama ini sudah ada.'}, 409);
      }

      // Tambahkan timestamp untuk created_at
      productsData['created_at'] = DateTime.now().toIso8601String();

      // Masukkan data ke database
      await Products().query().insert(productsData);

      return Response.json({
        'status': true,
        'message': 'Data product berhasil ditambahkan.',
        'data': productsData
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
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
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
      /// Validasi input dari pengguna
      request.validate({
        'vend_id': 'required|numeric',
        'prod_name': 'required|string|max_length:25',
        'prod_price': 'required|numeric|min:0',
        'prod_desc': 'required|text',
      }, {
        'vend_id.required': 'ID Vendors wajib diisi',
        'vend_id.numeric': 'ID Vendors harus berupa angka',
        'prod_name.required': 'Nama Produk wajib diisi',
        'prod_name.string': 'Nama Produk harus berupa teks',
        'prod_name.max_length': 'Nama Produk maksimal 25 karakter',
        'prod_price.required': 'Harga Produk wajib diisi',
        'prod_price.numeric': 'Harga Produk harus berupa angka',
        'prod_price.min': 'Harga Produk tidak boleh kurang dari 0',
        'prod_desc.required': 'Deskripsi Produk wajib diisi',
        'prod_desc.text': 'Deskripsi Produk harus berupa teks',
      });

      // Ambil input data products yang akan diupdate
      final productsData = request.input();
      productsData['update_at'] = DateTime.now().toIso8601String();

      // Cari products Berdasarkan ID
      final products = await Products().query().where('id', '=', id).first();

      if (products == null) {
        return Response.json({
          'message': 'Data Products ID $id tidak ditemukan.',
        }, 404); // HTTP Status Code 404 Not Found
      }

      // Update Data Products
      await Products().query().where('id', '=', id).update(productsData);

      // Mengembalikan respons sukses dengan status 200 OK
      return Response.json({
        'message': 'Data Products berhasil diperbarui',
        'data': productsData, // Menyertakan data customers yang diupdate
      }, 200); // HTTP Status Code 200 OK
    } catch (e) {
      // Menangani kesalahan validasi
      if (e is ValidationException) {
        final errorMessages = e.message;
        return Response.json({
          'error': errorMessages,
        }, 400); // HTTP Status Code 400 Bad Request
      } else {
        // Menangani kesalahan tak terduga
        return Response.json({
          'message': "Terjadi kesalahan di sisi server. Harap coba lagi nanti.",
        }, 500); // HTTP Status Code Internal Server Error
      }
    }
  }

  Future<Response> destroy(int id) async {
    return Response.json({});
  }
}

final ProductsController productsController = ProductsController();