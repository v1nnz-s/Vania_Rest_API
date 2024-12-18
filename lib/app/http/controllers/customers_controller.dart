import 'package:project_rest_vania/app/models/customers.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart'; // Validasi
import 'package:vania/vania.dart';

class CustomersController extends Controller {
  Future<Response> index() async {
    try {
      // Ambil data customers dari database
      final customers = await Customers().query().get();

      return Response.json({
        'status': true,
        'message': 'Data customers berhasil diambil.',
        'data': customers
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      // Menangani Error Server
      return Response.json({
        'message': 'Terjadi kesalahan di sisi server. Harap coba lagi nanti.'
      }, 500);
    }
  }

  Future<Response> create(Request request) async {
    return Response.json({'message': 'Form mmbuat customers baru'});
  }

  Future<Response> store(Request request) async {
    try {
      // Memberikan validasi tidak boleh kosong
      request.validate({
        'cust_name': 'required',
        'cust_address': 'required',
        'cust_city': 'required',
        'cust_state': 'required',
        'cust_zip': 'required',
        'cust_country': 'required',
        'cust_telp': 'required',
      }, {
        'cust_name.required': 'Nama tidak boleh kosong',
        'cust_address.required': 'Adrress tidak boleh kosong',
        'cust_city.required': 'City tidak boleh kosong',
        'cust_state.required': ' State tidak boleh kosong',
        'cust_zip.required': 'Zip tidak boleh kosong',
        'cust_country.required': 'Country tidak boleh kosong',
        'cust_telp.required': 'Telp tidak boleh kosong',
      });

      // Jika sudah mendapatkan inputan
      final customersData = request.input();

      final existingCustomer = await Customers()
          .query()
          .where('cust_name', '=', customersData['cust_name'])
          .first();

      if (existingCustomer != null) {
        return Response.json(
            {'message': 'Customer dengan nama ini sudah ada.'}, 409);
      }

      // Menambahkan timestamps untuk created_at
      customersData['created_at'] = DateTime.now().toIso8601String();

      // Masukkan data ke database
      await Customers().query().insert(customersData);

      return Response.json({
        'status': true,
        "message": "Data customers berhasil ditambahkan",
        "data": customersData,
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

      // Menangani Error Server
      return Response.json({
        "message": "Data Customers Gagal Ditambahkan, Silahkan Coba Lagi",
      }, 500);
    }
  }

  Future<Response> show(int id) async {
    try {
      // GET DATA
      final customers =
          await Customers().query().where('cust_id', '=', id).first();

      if (customers == null) {
        return Response.json(
            {'message': 'Data customers tidak ditemukan.'}, 404);
      }

      return Response.json({
        'status': true,
        'message': 'Daftar Customers',
        'data': customers,
      }, 200);
    } catch (e) {
      print('Error: ${e.toString()}');
      print('Stacktrace: ${StackTrace.current}');

      return Response.json({
        'message': "Terjadi kesalahan saat mengambil data customers",
      }, 500);
    }
  }

  Future<Response> edit(int id) async {
    return Response.json({});
  }

  Future<Response> update(Request request, int id) async {
    try {
      /// Validasi input dari pengguna
      request.validate({
        'cust_name': 'required|string|max_length:50',
        'cust_address': 'required|string|max_length:50',
        'cust_city': 'required|string|max_length:20',
        'cust_state': 'required|string|max_length:5',
        'cust_zip': 'required|string|max_length:7',
        'cust_country': 'required|string|max_length:25',
        'cust_telp': 'required|string|max_length:15',
      }, {
        'cust_name.required': 'Nama Customers wajib diisi',
        'cust_name.string': 'Nama Customers harus berupa teks',
        'cust_name.max_length': 'Id Customers maksimal 50 karakter.',
        'cust_address.required': 'Address Customers wajib diisi',
        'cust_address.string': 'Address Customers harus berupa teks',
        'cust_address.max_length': 'Address Customers maksimal 50 karakter.',
        'cust_city.required': 'City Customers wajib diisi',
        'cust_city.string': 'City Customers harus berupa teks',
        'cust_city.max_length': 'City Customers maksimal 20 karakter.',
        'cust_state.required': 'State Customers wajib diisi',
        'cust_state.string': 'State Customers harus berupa teks',
        'cust_state.max_length': 'State Customers maksimal 5 karakter.',
        'cust_zip.required': 'Zip Customers wajib diisi',
        'cust_zip.string': 'Zip Customers harus berupa teks',
        'cust_zip.max_length': 'Zip Customers maksimal 7 karakter.',
        'cust_country.required': 'Country Customers wajib diisi',
        'cust_country.string': 'Country Customers harus berupa teks',
        'cust_country.max_length': 'Country Customers maksimal 25 karakter.',
        'cust_telp.required': 'Telp Customers wajib diisi',
        'cust_telp.string': 'Telp Customers harus berupa teks',
        'cust_telp.max_length': 'Telp Customers maksimal 15 karakter.',
      });

      // Ambil input data customers yang akan diupdate
      final customersData = request.input();

      if (customersData.constainskey('id')) {
        customersData['cust_id'] = customersData['id'];
        customersData.remove('id');
      }
      print('Data yang diterima: $customersData');

      customersData['update_at'] = DateTime.now().toIso8601String();

      // Cari Customers Berdasarkan ID
      final customers = await Customers().query().where('id', '=', id).first();

      if (customers == null) {
        return Response.json({
          'message': 'Data customers ID $id tidak ditemukan.',
        }, 404); // HTTP Status Code 404 Not Found
      }

      // Update Data Customers
      await Customers().query().where('id', '=', id).update(customersData);

      // Mengembalikan respons sukses dengan status 200 OK
      return Response.json({
        'status': true,
        'message': 'Data customers dengan ID $id berhasil diperbarui',
        'data': customersData, // Menyertakan data customers yang diupdate
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
      // Cari Customers Berdasarkan ID
      final customers = await Customers().query().where('id', '=', id).first();

      if (customers == null) {
        return Response.json({
          'message': 'Data customers ID $id tidak ditemukan.',
        }, 404);
      }

      // Hapus Customers
      await Customers().query().where('id', '=', id).delete();

      return Response.json({
        'status': true,
        'message': 'Data customers ID $id berhasil di hapus',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': "Terjadi kesalahan saat menghapus data customers",
        'error': e.toString(),
      }, 500);
    }
  }
}

final CustomersController customersController = CustomersController();