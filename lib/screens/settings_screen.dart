import 'package:flutter/material.dart';
import 'package:card_random/services/history_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedFile = '52Cards.txt';

  @override
  void initState() {
    super.initState();
    _loadSelectedFile();
  }

  Future<void> _loadSelectedFile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedFile = prefs.getString('selectedFile') ?? '52Cards.txt';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9A9E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'File đang sử dụng',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFF9A9E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedFile.isEmpty ? '[Tên file]' : selectedFile,
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedFile.isEmpty ? Colors.grey[500] : Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.folder, color: Colors.white, size: 20),
                      onPressed: _pickFile,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showResetConfirmation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9A9E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Reset lịch sử',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'File tham khảo định dạng',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFF9A9E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  const url = 'https://drive.usercontent.google.com/download?id=1lMNVkVsNMJ7SlhceNVRBvtTr4CE7C3pQ&export=download';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Không thể mở đường dẫn tải file!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9A9E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFFF9A9E),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A9E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFFF9A9E).withOpacity(0.3),
                ),
              ),
              child: const Text(
                'Ứng dụng cung cấp công cụ ngẫu nhiên tích hợp 52 lá bài với giao diện trực quan, có thể dễ dàng thay đổi nội dung theo File tùy chỉnh\n\nEmail: dovinhhp102@gmail.com\nSĐT: 0984981822',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFFF9A9E),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              HistoryService().clear();
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Xóa lịch sử rút bài thành công!'),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _downloadSampleFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đang tải file mẫu...'),
        backgroundColor: const Color(0xFFFF9A9E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File mẫu đã được tải về thành công!'),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt']);
    if (result != null && result.files.single.path != null) {
      String path = result.files.single.path!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedFile', path);
      setState(() {
        selectedFile = path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chọn file: $path')),
      );
      Navigator.pop(context, true); // Thông báo cho màn hình trước reload lại
    }
  }
}
