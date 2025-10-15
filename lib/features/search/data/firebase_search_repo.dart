import 'package:socialapp/features/profile/domain/entities/profile_user.dart';
import 'package:socialapp/features/search/domain/search_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseSearchRepo implements SearchRepo{
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async{
    try{

      final result = await FirebaseFirestore.instance
            .collection("users")
            .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('name', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
            .get();

      final users = result.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id; // Add document ID as uid
        return ProfileUser.fromJson(data);
      }).toList();

      return users;
    } catch (e) { 
      throw Exception("Error searching users: $e");
    }
  }
}