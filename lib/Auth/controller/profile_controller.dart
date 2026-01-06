import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  Rx<File?> profileImage = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  //  Pick / Change Image
  Future<void> pickImage() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/profile.jpg';

      final File newImage = File(picked.path);

      //  If old image exists, delete it first
      final File savedImage = File(path);
      if (savedImage.existsSync()) {
        await savedImage.delete();
      }

      //  Save new image
      final File copiedImage = await newImage.copy(path);

      profileImage.value = copiedImage;
    }
  }

  //  Remove Image
  Future<void> removeImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile.jpg');

    if (file.existsSync()) {
      await file.delete();
    }

    profileImage.value = null;
  }

  @override
  void onInit() {
    super.onInit(); 
    _loadSavedImage();
  }

  //  Load saved image on app start
  Future<void> _loadSavedImage() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/profile.jpg');

    if (file.existsSync()) {
      profileImage.value = file;
    }
  }
}
