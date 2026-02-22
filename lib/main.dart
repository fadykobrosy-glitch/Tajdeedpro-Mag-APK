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
  ..setBackgroundColor(const Color(0xFF2c2c2c))
  // قناة المشاركة الوحيدة والنظيفة
  ..addJavaScriptChannel(
    'NativeShareChannel',
    onMessageReceived: (JavaScriptMessage message) {
      Share.share(message.message);
    },
  )
  ..setNavigationDelegate(
    NavigationDelegate(
      onNavigationRequest: (NavigationRequest request) async {
        final url = request.url;

        // 1. الحل الجذري والنهائي لروابط فيسبوك (Intent) والشاشة البيضاء
        if (url.startsWith('intent://')) {
          try {
            // تفكيك الرابط لنص، استبدال intent بـ https، وحذف كود الأندرويد اللي بيعمل كراش
            String cleanUrl = url.replaceFirst('intent://', 'https://').split('#Intent')[0];
            await launchUrl(Uri.parse(cleanUrl), mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint('Error launching Facebook: $e');
          }
          return NavigationDecision.prevent; // منع الشاشة البيضاء نهائياً
        }

        // 2. معالجة أي تطبيق خارجي تاني (واتساب، تيليجرام...)
        if (!url.startsWith('http') && !url.startsWith('https')) {
          try {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint('Error launching External App: $e');
          }
          return NavigationDecision.prevent;
        }

        // السماح بالتنقل الطبيعي داخل الموقع
        return NavigationDecision.navigate;
      },
      onPageFinished: (String url) {
        // 3. الحل النهائي للسكرول والمشاركة (بدون خنق الصفحة)
        _controller.runJavaScript('''
          // حقن ستايل نظيف جداً: بيخفي الهيدر والفوتير والمسطرة، بس بيترك السكرول شغال
          var style = document.createElement('style');
          style.innerHTML = `
            ::-webkit-scrollbar { display: none !important; }
            html, body {
              -ms-overflow-style: none !important;
              scrollbar-width: none !important;
              /* ممنوع استخدام overflow: hidden هون أبداً */
            }
            /* إذا في كلاسات بدك تخفيها متل الهيدر ضيفها هون، مثال: */
            .header-widget, .footer-widget { display: none !important; }
          `;
          document.head.appendChild(style);

          // 4. تشغيل زر المشاركة في الصفحة الرئيسية والمودال
          document.addEventListener('click', function(e) {
            const shareBtn = e.target.closest('.footer-btn.share-btn');
            if (shareBtn) {
              e.preventDefault();
              e.stopPropagation();
              
              // استخراج محسّن للرابط لجميع أنواع البطاقات
              const parentCard = shareBtn.closest('.article-card');
              let linkToShare = '';
              
              if (parentCard) {
                // الطريقة 1: data-post-url attribute (المصدر الأساسي)
                linkToShare = parentCard.getAttribute('data-post-url');
                
                // الطريقة 2: البحث عن رابط التعليقات في المحتوى
                if (!linkToShare) {
                  const cardContent = parentCard.querySelector('.card-full-body');
                  if (cardContent) {
                    const content = cardContent.innerHTML;
                    const regex = /<!--\s*COMMENTS:\s*(https?:\/\/[^\s--]+)\s*-->/;
                    const match = content.match(regex);
                    if (match && match[1]) {
                      linkToShare = match[1];
                    }
                  }
                }
                
                // الطريقة 3: البحث عن روابط داخل البطاقة
                if (!linkToShare) {
                  const linkElement = parentCard.querySelector('a[href*="tajdeedpro.blogspot.com"]');
                  if (linkElement) {
                    linkToShare = linkElement.href;
                  }
                }
                
                // الطريقة 4: الرجوع للرابط الحالي (آخر خيار)
                if (!linkToShare) {
                  linkToShare = window.location.href;
                }
              } else {
                linkToShare = window.location.href;
              }
              
              console.log('🔗 Extracted share URL:', linkToShare);
              
              // إرسال الرابط للدارت
              NativeShareChannel.postMessage(linkToShare);
            }
          });

          // 5. معالج خاص للمودال - إعادة ربط معالجات الأحداث بعد الاستنساخ
          function attachModalShareHandlers() {
            const modalShareBtn = document.querySelector('#modalFooterActions .footer-btn.share-btn');
            if (modalShareBtn) {
              console.log('🔧 Attaching modal share handler');
              modalShareBtn.onclick = function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                // الحصول على الرابط من خاصية المودال
                const modal = document.getElementById('articleModal');
                const linkToShare = modal.getAttribute('data-current-url') || window.location.href;
                
                console.log('🔗 Modal share URL:', linkToShare);
                NativeShareChannel.postMessage(linkToShare);
              };
            }
          }

          // مراقبة فتح المودال لإعادة ربط المعالجات
          const modalObserver = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList') {
                const modalActions = document.getElementById('modalFooterActions');
                if (modalActions && modalActions.innerHTML.includes('share-btn')) {
                  setTimeout(attachModalShareHandlers, 100);
                }
              }
            });
          });

          // بدء مراقبة المودال
          const modal = document.getElementById('articleModal');
          if (modal) {
            modalObserver.observe(document.getElementById('modalFooterActions'), {
              childList: true,
              subtree: true
            });
          }
        ''');
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
