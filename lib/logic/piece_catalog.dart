import 'package:flutter/material.dart';
import '../models/piece_definition.dart';

// Color palette by piece family
const _gold = Color(0xFFFFD700);
const _cyan = Color(0xFF00D4FF);
const _coral = Color(0xFFFF6B6B);
const _purple = Color(0xFFC084FC);
const _green = Color(0xFF4ADE80);
const _orange = Color(0xFFF97316);
const _indigo = Color(0xFF818CF8);
const _pink = Color(0xFFFB7185);
const _emerald = Color(0xFF34D399);
const _yellow = Color(0xFFFACC15);

const pieceCatalog = <PieceDefinition>[
  // --- 1-cell ---
  PieceDefinition(name: 'dot', cells: [(0, 0)], color: _gold),

  // --- 2-cell ---
  PieceDefinition(name: 'h2', cells: [(0, 0), (0, 1)], color: _cyan),
  PieceDefinition(name: 'v2', cells: [(0, 0), (1, 0)], color: _cyan),

  // --- 3-cell straight ---
  PieceDefinition(name: 'h3', cells: [(0, 0), (0, 1), (0, 2)], color: _coral),
  PieceDefinition(name: 'v3', cells: [(0, 0), (1, 0), (2, 0)], color: _coral),

  // --- 3-cell bent ---
  PieceDefinition(
      name: 'l3', cells: [(0, 0), (1, 0), (1, 1)], color: _purple),
  PieceDefinition(
      name: 'j3', cells: [(0, 1), (1, 0), (1, 1)], color: _purple),
  PieceDefinition(
      name: 's3', cells: [(0, 0), (0, 1), (1, 1)], color: _purple),
  PieceDefinition(
      name: 'z3', cells: [(0, 1), (1, 0), (1, 1)], color: _purple),

  // --- 4-cell square ---
  PieceDefinition(
      name: 'sq',
      cells: [(0, 0), (0, 1), (1, 0), (1, 1)],
      color: _green),

  // --- 4-cell straight ---
  PieceDefinition(
      name: 'h4',
      cells: [(0, 0), (0, 1), (0, 2), (0, 3)],
      color: _orange),
  PieceDefinition(
      name: 'v4',
      cells: [(0, 0), (1, 0), (2, 0), (3, 0)],
      color: _orange),

  // --- 4-cell shapes ---
  PieceDefinition(
      name: 'l4',
      cells: [(0, 0), (1, 0), (2, 0), (2, 1)],
      color: _indigo),
  PieceDefinition(
      name: 'j4',
      cells: [(0, 1), (1, 1), (2, 0), (2, 1)],
      color: _indigo),
  PieceDefinition(
      name: 't4',
      cells: [(0, 1), (1, 0), (1, 1), (1, 2)],
      color: _indigo),
  PieceDefinition(
      name: 's4',
      cells: [(0, 1), (0, 2), (1, 0), (1, 1)],
      color: _indigo),
  PieceDefinition(
      name: 'z4',
      cells: [(0, 0), (0, 1), (1, 1), (1, 2)],
      color: _indigo),

  // --- 5-cell straight ---
  PieceDefinition(
      name: 'h5',
      cells: [(0, 0), (0, 1), (0, 2), (0, 3), (0, 4)],
      color: _pink),
  PieceDefinition(
      name: 'v5',
      cells: [(0, 0), (1, 0), (2, 0), (3, 0), (4, 0)],
      color: _pink),

  // --- 5-cell shapes ---
  PieceDefinition(
      name: 'bigL',
      cells: [(0, 0), (1, 0), (2, 0), (3, 0), (3, 1)],
      color: _emerald),
  PieceDefinition(
      name: 'bigJ',
      cells: [(0, 1), (1, 1), (2, 1), (3, 0), (3, 1)],
      color: _emerald),
  PieceDefinition(
      name: 'plus',
      cells: [(0, 1), (1, 0), (1, 1), (1, 2), (2, 1)],
      color: _emerald),
  PieceDefinition(
      name: 'corner',
      cells: [(0, 0), (0, 1), (0, 2), (1, 0), (2, 0)],
      color: _emerald),

  // --- 6-cell rectangles ---
  PieceDefinition(
      name: '2x3',
      cells: [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (1, 2)],
      color: _yellow),
  PieceDefinition(
      name: '3x2',
      cells: [(0, 0), (0, 1), (1, 0), (1, 1), (2, 0), (2, 1)],
      color: _yellow),
];
