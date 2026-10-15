
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: FlowerApp(),
));

class FlowerApp extends StatefulWidget {
  const FlowerApp({super.key});

  @override
  State<FlowerApp> createState() => _FlowerAppState();
}

class _FlowerAppState extends State<FlowerApp> {
  // お花の種類と1本あたりの値段
  final flowers = {
    '🌹 バラ': 200,
    '🌷 チューリップ': 150,
    '🌻 ひまわり': 200,
    '🌸 桜': 150,
    '🌼 デイジー': 100,
    '🪻 ヒヤシンス': 150,
    '🪷 ハス': 200,
    '☘️ クローバー': 50,
    '🍀 四つ葉': 80,
    '🌿 ハーブ': 70,
    '🍁 紅葉': 100,
  };

  // デコレーションの種類と値段
  final decorations = {
    '🎀 リボン': 100,
    '🎨 色紙': 50,
    '💌 メッセージカード': 100,
  };

  final flowerCounts = <String, int>{};
  final selectedDecorations = <String>{};

  bool bag = false;
  bool message = false;
  int order = 0;
  String receipt = '';

  @override
  Widget build(BuildContext context) {
    // 本数と料金の計算
    final totalCount =
        flowerCounts.values.fold<int>(0, (sum, n) => sum + n);

    final flowerPrice = flowerCounts.entries.fold<int>(
      0, (sum, e) => sum + flowers[e.key]! * e.value,
    );

    final decoPrice = selectedDecorations.fold<int>(
      0, (sum, s) => sum + decorations[s]!,
    );

    final subtotal = flowerPrice + decoPrice;
    final tax = subtotal ~/ 10;
    final total = subtotal + tax;

    // 選んだお花を絵文字で表示
    final photo = SizedBox(
      height: 150,
      child: Center(
        child: Text(
          totalCount == 0
              ? '💐'
              : flowerCounts.entries
                  .where((e) => e.value > 0)
                  .map((e) => e.key.split(' ').first * e.value)
                  .join(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36),
        ),
      ),
    );

    // お花の本数選択
    final flowerSelection = Column(children: [
      for (final s in flowers.keys)
        Row(children: [
          Expanded(child: Text('$s（${flowers[s]}円/本）')),
          IconButton(
            onPressed: (flowerCounts[s] ?? 0) > 0
                ? () => setState(() {
                    flowerCounts[s] =
                        (flowerCounts[s] ?? 0) - 1;
                  })
                : null,
            icon: const Icon(Icons.remove),
          ),
          Text(
            '${flowerCounts[s] ?? 0}',
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            onPressed: () => setState(() {
              flowerCounts[s] = (flowerCounts[s] ?? 0) + 1;
            }),
            icon: const Icon(Icons.add),
          ),
        ]),
      Text(
        '💐 お花の総本数：$totalCount 本',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ]);

    // デコレーション選択
    final decorationChips = Wrap(
      spacing: 6,
      children: [
        for (final s in decorations.keys)
          FilterChip(
            label: Text('$s  ${decorations[s]}円'),
            selected: selectedDecorations.contains(s),
            onSelected: (v) => setState(() {
              if (v) {
                selectedDecorations.add(s);
              } else {
                selectedDecorations.remove(s);
              }
            }),
          ),
      ],
    );

    // 無料サービス
    final supplies = Column(children: [
      CheckboxListTile(
        title: const Text('🛍️ 持ち帰り袋（無料）'),
        value: bag,
        onChanged: (v) => setState(() => bag = v ?? false),
      ),
      CheckboxListTile(
        title: const Text('✍️ メッセージ記入（無料）'),
        value: message,
        onChanged: (v) => setState(() => message = v ?? false),
      ),
    ]);

    // 料金表示
    final bill = Column(children: [
      Text('税抜 $subtotal 円 / 消費税 $tax 円'),
      Text(
        '合計 $total 円',
        style: const TextStyle(fontSize: 28),
      ),
    ]);

    // 注文ボタン
    final submit = Center(
      child: FilledButton(
        onPressed: totalCount == 0
            ? null
            : () => setState(() {
                order = Random().nextInt(999) + 1;

                receipt = '💐 オリジナル花束\n'
                    'お花：\n'
                    '${flowerCounts.entries.where((e) => e.value > 0).map((e) => '${e.key} × ${e.value}本').join('\n')}\n'
                    '総本数：$totalCount 本\n'
                    'デコレーション：${selectedDecorations.isEmpty ? 'なし' : selectedDecorations.join('、')}\n'
                    '🛍️ 持ち帰り袋：${bag ? 'あり' : 'なし'}\n'
                    '✍️ メッセージ記入：${message ? 'あり' : 'なし'}\n'
                    '税抜：$subtotal 円\n'
                    '消費税（10%）：$tax 円\n'
                    '合計：$total 円';
              }),
        child: const Text('注文する'),
      ),
    );

    // 注文レシート
    final ticket = order == 0
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '注文番号 #$order',
                    style: const TextStyle(fontSize: 26),
                  ),
                  Text(receipt),
                ],
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('💐 よりみち花屋 💐'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              photo,
              const Text('🌸 お花を選ぶ'),
              flowerSelection,
              const SizedBox(height: 16),
              const Text('🎀 デコレーション'),
              decorationChips,
              const SizedBox(height: 16),
              const Text('無料サービス'),
              supplies,
              const Divider(),
              bill,
              const SizedBox(height: 12),
              submit,
              ticket,
            ],
          ),
        ),
      ),
    );
  }
}
