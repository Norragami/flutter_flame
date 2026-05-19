import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: CampfireGame(),
        ),
      ),
    ),
  );
}

class CampfireGame extends FlameGame with TapCallbacks {
  late CampfireComponent campfire;
  
  @override
  Future<void> onLoad() async {
    // Добавляем фон леса
    final background = SpriteComponent(
      sprite: await Sprite.load('forest.png'), // СЮДА ВСТАВЬ КАРТИНКУ ЛЕСА
      size: size,
      anchor: Anchor.topLeft,
    );
    add(background);
    
    // Добавляем костер, передавая ссылку на игру
    campfire = CampfireComponent(this);
    await campfire.onLoad();
    add(campfire);
  }
  
  @override
  void onTapUp(TapUpEvent event) {
    // Проверяем, был ли клик по костру
    final Vector2 tapPosition = event.localPosition;
    
    if (campfire.containsPoint(tapPosition)) {
      // Клик по костру - увеличиваем
      campfire.increaseSize();
    } else {
      // Клик вне костра - уменьшаем
      campfire.decreaseSize();
    }
  }
}

class CampfireComponent extends SpriteComponent {
  final CampfireGame gameReference;
  static const double minSizePercent = 0.05;  // 5%
  static const double maxSizePercent = 1.5;   // 100%
  static const double initialSizePercent = 0.5; // 50%
  static const double resizeStep = 0.05; // 5%
  
  double currentSizePercent = initialSizePercent;
  
  CampfireComponent(this.gameReference) : super(anchor: Anchor.center);
  
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('campfire.png'); 
    
    // Позиционируем костер в центре экрана
    position = Vector2(
      gameReference.size.x / 2,
      gameReference.size.y / 2,
    );
    
    updateSize();
  }
  
  void updateSize() {
    // Размер костра относительно размера экрана
    final baseSize = gameReference.size.x < gameReference.size.y 
        ? gameReference.size.x * 0.3 
        : gameReference.size.y * 0.3;
    
    size = Vector2.all(baseSize * currentSizePercent);
  }
  
  void increaseSize() {
    currentSizePercent += resizeStep;
    if (currentSizePercent > maxSizePercent) {
      currentSizePercent = maxSizePercent;
    }
    
    updateSize();
    print('Размер костра увеличен: ${(currentSizePercent * 100).toStringAsFixed(0)}%');
  }
  
  void decreaseSize() {
    currentSizePercent -= resizeStep;
    if (currentSizePercent < minSizePercent) {
      currentSizePercent = minSizePercent;
    }
    
    updateSize();
    print('Размер костра уменьшен: ${(currentSizePercent * 100).toStringAsFixed(0)}%');
  }
  
  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    // Обновляем позицию при изменении размера экрана
    position = Vector2(
      newSize.x / 2,
      newSize.y * 0.7,
    );
    updateSize();
  }
  
  // Вспомогательный метод для проверки попадания точки в костер
  bool containsPoint(Vector2 point) {
    final Rect rect = Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
    return rect.contains(Offset(point.x, point.y));
  }
}