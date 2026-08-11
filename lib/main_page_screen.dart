import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:net_2026/detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_animated_indexed_stack/easy_animated_indexed_stack.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> {
  //현재 페이지
  int _currentIndex = 0;

  // 전체 상품 목록을 담을 변수
  List<dynamic> product = [];

  // 선택된 옵션 인덱스 (0: 인기 매물, 1: 최신 매물, 2: 가격 인하)
  int _selectedOptionIndex = 0;

  // 검색 컨트롤러
  final TextEditingController _ctrl = TextEditingController();

  String _token = ""; // 토큰을 담을 변수

  // 로컬에 있는 토큰을 가져오는 함수
  Future<void> fetchToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? "토큰 없음";
  }

  // 정보를 불러오는 함수
  Future<void> fetchData() async {
    final url = "https://connexChat-server.onrender.com/vinyl/products";
    await fetchToken(); // await를 반드시 붙여 토큰 할당 완료 후 진행

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $_token"},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        setState(() {
          // API 응답 구조에 맞게 data 리스트 할당
          product = parsedJson['data'] ?? [];
        });
      } else {
        print("통신 오류, 오류 코드 ${response.statusCode}");
      }
    } catch (e) {
      print("통신 실패 $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313), // 배경색
      body: EasyAnimatedIndexedStack(
        index: _currentIndex,

        children: [
          //첫 페이지 : 홈
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // 상단 로고 및 알림 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: Image.asset(
                          'assets/images/logo_vertical.png',
                          width: 100,
                          height: 50,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  // 검색 창
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "앨범명, 아티스트 검색",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.qr_code,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 장르별 둘러보기 타이틀
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      child: const Text(
                        '장르별 둘러보기',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // 장르 버튼 1번째 줄
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCard(
                        imgPath: "assets/icons/rock.svg",
                        text: "Rock",
                      ),
                      _buildCard(
                        imgPath: "assets/icons/jazz.svg",
                        text: "Jazz",
                      ),
                      _buildCard(imgPath: "assets/icons/pop.svg", text: "Pop"),
                      _buildCard(
                        imgPath: "assets/icons/hip-hop.svg",
                        text: "Hip-hop",
                      ),
                    ],
                  ),

                  // 장르 버튼 2번째 줄
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCard(
                        imgPath: "assets/icons/electronic.svg",
                        text: "Electronic",
                      ),
                      _buildCard(
                        imgPath: "assets/icons/classical.svg",
                        text: "Classical",
                      ),
                      _buildCard(
                        imgPath: "assets/icons/rnb-soul.svg",
                        text: "R&B-Soul",
                      ),
                      _buildCard(imgPath: "assets/icons/etc.svg", text: "기타"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 옵션 피터 및 전체보기
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildOption(text: "인기 매물", index: 0),
                      _buildOption(text: "최신 등록", index: 1),
                      _buildOption(text: "가격 인하", index: 2),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () {},
                          child: Row(
                            children: [
                              Text(
                                '전체 보기',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_outlined,
                                color: Colors.white.withOpacity(0.5),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // 이미지 디자인 카드 영역(가로 스크롤)
                  product.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(30.0),
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox(
                          height: 275,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: product.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _buildProductCard(product[index]),
                              );
                            },
                          ),
                        ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          //여기까지가 인덱스 1

          //검색화면
          const Center(
            child: Text(
              "검색 페이지, 내일 하면 됨",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          //마이페이지 화면
          const Center(
            child: Text(
              "마이페이지, 내일 하면 됨",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF131313),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: const Color(0xFF1E1E1E),
            selectedItemColor: Colors.orange,
            unselectedItemColor: Colors.grey,
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "홈",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                label: "검색",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "마이페이지",
              ),
            ],
          ),
        )
    );
  }

  // Stack을 이용한 상품 카드 레이아웃 구현
  Widget _buildProductCard(Map<String, dynamic> item) {
    // 천 단위 쉼표 포맷팅 함수
    String formatPrice(dynamic price) {
      if (price == null) return '0';
      return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }

    return GestureDetector(
      onTap: () {
        //누르면 상세페이지로 이동해야함
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(id: item['id'])));
      },

      child: Container(
        width: 170, // 카드 폭
        decoration: BoxDecoration(
          color: const Color(0xFF242424), // 하단 배경색
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 상단 이미지 및 배지 영역 (Stack)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  // (1) 앨범 이미지
                  Image.network(
                    item['albumImage'] ?? '',
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 170,
                      color: Colors.grey[800],
                      child: const Icon(Icons.album, color: Colors.white),
                    ),
                  ),

                  // (2) 상태 배지 (Positioned)
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['condition'] ?? 'M', // M, NM, VG+ 등
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. 하단 정보 영역 (Column)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 앨범 제목
                  Text(
                    item['albumName'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 아티스트명
                  Text(
                    item['artist'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // 가격 (금색)
                  Text(
                    "₩ ${formatPrice(item['price'])}",
                    style: const TextStyle(
                      color: Color(0xFFDAA84D),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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

  Widget _buildCard({required String imgPath, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 85,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(imgPath, width: 32, height: 32),
                Text(
                  text,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption({required String text, required int index}) {
    final bool isSelected = _selectedOptionIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedOpacity(
        opacity: isSelected ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_selectedOptionIndex != index) {
              setState(() {
                _selectedOptionIndex = index;
              });
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 60,
                height: 2,
                color: isSelected ? Colors.orangeAccent : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
