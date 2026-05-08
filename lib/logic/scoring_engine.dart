// Points for placing a piece: 1 per cell
int scoreForPlacement(int cellCount) => cellCount;

// Points for clearing N lines: triangular sequence × 10
// N=1 → 10, N=2 → 30, N=3 → 60, N=4 → 100
int scoreForClear(int lineCount) {
  if (lineCount <= 0) return 0;
  return 10 * lineCount * (lineCount + 1) ~/ 2;
}
