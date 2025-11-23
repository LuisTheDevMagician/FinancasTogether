import '../data/daos/user_dao.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final UserDAO _userDAO = UserDAO();
  final Uuid _uuid = const Uuid();

  Future<User> create({required String name, required String colorHex}) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      colorHex: colorHex,
      createdAt: DateTime.now(),
    );

    await _userDAO.insert(user);
    return user;
  }

  Future<void> update(User user) async {
    await _userDAO.update(user);
  }

  Future<void> delete(String id) async {
    await _userDAO.delete(id);
  }

  Future<User?> getById(String id) async {
    return await _userDAO.getById(id);
  }

  Future<List<User>> getAll() async {
    return await _userDAO.listAll();
  }

  Future<bool> nameExists(String name, {String? excludeId}) async {
    return await _userDAO.existsByName(name, excludeId: excludeId);
  }

  Future<bool> colorInUse(String colorHex, {String? excludeId}) async {
    return await _userDAO.colorInUse(colorHex, excludeId: excludeId);
  }

  Future<int> count() async {
    return await _userDAO.count();
  }
}
