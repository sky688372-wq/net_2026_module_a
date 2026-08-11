import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.id});

  final int id;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  String? _token;
  Map<String, dynamic>? data;
  bool isLoading = true;

  Future<void> fetchToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? "토큰 없음";
  }

  Future<void> fetchDetailData() async {
    final url = "https://connexChat-server.onrender.com/vinyl/products/${widget.id}";

    await fetchToken();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        setState(() {
          data = parsedJson['data'];
          isLoading = false;
        });
        print(data);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDetailData();
  }

  @override
  Widget build(BuildContext context) {
    // 기기의 상태바(Status Bar) 높이를 가져옴
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      // SafeArea를 사용하지 않아야 상단 노치까지 이미지가 가득 차게 됩니다.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(
        child: Text(
          "데이터를 불러올 수 없습니다.",
          style: TextStyle(color: Colors.white),
        ),
      )
          : Stack(
        children: [
          // 1. 전체 스크롤 영역 (이미지 + 하단 내용)
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 이미지 영역
                SizedBox(
                  height: 380, // 원하는 이미지 높이
                  width: double.infinity,
                  child: Image.network(
                    data!['albumImage'] ?? '',
                    fit: BoxFit.cover, // 가로 및 영역을 꽉 채움
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.white),
                  ),
                ),

                // 이미지 하단에 들어갈 상세 내용 영역
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data!['albumName'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data!['artist'] ?? '',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: statusBarHeight + 10,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // 이전 화면으로 이동
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),


        ],
      ),
    );
  }
}