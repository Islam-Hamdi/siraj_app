import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';

class CommunityFeedView extends ConsumerStatefulWidget {
  const CommunityFeedView({super.key});

  @override
  ConsumerState<CommunityFeedView> createState() => _CommunityFeedViewState();
}

class _CommunityFeedViewState extends ConsumerState<CommunityFeedView> {
  final ScrollController _scrollController = ScrollController();
  final List<CommunityPost> _posts = [
    CommunityPost(
      id: '1',
      authorName: 'أحمد محمد',
      authorAvatar: '👤',
      timeAgo: 'منذ ساعتين',
      content: 'السلام عليكم إخواني، أريد أن أشارككم تجربتي في تعلم القرآن الكريم. بدأت منذ شهر بحفظ سورة البقرة وأشعر بسكينة عظيمة. هل لديكم نصائح لتحسين الحفظ؟',
      likes: 24,
      comments: 8,
      isLiked: false,
      tags: ['تعلم', 'قرآن', 'حفظ'],
    ),
    CommunityPost(
      id: '2',
      authorName: 'فاطمة علي',
      authorAvatar: '👩',
      timeAgo: 'منذ 4 ساعات',
      content: 'بارك الله فيكم جميعاً. أود أن أسأل عن أفضل الأوقات للدعاء والذكر. سمعت أن هناك أوقات مستجابة، فما هي؟',
      likes: 31,
      comments: 12,
      isLiked: true,
      tags: ['دعاء', 'ذكر', 'أوقات مستجابة'],
    ),
    CommunityPost(
      id: '3',
      authorName: 'محمد الأحمد',
      authorAvatar: '🧔',
      timeAgo: 'منذ يوم',
      content: 'الحمد لله، تمكنت اليوم من أداء صلاة الفجر في المسجد لأول مرة. الشعور رائع والأجواء الروحانية لا توصف. أنصح كل الإخوة بتجربة هذا.',
      likes: 45,
      comments: 15,
      isLiked: false,
      tags: ['صلاة', 'فجر', 'مسجد'],
    ),
    CommunityPost(
      id: '4',
      authorName: 'عائشة حسن',
      authorAvatar: '👩‍🦳',
      timeAgo: 'منذ يومين',
      content: 'شاركوني في الدعاء لوالدي المريض. اللهم اشفه شفاءً لا يغادر سقماً. جزاكم الله خيراً.',
      likes: 67,
      comments: 23,
      isLiked: true,
      tags: ['دعاء', 'مرض', 'والدين'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SirajColors.beige50,
      appBar: AppBar(
        title: const Text(
          'مجتمع سراج',
          style: TextStyle(
            color: SirajColors.sirajBrown900,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: SirajColors.beige50,
        foregroundColor: SirajColors.sirajBrown900,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        color: SirajColors.accentGold,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Community Guidelines Banner
            SliverToBoxAdapter(
              child: _buildGuidelinesBanner(),
            ),
            
            // Create Post Card
            SliverToBoxAdapter(
              child: _buildCreatePostCard(),
            ),
            
            // Posts List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CommunityPostCard(
                      post: _posts[index],
                      onLike: () => _toggleLike(_posts[index]),
                      onComment: () => _showCommentsDialog(_posts[index]),
                      onShare: () => _sharePost(_posts[index]),
                      onReport: () => _reportPost(_posts[index]),
                    ),
                  );
                },
                childCount: _posts.length,
              ),
            ),
            
            // Loading indicator at bottom
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SirajColors.accentGold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(),
        backgroundColor: SirajColors.accentGold,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGuidelinesBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SirajColors.accentGold.withOpacity(0.1),
            SirajColors.sirajBrown700.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SirajColors.accentGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: SirajColors.accentGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'إرشادات المجتمع',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: SirajColors.sirajBrown900,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'نرحب بك في مجتمع سراج. يرجى الالتزام بالأدب الإسلامي والاحترام المتبادل في جميع المشاركات والتعليقات.',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: SirajColors.sirajBrown700,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePostCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: SirajColors.beige100,
            child: Text(
              '👤',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _showCreatePostDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: SirajColors.beige50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SirajColors.nude300,
                    width: 1,
                  ),
                ),
                child: Text(
                  'شارك تجربتك أو اطرح سؤالاً...',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: SirajColors.sirajBrown700.withOpacity(0.7),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshFeed() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, this would fetch new posts from the server
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث المجتمع')),
      );
    }
  }

  void _toggleLike(CommunityPost post) {
    setState(() {
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
    });
  }

  void _showCommentsDialog(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(post: post),
    );
  }

  void _sharePost(CommunityPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ رابط المنشور')),
    );
  }

  void _reportPost(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن المنشور'),
        content: const Text('هل تريد الإبلاغ عن هذا المنشور؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم الإبلاغ عن المنشور')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SirajColors.errorRed,
            ),
            child: const Text('إبلاغ'),
          ),
        ],
      ),
    );
  }

  void _showCreatePostDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostBottomSheet(
        onPostCreated: (content, tags) {
          setState(() {
            _posts.insert(0, CommunityPost(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              authorName: 'أنت',
              authorAvatar: '👤',
              timeAgo: 'الآن',
              content: content,
              likes: 0,
              comments: 0,
              isLiked: false,
              tags: tags,
            ));
          });
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في المجتمع'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'ابحث عن منشور أو موضوع...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية المنشورات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('الأحدث'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('الأكثر إعجاباً'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('الأكثر تعليقاً'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final String timeAgo;
  final String content;
  int likes;
  final int comments;
  bool isLiked;
  final List<String> tags;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.tags,
  });
}

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onReport;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: SirajColors.sirajBrown900.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: SirajColors.beige100,
                child: Text(
                  post.authorAvatar,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: SirajColors.sirajBrown900,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      post.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: SirajColors.sirajBrown700.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') {
                    onReport();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag, color: SirajColors.errorRed),
                        SizedBox(width: 8),
                        Text('إبلاغ'),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: SirajColors.nude300,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Post Content
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: SirajColors.sirajBrown900,
                  height: 1.5,
                ),
          ),
          
          const SizedBox(height: 12),
          
          // Tags
          if (post.tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: SirajColors.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: SirajColors.accentGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '#$tag',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: SirajColors.accentGold,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              )).toList(),
            ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              _buildActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${post.likes}',
                color: post.isLiked ? SirajColors.errorRed : SirajColors.nude300,
                onTap: onLike,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${post.comments}',
                color: SirajColors.nude300,
                onTap: onComment,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: 'مشاركة',
                color: SirajColors.nude300,
                onTap: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CommentsBottomSheet extends StatelessWidget {
  final CommunityPost post;

  const CommentsBottomSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: SirajColors.beige50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SirajColors.nude300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'التعليقات',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: SirajColors.sirajBrown900,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('لا توجد تعليقات بعد'),
            ),
          ),
        ],
      ),
    );
  }
}

class CreatePostBottomSheet extends StatefulWidget {
  final Function(String content, List<String> tags) onPostCreated;

  const CreatePostBottomSheet({super.key, required this.onPostCreated});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: SirajColors.beige50,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: SirajColors.nude300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                Text(
                  'منشور جديد',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: SirajColors.sirajBrown900,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    final content = _contentController.text.trim();
                    final tags = _tagsController.text
                        .split(',')
                        .map((tag) => tag.trim())
                        .where((tag) => tag.isNotEmpty)
                        .toList();
                    
                    if (content.isNotEmpty) {
                      widget.onPostCreated(content, tags);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('نشر'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'شارك تجربتك أو اطرح سؤالاً...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: 'العلامات (مفصولة بفواصل)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}

