import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isChecked = false;
  bool _isPasswordHidden = true; // 기본적으로 가림 처리
  bool _isPasswordHidden2 = true;

  // 텍스트 필드 컨트롤러
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _passwordConfirmCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();

  // 휴대폰 번호 컨트롤러 및 포커스 노드
  final TextEditingController _phone1Ctrl = TextEditingController();
  final TextEditingController _phone2Ctrl = TextEditingController();
  final TextEditingController _phone3Ctrl = TextEditingController();

  final FocusNode _phone1Focus = FocusNode();
  final FocusNode _phone2Focus = FocusNode();
  final FocusNode _phone3Focus = FocusNode();

  // 최종 휴대폰 번호 조합 문자열
  String get fullPhoneNumber =>
      '${_phone1Ctrl.text}-${_phone2Ctrl.text}-${_phone3Ctrl.text}';

  // 1. 이메일 유효성 검사 (@, . 포함 및 @ 앞에 . 사용 불가)
  bool _isEmailValid(String email) {
    if (!email.contains('@') || !email.contains('.')) return false;
    final atIndex = email.indexOf('@');
    final prefix = email.substring(0, atIndex);
    if (prefix.contains('.')) return false;
    return true;
  }

  // 2. 비밀번호 유효성 검사 (8자 이상, 대/소문자, 숫자, 특수문자 포함)
  bool _isPasswordValid(String password) {
    final regExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    );
    return regExp.hasMatch(password);
  }

  // 3. 이름 유효성 검사 (한글 또는 영문만 허용)
  bool _isNameValid(String name) {
    if (name.isEmpty) return false;
    final regExp = RegExp(r'^[a-zA-Z가-힣]+$');
    return regExp.hasMatch(name);
  }

  // 최종 회원가입 유효성 검사 및 제출 함수
  void checkSignUp() {
    ScaffoldMessenger.of(context).clearSnackBars();

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final passwordConfirm = _passwordConfirmCtrl.text.trim();
    final name = _nameCtrl.text.trim();

    // 1. 이메일 조건 검사
    if (!_isEmailValid(email)) {
      _showSnackBar('올바른 이메일 형식을 입력해주세요.');
      return;
    }

    // 2. 비밀번호 조건 검사
    if (!_isPasswordValid(password)) {
      _showSnackBar('비밀번호는 8자 이상이며, 대/소문자, 숫자, 특수문자를 모두 포함해야 합니다.');
      return;
    }

    // 3. 비밀번호 확인 일치 검사
    if (password != passwordConfirm) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    // 4. 이름 검사
    if (!_isNameValid(name)) {
      _showSnackBar('이름은 한글 또는 영문만 입력 가능합니다.');
      return;
    }

    // 5. 휴대폰 번호 검사
    if (_phone1Ctrl.text.length < 3 ||
        _phone2Ctrl.text.length < 3 ||
        _phone3Ctrl.text.length < 4) {
      _showSnackBar('휴대폰 번호를 올바르게 입력해주세요.');
      return;
    }

    // 6. 약관 동의 검사
    if (!_isChecked) {
      _showSnackBar('서비스를 이용하시려면 약관에 동의하셔야 합니다.');
      return;
    }

    // 모든 유효성 검사 통과 시 REST API 호출
    _processSignUp();
  }

  // 통신 함수 구현 완성
  Future<void> _processSignUp() async {
    final url = Uri.parse("https://connexChat-server.onrender.com/vinyl/auth/signup");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": _emailCtrl.text.trim(),
          "password": _passwordCtrl.text.trim(),
          "name": _nameCtrl.text.trim(),
          "phone": fullPhoneNumber,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) { //API 통신 성공 시
        _showSnackBar('회원가입이 완료되었습니다.');
        Navigator.pop(context); // 로그인 화면으로 이동
      } else {
        // 서버 응답 에러 처리
        final errorData = jsonDecode(response.body);
        _showSnackBar(errorData['message'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('네트워크 오류가 발생했습니다. 다시 시도해 주세요.');
    }
  }

  // 메시지 출력 공통 함수
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _nameCtrl.dispose();

    _phone1Ctrl.dispose();
    _phone2Ctrl.dispose();
    _phone3Ctrl.dispose();
    _phone1Focus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    super.dispose();
  }

  InputDecoration _phoneInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 상단 이미지
            SizedBox(
              width: double.infinity,
              height: 250,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.3, sigmaY: 2.3),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.0001),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
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
                                color: Colors.white.withValues(alpha: 0.7),
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

            // 타이틀 영역
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '회원 정보를 입력하여 계정을 만들어주세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 입력 폼 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 1. 이메일
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: const [
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
                            style: TextStyle(color: Colors.red),
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
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. 비밀번호
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: const [
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
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: _isPasswordHidden,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "비밀번호를 입력해주세요.",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
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
                          color: Colors.white70,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. 비밀번호 확인
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: const [
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
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: _passwordConfirmCtrl,
                    obscureText: _isPasswordHidden2,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "비밀번호를 다시 입력해주세요.",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
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
                          color: Colors.white70,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. 이름
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: const [
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
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "이름을 입력해주세요.",
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 5. 휴대폰 번호
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: const [
                          Text(
                            "휴대폰 번호",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '  *',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // 번호 1 (010)
                      Expanded(
                        child: TextField(
                          controller: _phone1Ctrl,
                          focusNode: _phone1Focus,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 3,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _phoneInputDecoration(),
                          onChanged: (val) {
                            // 3자가 채워지고, 사용자가 해당 칸에 포커스를 두고 있을 때만 다음 칸으로 이동
                            if (val.length == 3 && _phone1Focus.hasFocus) {
                              FocusScope.of(context).requestFocus(_phone2Focus);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // 번호 2 (중간 자리)
                      Expanded(
                        child: TextField(
                          controller: _phone2Ctrl,
                          focusNode: _phone2Focus,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 4,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _phoneInputDecoration(),
                          onChanged: (val) {
                            // 4자가 다 채워졌을 때만 다음 칸으로 이동
                            if (val.length == 4 && _phone2Focus.hasFocus) {
                              FocusScope.of(context).requestFocus(_phone3Focus);
                            }
                            // 만약 다 지워서 0자가 되었을 때 이전 칸으로 포커스 이동하고 싶다면 아래 주석 해제
                            else if (val.isEmpty && _phone2Focus.hasFocus) {
                              FocusScope.of(context).requestFocus(_phone1Focus);
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // 번호 3 (끝 자리)
                      Expanded(
                        child: TextField(
                          controller: _phone3Ctrl,
                          focusNode: _phone3Focus,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 4,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: _phoneInputDecoration(),
                          onChanged: (val) {
                            // 만약 다 지워서 0자가 되었을 때 이전 칸으로 포커스 이동하고 싶다면 아래 주석 해제
                            // if (val.isEmpty && _phone3Focus.hasFocus) {
                            //   FocusScope.of(context).requestFocus(_phone2Focus);
                            // }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 이용약관 동의
                  CheckboxListTile(
                    title: const Text(
                      '이용약관 및 개인정보처리방침에 동의합니다.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    value: _isChecked,
                    activeColor: const Color(0xffdaa84d),
                    checkColor: Colors.black,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // 회원가입 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        checkSignUp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffdaa84d),
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

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '이미 계정이 있으신가요?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '로그인',
                          style: TextStyle(
                            color: Color(0xffdaa84d),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}