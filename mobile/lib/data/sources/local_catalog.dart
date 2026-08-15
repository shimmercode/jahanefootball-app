import '../models/category.dart';
import '../models/home_feed.dart';
import '../models/match.dart';
import '../models/news.dart';

/// Bundled catalog so Home / News / Football always render,
/// even when the production API or TheSportsDB is unreachable.
class LocalCatalog {
  static final DateTime _now = DateTime.now();

  static List<NewsCategory> categories() => const <NewsCategory>[
        NewsCategory(id: 'all', name: 'همه', slug: 'all'),
        NewsCategory(id: 'iran', name: 'ایران', slug: 'iran'),
        NewsCategory(id: 'world', name: 'جهان', slug: 'world'),
        NewsCategory(id: 'transfers', name: 'نقل‌وانتقالات', slug: 'transfers'),
        NewsCategory(id: 'ucl', name: 'اروپا', slug: 'ucl'),
        NewsCategory(id: 'national', name: 'تیم ملی', slug: 'national'),
      ];

  static List<NewsArticle> articles() {
    return <NewsArticle>[
      NewsArticle(
        id: '1',
        title: 'دربی تهران؛ نبرد حیثیت در آزادی',
        excerpt:
            'پرسپولیس و استقلال برای صدر جدول لیگ برتر در ورزشگاه آزادی به میدان می‌روند.',
        content:
            '''<p>هشتاد و چهارمین دربی پایتخت در شرایطی برگزار می‌شود که هر دو تیم برای تثبیت جایگاه‌شان در بالای جدول به سه امتیاز این دیدار نیاز دارند.</p>
<p>سرمربی پرسپولیس در نشست خبری تأکید کرد تمرکز تیم روی بازی خودشان است، نه حواشی. در سوی مقابل استقلال با خط حمله احیا شده وارد میدان می‌شود.</p>
<p>پیش‌بینی می‌شود بیش از ۷۰ هزار هوادار در آزادی حاضر باشند. داور دیدار از سوی کمیته داوران اعلام شده و VAR نیز فعال خواهد بود.</p>
<p>جهان فوتبال این بازی را به‌صورت لحظه‌به‌لحظه پوشش می‌دهد.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(hours: 2)),
        category: 'ایران',
        categoryId: 'iran',
        featured: true,
        tags: const <String>['دربی', 'پرسپولیس', 'استقلال'],
      ),
      NewsArticle(
        id: '2',
        title: 'تیم ملی در مسیر آماده‌سازی فصل جدید',
        excerpt: 'کادر فنی فهرست اولیه بازیکنان را برای اردوی بعدی اعلام کرد.',
        content:
            '''<p>فدراسیون فوتبال زمان اردوی بعدی تیم ملی را مشخص کرد. تمرکز این دوره روی هماهنگی خط دفاع و ضربات ایستگاهی است.</p>
<p>چند چهره جوان لیگ برتر برای اولین بار به اردو دعوت شده‌اند. بازی تدارکاتی نیز در حال هماهنگی است.</p>
<p>با نزدیک شدن به پنجره‌های رسمی، ترکیب اصلی هنوز قطعی نیست و رقابت برای پست هافبک دفاعی جدی است.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(hours: 5)),
        category: 'تیم ملی',
        categoryId: 'national',
        featured: true,
        tags: const <String>['تیم ملی', 'اردو'],
      ),
      NewsArticle(
        id: '3',
        title: 'پنجره‌ی نقل‌وانتقالات؛ مقصد ستاره‌های لیگ برتر',
        excerpt: 'بازار تابستانی باشگاه‌های ایرانی با چند پیشنهاد خارجی داغ شده است.',
        content:
            '''<p>چند مهاجم لیگ برتر پیشنهادهایی از امارات و قطر دریافت کرده‌اند. باشگاه‌ها برای حفظ بازیکنان کلیدی بندهای جدید قرارداد را فعال کرده‌اند.</p>
<p>در خط دفاع هم رقابت برای جذب یک مدافع میانی آزاد بالاست. جهان فوتبال صحت پیشنهادها را از منابع باشگاهی پیگیری می‌کند.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(hours: 8)),
        category: 'نقل‌وانتقالات',
        categoryId: 'transfers',
        featured: true,
        tags: const <String>['نقل‌وانتقالات'],
      ),
      NewsArticle(
        id: '4',
        title: 'لیگ قهرمانان اروپا؛ شب‌های بزرگ از راه رسید',
        excerpt: 'مرحله گروهی با تقابل‌های مدعیان سنتی و تازه‌واردها آغاز می‌شود.',
        content:
            '''<p>قرعه‌کشی مرحله لیگ، جدال‌های جذابی میان باشگاه‌های اسپانیا، انگلیس و آلمان رقم زده است.</p>
<p>کارشناسان جهان فوتبال شانس مدعیان را بررسی کرده‌اند: عمق نیمکت و ثبات دفاعی، کلید صعود خواهد بود.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(hours: 12)),
        category: 'اروپا',
        categoryId: 'ucl',
        tags: const <String>['اروپا', 'لیگ قهرمانان'],
      ),
      NewsArticle(
        id: '5',
        title: 'سپاهان و تراکتور؛ نبرد سخت هفته',
        excerpt: 'هفته چهارم لیگ برتر با دیدار مدعیان اصفهان و تبریز پیگیری می‌شود.',
        content:
            '''<p>سپاهان در خانه به‌دنبال حفظ روند امتیازگیری است و تراکتور با انگیزه صعود به صدر به اصفهان سفر می‌کند.</p>
<p>غیبت یک هافبک کلیدی سپاهان معادلات میانه میدان را تغییر داده است.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1489944440615-453fc2b6a9a9?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(hours: 16)),
        category: 'ایران',
        categoryId: 'iran',
        tags: const <String>['سپاهان', 'تراکتور'],
      ),
      NewsArticle(
        id: '6',
        title: 'آنالیز تاکتیکی: پرس از بالا در لیگ برتر',
        excerpt: 'چرا تیم‌هایی که پرس هماهنگ دارند، مالکیت حریف را خفه می‌کنند؟',
        content:
            '''<p>بررسی داده‌های هفته‌های اخیر نشان می‌دهد تیم‌هایی که پرس را پس از از دست دادن توپ در کمتر از پنج ثانیه شروع می‌کنند، موقعیت‌های بیشتری می‌سازند.</p>
<p>جهان فوتبال سه الگوی موفق پرس در لیگ ایران را بررسی کرده است.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1517927033932-b3d18e61fb3a?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 1)),
        category: 'ایران',
        categoryId: 'iran',
        tags: const <String>['آنالیز'],
      ),
      NewsArticle(
        id: '7',
        title: 'ستاره جوان لیگ جزیره در رادار باشگاه‌های بزرگ',
        excerpt: 'عملکرد درخشان یک وینگر ۲۰ ساله توجه باشگاه‌های مادرید و مونیخ را جلب کرده است.',
        content:
            '''<p>آمار گل‌سازی این بازیکن در ده بازی اخیر بالاتر از میانگین لیگ است. نمایندگان چند باشگاه بازی‌های او را از نزدیک دیده‌اند.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 1, hours: 4)),
        category: 'جهان',
        categoryId: 'world',
        tags: const <String>['اروپا', 'نقل‌وانتقالات'],
      ),
      NewsArticle(
        id: '8',
        title: 'گل‌گهر و فولاد؛ نبرد میانه جدول',
        excerpt: 'هر دو تیم برای فاصله گرفتن از منطقه خطر به امتیاز نیاز دارند.',
        content:
            '''<p>بازی در سیرجان برگزار می‌شود. فولاد با تغییرات خط حمله به‌دنبال اولین برد خارج از خانه است.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba6851?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 2)),
        category: 'ایران',
        categoryId: 'iran',
        tags: const <String>['لیگ برتر'],
      ),
      NewsArticle(
        id: '9',
        title: 'چگونه VAR قضاوت دربی را تغییر داد؟',
        excerpt: 'نگاهی به تصمیم‌های جنجالی و استاندارد بررسی صحنه‌ها.',
        content:
            '''<p>کمیته داوران کلیپ تصمیم‌های کلیدی هفته گذشته را منتشر کرد. جهان فوتبال این صحنه‌ها را با قوانین IFAB تطبیق داده است.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 2, hours: 6)),
        category: 'ایران',
        categoryId: 'iran',
        tags: const <String>['داوری', 'VAR'],
      ),
      NewsArticle(
        id: '10',
        title: 'برترین گل‌های هفته اروپا',
        excerpt: 'از شوت از راه دور تا حرکت انفرادی؛ پنج گل منتخب تحریریه.',
        content:
            '''<p>هیئت تحریریه جهان فوتبال پنج گل برتر هفته لیگ‌های معتبر اروپا را انتخاب کرده است. ویدیوها در نسخه وب قابل مشاهده است.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 3)),
        category: 'جهان',
        categoryId: 'world',
        tags: const <String>['گل', 'اروپا'],
      ),
      NewsArticle(
        id: '11',
        title: 'باشگاه‌ها برای فصل جدید چه تغییری در بدنسازی دادند؟',
        excerpt: 'برنامه آماده‌سازی تابستانی کوتاه‌تر، اما شدت بالاتر.',
        content:
            '''<p>چند باشگاه لیگ برتر مدل آماده‌سازی را به‌سمت تمرینات تناوبی و پیشگیری از مصدومیت برده‌اند. نتایج اولیه در مسافت طی‌شده بازیکنان دیده می‌شود.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1543326727-cf6c39e8f84c?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 3, hours: 5)),
        category: 'ایران',
        categoryId: 'iran',
        tags: const <String>['بدنسازی'],
      ),
      NewsArticle(
        id: '12',
        title: 'پیش‌بازی: جدال مدعیان قهرمانی در اروپا',
        excerpt: 'ترکیب احتمالی، آمار رودررو و نکات تاکتیکی دیدار بزرگ هفته.',
        content:
            '''<p>دو تیم در پنج تقابل اخیر، چهار بار بازی را با گل زده به پایان رسانده‌اند. نبرد هافبک‌ها تعیین‌کننده ریتم بازی خواهد بود.</p>''',
        imageUrl: 'https://images.unsplash.com/photo-1459865264687-595d652de67e?auto=format&fit=crop&w=1400&q=80',
        publishedAt: _now.subtract(const Duration(days: 4)),
        category: 'اروپا',
        categoryId: 'ucl',
        tags: const <String>['پیش‌بازی'],
      ),
    ];
  }

  static List<FootballMatch> matches() {
    return <FootballMatch>[
      FootballMatch(
        id: 'm1',
        homeTeam: 'پرسپولیس',
        awayTeam: 'استقلال',
        league: 'لیگ برتر ایران',
        kickoff: _now.subtract(const Duration(minutes: 34)),
        homeScore: 1,
        awayScore: 1,
        status: 'live',
        minute: '56',
        venue: 'ورزشگاه آزادی',
      ),
      FootballMatch(
        id: 'm2',
        homeTeam: 'سپاهان',
        awayTeam: 'تراکتور',
        league: 'لیگ برتر ایران',
        kickoff: _now.add(const Duration(hours: 5)),
        status: 'scheduled',
        venue: 'نقش جهان',
      ),
      FootballMatch(
        id: 'm3',
        homeTeam: 'رئال مادرید',
        awayTeam: 'بایرن مونیخ',
        league: 'لیگ قهرمانان اروپا',
        kickoff: _now.add(const Duration(hours: 8)),
        status: 'scheduled',
        venue: ' سانتیاگو برنابئو',
      ),
      FootballMatch(
        id: 'm4',
        homeTeam: 'لیورپول',
        awayTeam: 'آرسنال',
        league: 'لیگ برتر انگلیس',
        kickoff: _now.subtract(const Duration(hours: 3)),
        homeScore: 2,
        awayScore: 1,
        status: 'finished',
        venue: 'آنفیلد',
      ),
      FootballMatch(
        id: 'm5',
        homeTeam: 'بارسلونا',
        awayTeam: 'اتلتیکو',
        league: 'لالیگا',
        kickoff: _now.add(const Duration(days: 1, hours: 2)),
        status: 'scheduled',
        venue: 'المپیک مونجوئیک',
      ),
      FootballMatch(
        id: 'm6',
        homeTeam: 'گل‌گهر',
        awayTeam: 'فولاد',
        league: 'لیگ برتر ایران',
        kickoff: _now.add(const Duration(days: 1, hours: 6)),
        status: 'scheduled',
        venue: 'سیرجان',
      ),
    ];
  }

  static HomeFeed home() {
    final List<NewsArticle> all = articles();
    return HomeFeed(
      featured: all.where((NewsArticle item) => item.featured).toList(),
      latest: all,
      matches: matches(),
      categories: categories(),
    );
  }

  static NewsArticle? byId(String id) {
    try {
      return articles().firstWhere((NewsArticle item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static FootballMatch? matchById(String id) {
    try {
      return matches().firstWhere((FootballMatch item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<NewsArticle> search(String query) {
    final String q = query.trim();
    if (q.isEmpty) {
      return articles();
    }
    return articles().where((NewsArticle item) {
      return item.title.contains(q) ||
          item.excerpt.contains(q) ||
          item.category.contains(q) ||
          item.tags.any((String tag) => tag.contains(q));
    }).toList();
  }
}
