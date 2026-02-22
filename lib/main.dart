import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

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
      theme: ThemeData(
        useMaterial3: false,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WebViewScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2c2c2c),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFfb6d0e),
                        shape: ContinuousRectangleBorder(
                          side: const BorderSide(color: Colors.orange, width: 2.0),
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Center(
                        child: ClipPath(
                          clipper: ShapeBorderClipper(
                            shape: ContinuousRectangleBorder(
                              side: const BorderSide(color: Colors.orange, width: 2.0),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Image.asset(
                            'assets/icon/icon.png',
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFfb6d0e),
                                  shape: ContinuousRectangleBorder(
                                    side: const BorderSide(color: Colors.orange, width: 2.0),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.article,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'تجديد',
                      style: GoogleFonts.tajawal(
                        color: const Color(0xFFefefef),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        'أول مجلة إلكترونية تقدم الابتكار والتطوير في عالم التصميم الواسع والإعلان',
                        style: GoogleFonts.tajawal(
                          color: const Color(0xFFefefef),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Column(
                children: [
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.tajawal(
                      color: const Color(0xFFfb6d0e),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'All Rights Reserved - Tajdeedpro Mag - 2026',
                    style: GoogleFonts.tajawal(
                      color: const Color(0xFFefefef),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
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

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'NativeShareChannel',
        onMessageReceived: (JavaScriptMessage message) async {
          await Share.share(message.message, subject: 'تجديد');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0.0;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            _injectCustomStyles();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url; // شلنا الـ toLowerCase عشان ما يخرب الروابط الحساسة

            // معالجة روابط فيسبوك حصراً
            if (url.contains('facebook.com') || url.contains('fb.me') || url.startsWith('intent://')) {
              
              // Fix Facebook Intent (White Screen Issue)
              if (url.startsWith('intent://')) {
                // Use launchUrl directly with intent URL to let Android handle it
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              } else {
                // Handle regular Facebook URLs
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
              
              return NavigationDecision.prevent; // منع الـ WebView من فتح "الطبقة البيضاء"
            }

            // معالجة الواتساب والاتصال
            if (url.contains('api.whatsapp.com') || url.contains('wa.me') || url.startsWith('tel:')) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            // السماح بتصفح المدونة فقط داخل التطبيق
            if (url.contains('tajdeedpro.blogspot.com')) {
              return NavigationDecision.navigate;
            }

            // أي رابط خارجي تاني يفتحه بره
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://tajdeedpro.blogspot.com/'));
  }

  Future<void> _launchExternalURL(String url) async {
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
    return;
  }

  void _injectCustomStyles() {
    _controller.runJavaScript('''
      (function() {
        // 1. Featured Ad Card Navigation - Handle card clicks
        document.addEventListener('click', function(e) {
          var cardLink = e.target.closest('.featured-ad-card-link');
          if (cardLink) {
            // Skip if share icon was clicked (handled separately)
            if (e.target.closest('.share-icon, .share-btn, [class*="share"]')) return;
            
            e.preventDefault();
            var href = cardLink.getAttribute('href') || "";
            if (href) {
              // Force WebView to load the URL to prevent ?m=1 reset
              window.location.href = href;
            }
            return false;
          }
        }, true);

        // 2. Share Icon Listener - Handle share clicks with stopPropagation
        document.addEventListener('click', function(e) {
          var shareIcon = e.target.closest('.share-icon, .share-btn, [class*="share"]');
          if (shareIcon) {
            e.preventDefault();
            e.stopPropagation(); // Prevent card navigation
            
            var href = shareIcon.getAttribute('href') || "";
            var title = document.title;
            var specificUrl = href || window.location.href;
            
            NativeShareChannel.postMessage(title + "|" + specificUrl);
            return false;
          }
        }, true);

        // 3. Footer Share Button Listener (existing functionality)
        document.addEventListener('click', function(e) {
          var shareBtn = e.target.closest('.footer-btn.share-btn');
          if (shareBtn) {
            e.preventDefault();
            e.stopPropagation();
            
            var href = shareBtn.getAttribute('href') || "";
            var title = document.title;
            var specificUrl = href || window.location.href;
            
            NativeShareChannel.postMessage(title + "|" + specificUrl);
            return false;
          }
        }, true);

        // 4. Scroll fix and UI cleanup
        var style = document.createElement('style');
        style.innerHTML = `
          /* Hide scrollbar for Chrome, Safari and Opera */
          ::-webkit-scrollbar {
            display: none !important;
          }
          /* Hide scrollbar for IE, Edge and Firefox */
          html, body {
            -ms-overflow-style: none !important;  /* IE and Edge */
            scrollbar-width: none !important;  /* Firefox */
            overflow-y: scroll !important; /* Force scrolling capability */
            -webkit-overflow-scrolling: touch !important; /* Smooth scrolling for mobile */
          }
          .header-widget, .footer-wrapper, .sidebar-wrapper { display: none !important; }
          #send-to-messenger-button { display: none !important; }
        `;
        document.head.appendChild(style);
      })();
    ''');
  }

  Future<void> _refreshWebView() async {
    await _controller.reload();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF2c2c2c),
        body: Stack(
          children: [
            // Full-screen WebView with RefreshIndicator
            SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshWebView,
                color: const Color(0xFFfb6d0e),
                backgroundColor: const Color(0xFF2c2c2c),
                displacement: 80,
                strokeWidth: 3,
                child: WebViewWidget(
                  controller: _controller,
                ),
              ),
            ),
            // Loading indicator overlay
            if (_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFfb6d0e)),
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
