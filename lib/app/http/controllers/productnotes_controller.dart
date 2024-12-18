import 'package:vania/vania.dart';

import 'package:project_rest_vania/app/models/productnotes.dart';
// ignore: implementation_imports
import 'package:vania/src/exception/validation_exception.dart';

class ProductnotesController extends Controller {
  Future<Response> index() async {
    return Response.json({'message': 'Hello World'});
  }

  Future<Response> create(Request request) async {
    return Response.json({});
  }

  Future<Response> store(Request request) async {
    try {
      // Validasi input
      request.validate({
        'prod_id': 'required',
        'note_date': 'required',
        'note_text': 'required',
      }, {
        'prod_id.required': 'ID produk tidak boleh kosong.',
        'note_date.required': 'Tanggal catatan tidak boleh kosong.',
        'note_text.required': 'Teks catatan tidak boleh kosong.',
      });

      // Jika sudah mendapatkan inputan
      final productnotesData = request.input();

      final existingProductNotes = await Productnotes()
          .query()
          .where('prod_id', '=', productnotesData['prod_id'])
          .first();

      if (existingProductNotes == null) {
        return Response.json(
            {'message': 'Catatan product dengan ID ini tidak ada.'}, 404);
      }

      // Menambahkan timestamps untuk created_at
      productnotesData['created_at'] = DateTime.now().toIso8601String();

      // Masukkan data ke database
      await Productnotes().query().insert(productnotesData);

      return Response.json({
        'status': true,
        'message': 'Catatan product berhasil ditambahkan.',
        'data': productnotesData
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

  Future<Response> update(Request request, int noteId) async {
    try {
      // Validasi input
      request.validate({
        'prod_id': 'required|integer',
        'note_date': 'required|date',
        'note_text': 'required|string',
      }, {
        'prod_id.required': 'ID produk wajib diisi.',
        'prod_id.integer': 'ID produk harus berupa angka.',
        'note_date.required': 'Tanggal catatan wajib diisi.',
        'note_date.date': 'Tanggal catatan harus berupa tanggal.',
        'note_text.required': 'Teks catatan wajib diisi.',
        'note_text.string': 'Teks catatan harus berupa teks.',
      });

      // Ambil input data customers yang akan diupdate
      final productnotesData = request.input();

      if (productnotesData.containsKey('id')) {
        productnotesData['note_id'] = productnotesData['id'];
        productnotesData.remove('id');
      }

      // Menambahkan timestamps untuk update_at
      productnotesData['updated_at'] = DateTime.now().toIso8601String();

      // Cari Product Notes Berdasarkan ID
      final existingProductNotes =
          await Productnotes().query().where('note_id', '=', noteId).first();

      if (existingProductNotes == null) {
        return Response.json(
            {'message': 'Catatan product dengan ID ini tidak ada.'}, 404);
      }

      if (productnotesData.containsKey('prod_id')) {
        final existingProductNotes = await Productnotes()
            .query()
            .where('prod_id', '=', productnotesData['prod_id'])
            .first();

        if (existingProductNotes == null) {
          return Response.json(
              {'message': 'Product dengan ID ini tidak ada.'}, 404);
        }
      }

      // Update data ke database
      await Productnotes()
          .query()
          .where('note_id', '=', noteId)
          .update(productnotesData);

      // Response jika berhasil
      return Response.json({
        'status': true,
        'message': 'Catatan product berhasil diupdate.',
        'data': productnotesData
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
      // Periksa apakah catatan produk dengan ID yang sama sudah ada
      final existingProductNotes =
          await Productnotes().query().where('note_id', '=', id).first();

      if (existingProductNotes == null) {
        return Response.json(
            {'message': 'Catatan produk dengan ID ini tidak ada.'}, 404);
      }

      // Hapus data dari database
      await Productnotes().query().where('note_id', '=', id).delete();

      // Response jika berhasil
      return Response.json({
        'status': true,
        'message': 'Catatan produk berhasil dihapus.',
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

final ProductnotesController productnotesController = ProductnotesController();