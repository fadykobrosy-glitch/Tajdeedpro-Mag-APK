import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

void main() {
  runApp(const TajdeedProMagApp());
}

class TajdeedProMagApp extends StatelessWidget {
  const TajdeedProMagApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tajdeed Pro Mag',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: false),
      // البداية مباشرة من شاشة الويب التي تحتوي السبلاش بداخلها
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  double _loadingProgress = 0;
  bool _isPageFinished = false;
  bool _showSplash = true; // للتحكم في ظهور طبقة السبلاش

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF2c2c2c))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isPageFinished = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isPageFinished = true;
              // إخفاء السبلاش بنعومة بعد اكتمال التحميل الأول
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) setState(() => _showSplash = false);
              });
            });
            
            // حقن CSS لإخفاء السكرول بار وتحسين المظهر
            _controller.runJavaScript("""
              var style = document.createElement('style');
              style.innerHTML = '::-webkit-scrollbar { display: none; }';
              document.head.appendChild(style);
            """);
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (request.url.startsWith('https://www.whatsapp.com') || 
                request.url.startsWith('whatsapp://') || 
                !request.url.startsWith('http')) {
              try {
                await launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
              } catch (e) {
                debugPrint("Could not launch $e");
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'share') {
            _handleShare();
          }
        },
      )
      ..loadRequest(Uri.parse('https://www.tajdeedpro.com/'));
  }

  void _handleShare() async {
    try {
      final String result = await _controller.runJavaScriptReturningResult("""
        (function() {
          var linkTag = document.querySelector('link[rel="canonical"]');
          if (linkTag && linkTag.href) return linkTag.href;
          var ogUrl = document.querySelector('meta[property="og:url"]');
          if (ogUrl && ogUrl.content) return ogUrl.content;
          return window.location.href;
        })()
      """) as String;

      final String url = result.replaceAll('"', '').trim();
      if (url.isNotEmpty) {
        await Share.share(url);
      }
    } catch (e) {
      debugPrint("Error sharing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // استخدام PopScope بدلاً من WillPopScope
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF2c2c2c),
        body: Stack(
          children: [
            // الطبقة 1: الموقع (WebView)
            SafeArea(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () => _controller.reload(),
                color: const Color(0xFFfb6d0e),
                backgroundColor: const Color(0xFF2c2c2c),
                child: WebViewWidget(controller: _controller),
              ),
            ),

            // الطبقة 2: واجهة السبلاش سكرين (تختفي عند اكتمال التحميل)
            if (_showSplash)
              AnimatedOpacity(
                opacity: _isPageFinished ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 600),
                child: Container(
                  color: const Color(0xFF2c2c2c),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFfb6d0e),
                            borderRadius: BorderRadius.circular(18), // الزاوية المطلوبة 18
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/images/logo.png',
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Text(
                          "All rights reserved to Tajdeed Pro",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // الطبقة 3: برواز الطاقة (التحميل المحيطي)
            if (!_isPageFinished)
              IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: PerimeterPainter(progress: _loadingProgress),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// الرسام الخاص ببرواز الطاقة
class PerimeterPainter extends CustomPainter {
  final double progress;
  PerimeterPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFFfb6d0e)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round; // لضمان نعومة البداية

    // إضافة تأثير النيون (Glow)
    final shadowPaint = Paint()
      ..color = const Color(0xFFfb6d0e).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    Path pathLeft = Path();
    Path pathRight = Path();

    // نقطة البداية: أسفل المنتصف
    double startX = size.width / 2;
    double startY = size.height;

    // حساب المسافة الكلية المحيطة بنصف شاشة
    double halfPerimeter = (size.width / 2) + size.height + (size.width / 2);
    double currentDist = halfPerimeter * progress;

    // رسم المسارين المتناظرين
    _drawPath(pathLeft, currentDist, size, startX, startY, -1);
    _drawPath(pathRight, currentDist, size, startX, startY, 1);

    canvas.drawPath(pathLeft, shadowPaint);
    canvas.drawPath(pathLeft, paint);
    canvas.drawPath(pathRight, shadowPaint);
    canvas.drawPath(pathRight, paint);
    
    // رسم الرأس المدبب يدويًا (اختياري لزيادة الجمالية)
  }

  void _drawPath(Path path, double dist, Size size, double startX, double startY, int direction) {
    path.moveTo(startX, startY);
    
    // 1. الجزء السفلي (من المنتصف للزاوية)
    double segment1 = size.width / 2;
    if (dist > 0) {
      double d = math.min(dist, segment1);
      path.lineTo(startX + (d * direction), startY);
    }

    // 2. الجزء الجانبي (للأعلى)
    if (dist > segment1) {
      double d = math.min(dist - segment1, size.height);
      path.lineTo(startX + (segment1 * direction), startY - d);
    }

    // 3. الجزء العلوي (للمنتصف فوق)
    if (dist > segment1 + size.height) {
      double d = math.min(dist - (segment1 + size.height), segment1);
      path.lineTo((startX + (segment1 * direction)) - (d * direction), 0);
    }
  }

  @override
  bool shouldRepaint(PerimeterPainter oldDelegate) => oldDelegate.progress != progress;
}
