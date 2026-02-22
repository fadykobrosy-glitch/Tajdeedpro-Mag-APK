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
        'FlutterShare',
        onMessageReceived: (JavaScriptMessage message) async {
          await _handleWebShare(message.message);
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
              
              String finalUrl = url;

              // إذا كان الرابط هو الـ Intent اللي بعتلي ياه، منفك تشفيره فوراً
              if (url.startsWith('intent://')) {
                RegExp regExp = RegExp(r'intent://([\s\S]*?)#Intent');
                var match = regExp.firstMatch(url);
                if (match != null) {
                  finalUrl = "https://" + match.group(1)!;
                }
              }

              // السر هون: فتح الرابط بمتصفح خارجي نظامي بيعرف يتعامل مع تطبيق فيسبوك
              await launchUrl(
                Uri.parse(finalUrl),
                mode: LaunchMode.externalApplication,
              );
              
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

  Future<void> _handleWebShare(String message) async {
    try {
      String urlToShare = "";
      String title = "تجديد";
      if (message.contains('|')) {
        final data = message.split('|');
        title = data[0];
        urlToShare = data[1];
      } else {
        urlToShare = message;
      }
      
      if (urlToShare.isNotEmpty) {
        // Check if it's a Facebook URL and handle with deep linking
        if (urlToShare.contains('facebook.com')) {
          final String fbScheme = "fb://facewebmodal/f?href=$urlToShare";
          final Uri fbUri = Uri.parse(fbScheme);
          final Uri webUri = Uri.parse(urlToShare);

          try {
            // Try to open Facebook app with deep link
            bool launched = await launchUrl(
              fbUri,
              mode: LaunchMode.externalNonBrowserApplication,
            );

            // Fallback to browser if Facebook app not installed
            if (!launched) {
              await launchUrl(webUri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            // Final fallback to native share
            await Share.share('$title\n$urlToShare', subject: title);
          }
        } else {
          // For non-Facebook URLs, use native share
          await Share.share('$title\n$urlToShare', subject: title);
        }
      }
    } catch (e) {
      debugPrint("Share Error: $e");
    }
  }

  void _injectCustomStyles() {
    _controller.runJavaScript('''
      (function() {
        // 1. Override navigator.share for all share scenarios
        window.navigator.share = function(data) {
          const title = data.title || document.title || 'تجديد';
          const url = data.url || window.location.href;
          FlutterShare.postMessage(title + '|' + url);
          return Promise.resolve();
        };

        // 2. Enhanced click detection for all share button types
        document.addEventListener('click', function(e) {
          var anchor = e.target.closest('a');
          var button = e.target.closest('button');
          
          // Handle anchor links with share URLs
          if (anchor) {
            var href = anchor.getAttribute('href') || "";
            if (href.includes('facebook.com/share') || href.includes('api.whatsapp.com/send') || 
                href.includes('twitter.com/intent') || href.includes('telegram.me')) {
              e.preventDefault();
              var title = document.title;
              FlutterShare.postMessage(title + "|" + href);
              return false;
            }
          }
          
          // Handle buttons with share-related attributes or text
          if (button) {
            var text = button.innerText || button.textContent || "";
            var className = button.className || "";
            if (text.includes('مشاركة') || text.includes('share') || 
                className.includes('share') || button.getAttribute('data-share')) {
              e.preventDefault();
              e.stopPropagation();
              var title = document.title;
              var url = window.location.href;
              FlutterShare.postMessage(title + "|" + url);
              return false;
            }
          }
        }, true);

        // 3. إخفاء العناصر غير المرغوبة (تنسيق الصفحة)
        var style = document.createElement('style');
        style.innerHTML = `
          * { -webkit-scrollbar { display: none !important; } scrollbar-width: none !important; -ms-overflow-style: none !important; }
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
