import '../models/class_model.dart';

/// Defines the progression of classes inspired by the Solo Leveling manhwa.
/// Each class unlocks at a specific level and grants a set of abilities.  The
/// final evolution at level 100 is the "Shadow Monarch".  As the player
/// levels up, they transition through these classes once the required
/// level threshold is reached.
const List<LevelClass> exampleClasses = [
  LevelClass(
    name: 'E‑Rank Hunter',
    abilities: ['Basic Strength', 'Quick Step'],
    requiredLevel: 1,
  ),
  LevelClass(
    name: 'D‑Rank Hunter',
    abilities: ['Improved Strength', 'Double Strike'],
    requiredLevel: 10,
  ),
  LevelClass(
    name: 'C‑Rank Hunter',
    abilities: ['Shadow Daggers', 'Enhanced Agility'],
    requiredLevel: 20,
  ),
  LevelClass(
    name: 'B‑Rank Hunter',
    abilities: ['Shadow Slash', 'Enhanced Endurance'],
    requiredLevel: 30,
  ),
  LevelClass(
    name: 'A‑Rank Hunter',
    abilities: ['Shadow Magic', 'Advanced Tactics'],
    requiredLevel: 50,
  ),
  LevelClass(
    name: 'S‑Rank Hunter',
    abilities: ['Shadow Army', 'Spatial Movement'],
    requiredLevel: 70,
  ),
  LevelClass(
    name: 'Shadow Monarch',
    abilities: ['Shadow Monarch', 'Army of Shadows', 'Reality Slash'],
    requiredLevel: 100,
  ),
];
