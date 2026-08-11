import 'dart:convert';
import 'dart:ui'; // ImageFilter 사용을 위해 필수
import 'package:flutter/material.dart';
import 'package:net_2026/main_page_screen.dart';
import 'package:net_2026/sign_up_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static var token = "";

  bool _isPasswordHidden = false;

  String status = "정보를 입력해주세요.";

  // 텍스트 필드 컨트롤러
  final TextEditingController _emailCtrl = TextEditingController(); // 이메일 컨트롤러
  final TextEditingController _passwordCtrl =
      TextEditingController(); // 비밀번호 컨트롤러

  //이메일 유효성 검사
  bool _checkEmail() {
    final text = _emailCtrl.text.trim();
    if (text.contains('@') &&
        text.contains('.') &&
        text.contains(".@") == false) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(status)));
      return true;
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(status)));
      return false;
    }
  }


  //이메일 : test@example.com
  //비번 : Test1234!

  // 통신 함수
  Future<void> tryLogin() async {
    if (_checkEmail() == false) {
      return;
    }

    final url = "https://connexChat-server.onrender.com/vinyl/auth/login";
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final parsedData = jsonDecode(response.body);
        final SharedPreferences prefs = await SharedPreferences.getInstance(); //로컬 저장 객체
        await prefs.setString('token', parsedData['data']['token']);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("로그인 성공"),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainPageScreen()),
        );
      } else {
        // API 명세서에 맞춰 errors 배열 내부의 첫 번째 객체 message를 가져옴
        String errorMessage = "로그인 실패";

        if (data['errors'] != null &&
            data['errors'] is List &&
            (data['errors'] as List).isNotEmpty) {
          errorMessage = data['errors'][0]['message'] ?? '로그인 실패';
          print(errorMessage);
        } else if (data['message'] != null) {
          errorMessage = data['message'];
          print(errorMessage);
        }

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류가 발생했습니다: $e")),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 배경색을 더 깔끔한 검은색으로 변경
      body: SingleChildScrollView(
        // 키보드가 올라왔을 때 오버플로우 방지용
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 1. 상단 250px 영역 (배경 + 블러 + 로고)
            SizedBox(
              width: double.infinity,
              height: 250,
              child: ClipRect(
                child: Stack(
                  children: [
                    // (1) 원본 배경 이미지
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // (2) 이미지 위에 씌울 블러 필터
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.3, sigmaY: 2.3),
                        child: Container(
                          color: Colors.black.withOpacity(0.0001), // 오버레이 레이어
                        ),
                      ),
                    ),

                    // (3) 로고 및 타이틀
                    Center(
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo_horizontal.png',
                              width: 180,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vinyl Record Secondhand Marketplace',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 타이틀 문구 영역
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "로그인",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '계정으로 로그인하여 다양한 서비스를 이용하세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. 입력 폼 및 로그인 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 이메일 텍스트 필드
                  TextField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "이메일을 입력해주세요.",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 비밀번호 텍스트 필드
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _isPasswordHidden ? true : false,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "비밀번호를 입력해주세요.",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          });
                        },

                        child: Icon(
                          _isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.remove_red_eye_sharp,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('현재 준비중인 기능입니다.')),
                          );
                        },

                        child: Text(
                          '비밀번호를 잊으셨나요?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        tryLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffdaa84d),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "로그인",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(
                      color: Colors.white.withOpacity(0.3), // 이미지처럼 어둡고 얇은 선
                      thickness: 1, // 선 두께
                      endIndent: 15, // 텍스트("또는")와의 간격
                    ),
                  ),
                ),

                // 2. 중앙 텍스트
                Text(
                  '또는',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6), // 텍스트 색상
                    fontSize: 14,
                  ),
                ),

                // 3. 오른쪽 구분선
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(
                      color: Colors.white.withOpacity(0.3), // 왼쪽 선과 동일한 색상
                      thickness: 1, // 선 두께
                      indent: 15, // 텍스트("또는")와의 간격
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '계정이 없으신가요?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),

                  SizedBox(width: 10),

                  GestureDetector(
                    onTap: () {
                      //회원 가입 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },

                    child: Text(
                      '회원 가입',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffdaa84d),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
