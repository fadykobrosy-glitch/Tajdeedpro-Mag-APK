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
        onMessageReceived: (JavaScriptMessage message) {
          _handleWebShare(message.message);
        },
      )
      // Hide scrollbar without breaking pull-to-refresh
      ..runJavaScript('''
        // Hide scrollbar but keep scrolling functionality and pull-to-refresh
        const style = document.createElement('style');
        style.innerHTML = '\n          ::-webkit-scrollbar {\n            display: none !important;\n          }\n          * {\n            scrollbar-width: none !important;\n            -ms-overflow-style: none !important;\n          }\n        ';
        document.head.appendChild(style);
      ''')
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
            
            // Inject JavaScript to enable website share buttons
            const script = `
              window.navigator.share = function(data) {
                const title = data.title || document.title || 'تجديد';
                const url = data.url || window.location.href;
                FlutterShare.postMessage(title + '|' + url);
                return Promise.resolve();
              };
              document.addEventListener('click', function(e) {
                let target = e.target.closest('a, button');
                if (target && (target.href?.includes('share') || target.className?.includes('share'))) {
                  const url = window.location.href;
                  const title = document.title;
                  FlutterShare.postMessage(title + '|' + url);
                }
              }, true);
            `;
            _controller.runJavaScript(script);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url.toLowerCase();
            
            // Handle Facebook URLs with multiple fallbacks
            if (url.contains('facebook.com') || 
                url.contains('fb.me') ||
                url.startsWith('fb://') ||
                url.startsWith('intent://facebook.com') ||
                url.startsWith('intent://www.facebook.com')) {
              
              // Try multiple Facebook app schemes
              final facebookSchemes = [
                'fb://facewebmodal/f?href=${Uri.encodeComponent(request.url)}',
                'fb://profile/',
                'fb://page/',
                'fb://group/',
                'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(request.url)}'
              ];
              
              bool launched = false;
              for (final scheme in facebookSchemes) {
                try {
                  final uri = Uri.parse(scheme);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    launched = true;
                    break;
                  }
                } catch (e) {
                  continue;
                }
              }
              
              // Fallback to browser if all schemes fail
              if (!launched) {
                await _launchExternalURL(request.url);
              }
              
              return NavigationDecision.prevent;
            }
            
            if (url.contains('api.whatsapp.com') || 
                url.contains('wa.me')) {
              _launchExternalURL(request.url);
              return NavigationDecision.prevent;
            }
            
            if (url.startsWith('tel:')) {
              _launchExternalURL(request.url);
              return NavigationDecision.prevent;
            }
            
            // Open non-blog URLs in system browser
            if (!url.contains('tajdeedpro.blogspot.com')) {
              _launchExternalURL(request.url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
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
        await Share.share('$title\n$urlToShare', subject: title);
      }
    } catch (e) {
      debugPrint("Share Error: $e");
    }
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
