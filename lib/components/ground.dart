import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

const groundSize = 7.0;

class Ground extends BodyComponent {
  Ground(Vector2 position, Sprite sprite)
      : super(
          renderBody: false, // 디버그 렌더링 사용 중지
          bodyDef: BodyDef() // BodyType.static 설정
            ..position = position
            ..type = BodyType.static,
          fixtureDefs: [
            FixtureDef(
              PolygonShape()..setAsBoxXY(groundSize / 2, groundSize / 2),
              friction: 0.3,
            )
          ],
          children: [
            // 여기서 렌더링 제공
            SpriteComponent(
              anchor: Anchor.center,
              sprite: sprite,
              size: Vector2.all(groundSize),
              position: Vector2(0, 0),
            ),
          ],
        );
}
