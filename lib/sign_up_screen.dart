import 'package:flutter/material.dart';
import 'dart:ui';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isChecked = false;
  bool _isPasswordHidden = false;
  bool _isPasswordHidden2 = false;

  // 텍스트 필드 컨트롤러
  final TextEditingController _emailCtrl = TextEditingController(); // 이메일 컨트롤러
  final TextEditingController _passwordCtrl =
      TextEditingController(); // 비밀번호 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //상단 이미지
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
                    Positioned(
                      top: 30,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),

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
            // 본격적인 정보들
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      '회원 정보를 입력하여 계정을 만들어주세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 이메일 부분
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "이메일",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '  *',
                            style: TextStyle(
                              color: Colors.red
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

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

                  // 비밀번호 부분
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "비밀번호",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '  *',
                            style: TextStyle(
                                color: Colors.red
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

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

                  const SizedBox(height: 12),

                  // 비밀번호 확인 부분
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "비밀번호 확인",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '  *',
                            style: TextStyle(
                                color: Colors.red
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _isPasswordHidden2 ? true : false,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "비밀번호를 다시 입력해주세요.",
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
                            _isPasswordHidden2 = !_isPasswordHidden2;
                          });
                        },

                        child: Icon(
                          _isPasswordHidden2
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

                  //이름 부분
                  const SizedBox(height: 12),

                  // 비밀번호 확인 부분
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "이름",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '  *',
                            style: TextStyle(
                                color: Colors.red
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _isPasswordHidden2 ? true : false,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "이름을 입력해주세요.",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
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
                ],
              ),
            ),

            SizedBox(height: 10,),

            Text(
              "휴대폰 번호 해야하는 곳임",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20
              ),
            ),

            SizedBox(height: 10,),

            CheckboxListTile(
              title: const Text(
                '이용약관 및 개인정보처리방침에 동의합니다.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              value: _isChecked,
              activeColor: const Color(0xffdaa84d),
              checkColor: Colors.black,
              controlAffinity: ListTileControlAffinity.leading, // 체크박스를 왼쪽 끝에 배치
              contentPadding: EdgeInsets.zero,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value!;
                });
              },
            ),

            SizedBox(height: 10,),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그인 로직 처리
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffdaa84d),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 10,),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '이미 계정이 있으신가요?',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7)
                  ),
                ),

                SizedBox(width: 10,),

                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        color: Color(0xffdaa84d),
                        fontWeight: FontWeight.bold
                      ),
                    )
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
