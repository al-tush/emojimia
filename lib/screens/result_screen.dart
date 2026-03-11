import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../models/hume_result.dart';
import '../utils/emotion_translations.dart';
import '../utils/image_saver.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.imageBytes, this.result, this.error});

  final Uint8List imageBytes;
  final HumeResult? result;
  final String? error;

  static const _emotionToSeed = {
    'Joy': 'happy',
    'Amusement': 'amused',
    'Excitement': 'excited',
    'Ecstasy': 'ecstatic',
    'Contentment': 'content',
    'Satisfaction': 'satisfied',
    'Triumph': 'triumph',
    'Pride': 'proud',
    'Relief': 'relieved',
    'Calmness': 'calm',
    'Sadness': 'sad',
    'Distress': 'distress',
    'Disappointment': 'disappointed',
    'Guilt': 'guilty',
    'Shame': 'ashamed',
    'Embarrassment': 'embarrassed',
    'Nostalgia': 'nostalgic',
    'Anger': 'angry',
    'Disgust': 'disgusted',
    'Contempt': 'contempt',
    'Horror': 'horror',
    'Fear': 'scared',
    'Anxiety': 'anxious',
    'Doubt': 'doubtful',
    'Confusion': 'confused',
    'Surprise (positive)': 'surprised_happy',
    'Surprise (negative)': 'surprised_sad',
    'Awe': 'awe',
    'Admiration': 'admiring',
    'Adoration': 'adoring',
    'Love': 'loving',
    'Romance': 'romantic',
    'Desire': 'desire',
    'Craving': 'craving',
    'Envy': 'envious',
    'Boredom': 'bored',
    'Tiredness': 'tired',
    'Interest': 'interested',
    'Concentration': 'focused',
    'Contemplation': 'thinking',
    'Determination': 'determined',
    'Realization': 'realization',
    'Awkwardness': 'awkward',
    'Empathic Pain': 'empathy',
    'Sympathy': 'sympathetic',
    'Pain': 'pain',
    'Entrancement': 'entranced',
    'Aesthetic Appreciation': 'aesthetic',
  };

  String get _cartoonSeed {
    final dominant = result?.dominantEmotionName ?? 'neutral';
    return _emotionToSeed[dominant] ?? dominant.toLowerCase().replaceAll(' ', '_');
  }

  String get _cartoonUrl {
    final seed = Uri.encodeComponent(_cartoonSeed);
    return 'https://api.dicebear.com/9.x/fun-emoji/svg?seed=$seed&size=200';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат анализа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'На главную',
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) _ErrorBanner(message: error!),
            if (error != null) const SizedBox(height: 16),
            _PhotoCard(imageBytes: imageBytes),
            const SizedBox(height: 16),
            if (result != null) ...[
              _EmotionsCard(emotions: result!.topEmotions),
              const SizedBox(height: 12),
              if (result!.topDescriptions.isNotEmpty) _DescriptionsCard(descriptions: result!.topDescriptions),
              if (result!.topDescriptions.isNotEmpty) const SizedBox(height: 12),
              if (result!.topFacs.isNotEmpty) _FacsCard(facs: result!.topFacs),
              if (result!.topFacs.isNotEmpty) const SizedBox(height: 12),
              _EmojiCloudCard(emotions: result!.topEmotions),
              const SizedBox(height: 12),
              _ShareSection(emotions: result!.topEmotions),
              const SizedBox(height: 12),
              _AvatarCard(cartoonUrl: _cartoonUrl, seed: _cartoonSeed),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.imageBytes});
  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Ваш снимок',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          AspectRatio(aspectRatio: 1, child: Image.memory(imageBytes, fit: BoxFit.cover)),
        ],
      ),
    );
  }
}

class _EmotionsCard extends StatelessWidget {
  const _EmotionsCard({required this.emotions});
  final List<EmotionScore> emotions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Топ-5 эмоций',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...emotions.map((e) => _EmotionRow(emotion: e)),
          ],
        ),
      ),
    );
  }
}

class _EmotionRow extends StatelessWidget {
  const _EmotionRow({required this.emotion});
  final EmotionScore emotion;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scorePercent = (emotion.score * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  translateEmotion(emotion.name),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$scorePercent%',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: emotion.score.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Emotion → gradient colour ────────────────────────────────────────────────

Color _emotionColor(String name) {
  const map = {
    // Positive / energetic — amber / orange
    'Joy': Color(0xFFFFB300),
    'Amusement': Color(0xFFFB8C00),
    'Excitement': Color(0xFFEF6C00),
    'Ecstasy': Color(0xFFEC407A),
    'Triumph': Color(0xFFFFD54F),
    'Pride': Color(0xFFFFB74D),
    'Satisfaction': Color(0xFF9CCC65),
    'Contentment': Color(0xFF66BB6A),
    'Surprise (positive)': Color(0xFFFFA726),
    // Love / affection — rose / pink
    'Love': Color(0xFFE91E63),
    'Romance': Color(0xFFC2185B),
    'Adoration': Color(0xFFF06292),
    'Desire': Color(0xFFD81B60),
    'Admiration': Color(0xFFAB47BC),
    // Calm / peaceful — teal / indigo
    'Calmness': Color(0xFF26A69A),
    'Relief': Color(0xFF00ACC1),
    'Awe': Color(0xFF5C6BC0),
    'Aesthetic Appreciation': Color(0xFF7E57C2),
    'Entrancement': Color(0xFF7B1FA2),
    'Nostalgia': Color(0xFF5C6BC0),
    'Sympathy': Color(0xFF7986CB),
    'Empathic Pain': Color(0xFF5E35B1),
    // Cognitive — cyan / blue
    'Interest': Color(0xFF0288D1),
    'Concentration': Color(0xFF0097A7),
    'Contemplation': Color(0xFF00838F),
    'Realization': Color(0xFFF9A825),
    'Determination': Color(0xFFE65100),
    // Sad / blue
    'Sadness': Color(0xFF1E88E5),
    'Disappointment': Color(0xFF1565C0),
    'Distress': Color(0xFF283593),
    'Guilt': Color(0xFF311B92),
    'Shame': Color(0xFF4527A0),
    'Pain': Color(0xFF1A237E),
    // Angry — red
    'Anger': Color(0xFFC62828),
    'Contempt': Color(0xFFB71C1C),
    'Disgust': Color(0xFF558B2F),
    'Horror': Color(0xFF880E4F),
    // Anxious / fear — dark purple
    'Fear': Color(0xFF6A1B9A),
    'Anxiety': Color(0xFF4A148C),
    // Other
    'Embarrassment': Color(0xFFBF360C),
    'Awkwardness': Color(0xFF8D6E63),
    'Confusion': Color(0xFF78909C),
    'Doubt': Color(0xFF546E7A),
    'Boredom': Color(0xFF607D8B),
    'Tiredness': Color(0xFF455A64),
    'Craving': Color(0xFFEF6C00),
    'Envy': Color(0xFF388E3C),
    'Surprise (negative)': Color(0xFF37474F),
  };
  return map[name] ?? const Color(0xFF5E35B1);
}

// ─── Share card ────────────────────────────────────────────────────────────────

class _ShareSection extends StatefulWidget {
  const _ShareSection({required this.emotions});
  final List<EmotionScore> emotions;

  @override
  State<_ShareSection> createState() => _ShareSectionState();
}

class _ShareSectionState extends State<_ShareSection> {
  final _repaintKey = GlobalKey();
  bool _capturing = false;

  Future<void> _captureAndShare() async {
    setState(() => _capturing = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        downloadImageBytes(bytes);
      } else {
        final xFile = XFile.fromData(bytes, mimeType: 'image/png', name: 'emojimia-mood.png');
        await SharePlus.instance.share(ShareParams(files: [xFile], subject: 'Мои эмоции — emojimia'));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.share_outlined, color: colorScheme.tertiary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Карточка для шаринга',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _repaintKey,
              child: _ShareContent(emotions: widget.emotions),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _capturing ? null : _captureAndShare,
              icon: _capturing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(kIsWeb ? Icons.download_outlined : Icons.share),
              label: Text(
                _capturing
                    ? 'Сохранение...'
                    : kIsWeb
                    ? 'Скачать PNG'
                    : 'Поделиться',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareContent extends StatelessWidget {
  const _ShareContent({required this.emotions});
  final List<EmotionScore> emotions;

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) return const SizedBox.shrink();

    final dominant = emotions.first;
    final secondary = emotions.skip(1).take(3).toList();
    final baseColor = _emotionColor(dominant.name);
    final darkColor = Color.lerp(baseColor, Colors.black, 0.45)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [baseColor, darkColor]),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App branding
          Row(
            children: [
              Text(
                'emojimia',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text('✦', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
            ],
          ),
          const SizedBox(height: 28),
          // Dominant emoji + name
          Center(
            child: Column(
              children: [
                Text(
                  emotionEmoji(dominant.name),
                  style: const TextStyle(fontSize: 88, height: 1.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  translateEmotion(dominant.name),
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(dominant.score * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Secondary emotions — frosted panel
          if (secondary.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: secondary
                    .map(
                      (e) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emotionEmoji(e.name), style: const TextStyle(fontSize: 30, height: 1.0)),
                          const SizedBox(height: 5),
                          Text(
                            translateEmotion(e.name),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(e.score * 100).toStringAsFixed(0)}%',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 10),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 20),
          // Brand footer
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFFBC0D), borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'M',
                  style: TextStyle(
                    color: const Color(0xFFDA291C),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.25), offset: const Offset(1, 1), blurRadius: 2),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'влюблены в вас',
                  style: TextStyle(
                    color: Color(0xFFDA291C),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _EmojiCloudCard extends StatelessWidget {
  const _EmojiCloudCard({required this.emotions});
  final List<EmotionScore> emotions;

  @override
  Widget build(BuildContext context) {
    if (emotions.isEmpty) return const SizedBox.shrink();

    final dominant = emotions.first;
    final rest = emotions.skip(1).toList();
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('😊', style: TextStyle(fontSize: 20, color: colorScheme.primary)),
                const SizedBox(width: 8),
                Text(
                  'Эмодзи настроения',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DominantEmojiItem(emotion: dominant),
            if (rest.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rest.map((e) => _SecondaryEmojiItem(emotion: e)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DominantEmojiItem extends StatelessWidget {
  const _DominantEmojiItem({required this.emotion});
  final EmotionScore emotion;

  @override
  Widget build(BuildContext context) {
    final percent = (emotion.score * 100).toStringAsFixed(0);
    return Column(
      children: [
        Text(
          emotionEmoji(emotion.name),
          style: const TextStyle(fontSize: 80, height: 1.1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          translateEmotion(emotion.name),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          '$percent%',
          style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _SecondaryEmojiItem extends StatelessWidget {
  const _SecondaryEmojiItem({required this.emotion});
  final EmotionScore emotion;

  @override
  Widget build(BuildContext context) {
    final percent = (emotion.score * 100).toStringAsFixed(0);
    final fontSize = 28.0 + emotion.score * 20;

    return Column(
      children: [
        Text(
          emotionEmoji(emotion.name),
          style: TextStyle(fontSize: fontSize, height: 1.1),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          translateEmotion(emotion.name),
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$percent%',
          style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DescriptionsCard extends StatelessWidget {
  const _DescriptionsCard({required this.descriptions});
  final List<DescriptionScore> descriptions;

  @override
  Widget build(BuildContext context) {
    return _CollapsibleCard(
      icon: Icons.face,
      title: 'Facial Descriptions',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: descriptions.map((d) {
          final scoreText = d.score.toStringAsFixed(3);
          return Chip(
            label: Text('${translateDescription(d.name)} ($scoreText)'),
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.7),
            labelStyle: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSecondaryContainer),
          );
        }).toList(),
      ),
    );
  }
}

class _FacsCard extends StatelessWidget {
  const _FacsCard({required this.facs});
  final List<FacsScore> facs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _CollapsibleCard(
      icon: Icons.grid_view,
      title: 'FACS 2.0 — Action Units',
      child: Column(
        children: facs.map((f) {
          final label = translateFacs(f.name);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f.score.toStringAsFixed(3),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: f.score.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({required this.cartoonUrl, required this.seed});
  final String cartoonUrl;
  final String seed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.tertiary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Твой эмодзи-аватар',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Image.network(
              cartoonUrl,
              height: 180,
              width: 180,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.face, size: 120, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'seed: $seed',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleCard extends StatefulWidget {
  const _CollapsibleCard({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  State<_CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<_CollapsibleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(widget.icon, color: Theme.of(context).colorScheme.secondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: widget.child),
        ],
      ),
    );
  }
}
