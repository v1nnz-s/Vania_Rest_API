import 'package:vania/vania.dart';

import 'package:project_rest_vania/app/models/vendors.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';



class VendorsController extends Controller {
  Future<Response> store(Request request) async {
    try {
      // Memberikan validasi tidak boleh kosong
      request.validate({
        'vend_name': 'required',
        'vend_address': 'required',
        'vend_kota': 'required',
        'vend_state': 'required',
        'vend_zip': 'required',
        'vend_country': 'required',
      }, {
        'vend_name.required': 'Nama Vendors tidak boleh kosong',
        'vend_address.required': 'Address Vendors tidak boleh kosong',
        'vend_kota.required': 'Kota Vendors tidak boleh kosong',
        'vend_state.required': ' State Vendors tidak boleh kosong',
        'vend_zip.required': ' Zip Vendors tidak boleh kosong',
        'vend_country.required': 'Country Vendors tidak boleh kosong',
      });
      // Jika sudah mendapatkan inputan
      final vendorsData = request.input();

      // Periksa apakah customer dengan nama yang sama sudah ada
      final existingVendors = await Vendors()
          .query()
          .where('vend_name', '=', vendorsData['vend_name'])
          .first();

      if (existingVendors != null) {
        return Response.json(
            {'message': 'Vendor dengan nama ini sudah ada.'}, 409);
      }

      // Tambahkan timestamp untuk created_at
      vendorsData['created_at'] = DateTime.now().toIso8601String();

      // Masukkan data ke database
      await Vendors().query().insert(vendorsData);

      return Response.json({
        'status': true,
        "message": "Data vendors berhasil ditambahkan",
        "data": vendorsData,
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
        "message": "Terjadi kesalahan di sisi server. Silahkan Coba Lagi",
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
        'vend_name': 'required|string|max_length:50',
        'vend_address': 'required|text',
        'vend_kota': 'required|text',
        'vend_state': 'required|string|max_length:5',
        'vend_zip': 'required|string|max_length:7',
        'vend_country': 'required|string|max_length:25',
      }, {
        'vend_name.required': 'Nama Vendors wajib diisi',
        'vend_name.string': 'Nama Vendors harus berupa teks',
        'vend_name.max_length': 'Id Vendors maksimal 50 karakter.',
        'vend_address.required': 'Address Vendors wajib diisi',
        'vend_address.text': 'Address Vendors harus berupa teks',
        'vend_kota.required': 'Kota Vendors wajib diisi',
        'vend_kota.text': 'Kota Vendors harus berupa teks',
        'cust_state.required': 'State Vendors wajib diisi',
        'cust_state.string': 'State Vendors harus berupa teks',
        'cust_state.max_length': 'State Vendors maksimal 5 karakter.',
        'cust_zip.required': 'Zip Vendors wajib diisi',
        'cust_zip.string': 'Zip Vendors harus berupa teks',
        'cust_zip.max_length': 'Zip Vendors maksimal 7 karakter.',
        'cust_country.required': 'Country Vendors wajib diisi',
        'cust_country.string': 'Country Vendors harus berupa teks',
        'cust_country.max_length': 'Country Vendors maksimal 25 karakter.',
      });

      // Ambil input data vendors yang akan diupdate
      final vendorsData = request.input();

      if (vendorsData.containsKey('id')) {
        vendorsData['vend_id'] = vendorsData['id'];
        vendorsData.remove('id');
      }
      print('Data yang diterima: $vendorsData');

      vendorsData['update_at'] = DateTime.now().toIso8601String();

      // Cari Customers Berdasarkan ID
      final vendors = await Vendors().query().where('id', '=', id).first();

      if (vendors == null) {
        return Response.json({
          'message': 'Data vendors ID $id tidak ditemukan.',
        }, 404); // HTTP Status Code 404 Not Found
      }

      // Update Data Customers
      await Vendors().query().where('id', '=', id).update(vendorsData);

      // Mengembalikan respons sukses dengan status 200 OK
      return Response.json({
        'status': true,
        'message': 'Data vendors ID $id berhasil diperbarui',
        'data': vendorsData, // Menyertakan data vendors yang diupdate
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
    try {
      final existingVendors =
          await Vendors().query().where('vend_id', '=', id).first();

      if (existingVendors == null) {
        return Response.json(
            {'message': 'Data vendors dengan ID $id tidak ditemukan.'}, 400);
      }

      await Vendors().query().where('vend_id', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Data vendors dengan ID $id berhasil dihapus.'
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus data vendors.',
        'error': e.toString()
      }, 500);
    }
  }
}

final VendorsController vendorsController = VendorsController();