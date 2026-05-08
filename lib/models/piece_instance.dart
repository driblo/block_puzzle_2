import 'piece_definition.dart';

class PieceInstance {
  final String id;
  final PieceDefinition definition;
  final bool isPlaced;

  const PieceInstance({
    required this.id,
    required this.definition,
    this.isPlaced = false,
  });

  PieceInstance markPlaced() =>
      PieceInstance(id: id, definition: definition, isPlaced: true);
}
