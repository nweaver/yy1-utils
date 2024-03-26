An ugly script to take both a feeder inventory and a Altium pick &
place CSV and output for the YY1.

This needs significant improvement:

1) Don't forget to handle the bug that changes after skipped
components get skipped (oops), and the case where we go from just tiny
to big.

2) Consider rewriting in a way to get realtime inventory from a Google
Doc instead of a saved csv.

