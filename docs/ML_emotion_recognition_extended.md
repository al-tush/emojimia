# ML-решения для распознавания большого числа эмоций (10–100+ категорий)

Список моделей, датасетов и API, которые распознают **значительно больше эмоций**, чем классические 6–8 базовых (по Экману), с краткими описаниями и ссылками. Учтены только те решения, где эмоции заданы явной таксономией или размерностью и где есть документация/исследования.

---

## Сводная таблица

| Решение | Модальность | Число эмоций/измерений | Тип | Доступ |
|--------|-------------|-------------------------|-----|--------|
| **Hume AI Expression Measurement (Face)** | Лицо (изображение/видео) | **48** | API (облако) | Платный API |
| **Emo135** | Лицо | **135** | Датасет | IEEE Dataport |
| **GoEmotions** | Текст | **27 + нейтральный** | Датасет + модели | Открытый (Google) |
| **EmoNet-Voice** | Речь | **40** | Бенчмарк/датасет | Открытый |
| **EMOTIC** | Лицо + контекст сцены | **26** | Датасет | Открытый |
| **AffectNet+** | Лицо | Мягкие метки (много эмоций сразу) | Датасет | Исследования |
| **AffectNet** | Лицо | 8 + Valence/Arousal | Датасет | Открытый |
| **CK+** | Лицо (видео) | 7 | Датасет | Открытый |

Базовый уровень для сравнения: типичные системы FER — **6–8** дискретных эмоций (например, радость, грусть, гнев, удивление, отвращение, страх, нейтральный, презрение).

---

## 1. Hume AI Expression Measurement — лицо (48 измерений)

**Что это:** коммерческий API для оценки эмоциональной экспрессии по лицу (изображения и видео). Около **48 дискретных выражений** с оценкой степени выраженности (score) для каждого.

**Полный список 48 выражений (Hume Face):**  
Admiration, Adoration, Aesthetic Appreciation, Amusement, Anger, Anxiety, Awe, Awkwardness, Boredom, Calmness, Concentration, Contemplation, Confusion, Contempt, Contentment, Craving, Desire, Determination, Disappointment, Disgust, Distress, Doubt, Ecstasy, Embarrassment, Empathic Pain, Entrancement, Envy, Excitement, Fear, Guilt, Horror, Interest, Joy, Love, Nostalgia, Pain, Pride, Realization, Relief, Romance, Sadness, Satisfaction, Shame, Surprise (negative), Surprise (positive), Sympathy, Tiredness, Triumph.

**Дополнительно:**
- Опционально: **FACS 2.0** (Action Units) и **facial descriptions** (Smile, Frown, Grin, Cry, etc.).
- Поддержка Batch (REST) и Streaming (WebSocket).
- Модели построены на многолетних исследованиях в computational emotion science.
- Каждое выражение возвращается как score (насколько аннотатор-человек согласился бы с наличием этого выражения).

**Ссылки:**  
- [Expression Measurement — Face (Hume)](https://dev.hume.ai/docs/expression-measurement/models/face)  
- [Hume AI Expression Measurement](https://hume.ai/expression-measurement)

---

## 2. Emo135 — 135 классов эмоций по лицу

**Что это:** датасет для распознавания мимики с **135 дискретными эмоциональными категориями** и 696 168 изображений лиц. Таксономия опирается на психолингвистические списки эмоциональной лексики (сотни английских терминов эмоций), а не только на базовые эмоции Экмана.

**Особенности:**
- Количество изображений на класс: от ~994 до ~12 794.
- Фокус на семантической детализации эмоций, а не только на 6–8 базовых.
- Подходит для обучения и оценки моделей с большим числом классов (в т.ч. fine-grained FER).

**Доступ:** IEEE Dataport (по условиям портала).

**Ссылка:**  
- [135-class Emotional Facial Expression Dataset (IEEE Dataport)](https://ieee-dataport.org/documents/135-class-emotional-facial-expression-dataset)

---

## 3. GoEmotions — 27 эмоций + нейтральный (текст)

**Что это:** датасет и таксономия для **тонкой классификации эмоций по тексту** (58 000 аннотированных комментариев Reddit). **27 эмоций + нейтральный** класс. Используется для обучения BERT-подобных моделей; не для лица, но даёт эталон «много эмоций» с чёткой таксономией.

**27 категорий:**
- **Положительные (12):** Admiration, Amusement, Approval, Caring, Curiosity, Excitement, Gratitude, Joy, Love, Optimism, Pride, Relief.
- **Отрицательные (11):** Anger, Annoyance, Disappointment, Disapproval, Disgust, Embarrassment, Fear, Grief, Nervousness, Remorse, Sadness.
- **Неоднозначные (4):** Confusion, Desire, Realization, Surprise.

**Дополнительно:**
- У каждой категории есть краткое определение и примеры для согласованной разметки.
- До 3 меток на комментарий (или нейтральный).
- BERT-модели достигают Macro F1 ~0.46–0.49 на этом датасете.

**Ссылки:**  
- [GoEmotions (Google Research)](https://research.google/blog/goemotions-a-dataset-for-fine-grained-emotion-classification/)  
- [GoEmotions Taxonomy (Emergent Mind)](https://www.emergentmind.com/topics/goemotions-taxonomy)  
- [GitHub: goemotions](https://github.com/google-research/google-research/tree/master/goemotions)

---

## 4. EmoNet-Voice — 40 эмоций (речь)

**Что это:** бенчмарк и датасет для **распознавания эмоций по речи** с **40 тонкими эмоциональными категориями** и уровнями интенсивности. Включает как базовые (гнев, грусть), так и более тонкие состояния (концентрация, созерцание, стыд, боль, зависть, смущение и т.д.).

**Структура:**
- **EmoNet-Voice Big:** >4 500 часов синтетической речи, 11 голосов, 4 языка (EN, DE, ES, FR), 40 эмоций и уровни интенсивности.
- **EmoNet-Voice Bench:** ~12 600 клипов (~36 ч), экспертная разметка по 3 уровням интенсивности (0/1/2), верификация психологами.

**Особенности:**
- Высокоактивированные эмоции (например, гнев) распознаются лучше (~95% accuracy); близкие по восприятию (например, грусть vs дистресс) — сложнее (~63%).
- Модальность — **речь**, не лицо; полезно для мультимодальных систем.

**Ссылки:**  
- [EmoNet-Voice (arXiv)](https://arxiv.org/html/2506.09827v1)  
- [Hugging Face — EmoNet-Voice](https://huggingface.co/papers/2506.09827)

---

## 5. EMOTIC — 26 эмоций (лицо + контекст)

**Что это:** датасет для распознавания эмоций **в контексте сцены**: человек в естественной обстановке. **26 дискретных эмоций** плюс размерности Valence, Arousal, Dominance.

**26 категорий (кратко):**  
Peace, Affection, Esteem, Anticipation, Engagement, Confidence, Happiness, Pleasure, Excitement, Surprise, Sympathy, Doubt/Confusion, Disconnection, Fatigue, Embarrassment, Yearning, Disapproval, Aversion, Annoyance, Anger, Sensitivity, Sadness, Disquietment, Fear, Pain, Suffering.

**Дополнительно:**
- Комбинация дискретных меток и непрерывных размерностей (VAD).
- Учёт контекста (сцена), а не только лица — даёт более «аккуратную» интерпретацию эмоции в ситуации.

**Ссылки:**  
- [EMOTIC — Annotations](https://s3.sunai.uoc.edu/emotic/annotations.html)  
- [EMOTIC Dataset](https://www.emergentmind.com/topics/emotic-dataset)

---

## 6. AffectNet и AffectNet+ (лицо)

**AffectNet:** крупный датасет по лицу (~400 тыс. изображений с разметкой из >1 млн). **8 дискретных эмоций:** Neutral, Happy, Angry, Sad, Fear, Surprise, Disgust, Contempt; плюс непрерывные Valence и Arousal. Эталон для FER с 8 классами.

**AffectNet+ (2024):** развитие в сторону **мягких меток (soft labels)** — одна экспрессия может быть размечена несколькими эмоциями с разной уверенностью. Это не «ещё 100 классов», а более аккуратное моделирование смешанных и составных эмоций.

**Ссылки:**  
- [AffectNet (paperswithcode)](https://paperswithcode.com/dataset/affectnet)  
- [AffectNet+ (arXiv)](https://arxiv.org/html/2410.22506v1)

---

## 7. CK+ (Extended Cohn-Kanade) — 7 эмоций

**Что это:** классический датасет видеопоследовательностей (нейтральное → пик экспрессии). **7 эмоций по Экману:** anger, contempt, disgust, fear, happiness, sadness, surprise. 327 размеченных видео, 593 последовательности, 123 субъекта. Часто используется как базовый уровень для сравнения с «расширенными» таксономиями (10–100+ эмоций).

**Ссылка:**  
- [CK+ (paperswithcode)](https://paperswithcode.com/dataset/ck)

---

## Замечания по «аккуратности»

- **Таксономия:** перечисленные системы используют явные списки эмоций или размерности (VAD, 48 scores), а не произвольные теги.
- **Валидация:** у части датасетов есть экспертная или многократная разметка (GoEmotions, EmoNet-Voice, EMOTIC).
- **Модальность:** для **лица** максимум дискретных классов в одном датасете — **135** (Emo135); по API «из коробки» — **48** (Hume). Остальные — текст или речь, либо меньше классов.
- **Интеграция во Flutter:** для 10–100+ эмоций по лицу реалистичные варианты — либо облачный API (Hume), либо своя модель, обученная на Emo135/EMOTIC/GoEmotions (если объединять с текстом), с экспортом в ONNX/TFLite для on-device.

---

## Краткая рекомендация по использованию

- **Нужно много эмоций по лицу в продакшене:** Hume Expression Measurement (Face) — 48 выражений, готовый API.
- **Нужна своя модель с большим числом классов по лицу:** обучение на Emo135 (135 классов) или EMOTIC (26 классов + контекст).
- **Текст или мультимодальность:** таксономия и датасет GoEmotions (27 эмоций).
- **Речь:** бенчмарк и данные EmoNet-Voice (40 эмоций).

Если нужно, можно вынести этот список в отдельный раздел в основном README проекта или добавить таблицу сравнения (цена, лимиты, модальность) для API.
