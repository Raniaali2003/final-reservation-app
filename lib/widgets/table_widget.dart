import 'package:flutter/material.dart';
import 'package:my_first_flutter_app/models/restaurant.dart';

class TableWidget extends StatelessWidget {
  final TableModel table;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;
  final int seatCount;
  final double size;

  const TableWidget({
    super.key,
    required this.table,
    this.isSelected = false,
    this.isAvailable = true,
    this.onTap,
    this.seatCount = 4,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color tableColor = isSelected
        ? colorScheme.primary
        : isAvailable
            ? colorScheme.primary.withOpacity(0.2)
            : Colors.grey[300]!;

    Color borderColor = isSelected
        ? colorScheme.primary
        : isAvailable
            ? colorScheme.primary.withOpacity(0.5)
            : Colors.grey[400]!;

    Color textColor = isSelected
        ? colorScheme.onPrimary
        : isAvailable
            ? colorScheme.onSurface
            : Colors.grey[600]!;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: tableColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                'Table ${table.number}',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.16,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTableLeg(size * 0.2, borderColor),
              _buildTableLeg(size * 0.2, borderColor),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSeat(0, seatCount > 0, textColor, size * 0.2),
              _buildSeat(1, seatCount > 1, textColor, size * 0.2),
            ],
          ),
          if (seatCount > 2) ...[
            SizedBox(height: size * 0.1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeat(2, seatCount > 2, textColor, size * 0.2),
                _buildSeat(3, seatCount > 3, textColor, size * 0.2),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '${table.maxSeats} ${table.maxSeats == 1 ? 'seat' : 'seats'}\n',
              style: TextStyle(
                color: textColor,
                fontSize: size * 0.12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableLeg(double size, Color color) {
    return Container(
      width: size,
      height: size * 0.5,
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(size * 0.2)),
      ),
    );
  }

  Widget _buildSeat(int index, bool isAvailable, Color color, double size) {
    return Container(
      width: size,
      height: size * 0.5,
      decoration: BoxDecoration(
        color: isAvailable ? color.withOpacity(0.3) : Colors.transparent,
        border: Border.all(
          color: isAvailable ? color : Colors.transparent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
