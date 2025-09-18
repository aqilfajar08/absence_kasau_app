import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/utils/indonesian_date_formatter.dart';

class IndonesianCalendarTimeline extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;
  final double leftMargin;
  final Color monthColor;
  final Color dayColor;
  final Color activeDayColor;
  final Color activeBackgroundDayColor;
  final bool showYears;

  const IndonesianCalendarTimeline({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.leftMargin = 20,
    this.monthColor = AppColors.grey,
    this.dayColor = AppColors.black,
    this.activeDayColor = Colors.white,
    this.activeBackgroundDayColor = AppColors.primary,
    this.showYears = true,
  });

  @override
  State<IndonesianCalendarTimeline> createState() => _IndonesianCalendarTimelineState();
}

class _IndonesianCalendarTimelineState extends State<IndonesianCalendarTimeline> {
  late DateTime _selectedDate;
  late PageController _headerPageController;
  late PageController _daysPageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _currentPage = _getPageForDate(_selectedDate);
    _headerPageController = PageController(initialPage: _currentPage);
    _daysPageController = PageController(initialPage: _currentPage);
  }

  int _getPageForDate(DateTime date) {
    final firstDate = widget.firstDate;
    final monthsDiff = (date.year - firstDate.year) * 12 + (date.month - firstDate.month);
    return monthsDiff;
  }

  DateTime _getDateForPage(int page) {
    final firstDate = widget.firstDate;
    final year = firstDate.year + (page ~/ 12);
    final month = firstDate.month + (page % 12);
    return DateTime(year, month, 1);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;
    
    List<DateTime> days = [];
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month/Year header
        Container(
          height: 50,
          child: PageView.builder(
            controller: _headerPageController,
            onPageChanged: (page) {
              setState(() {
                _currentPage = page;
              });
              // Sync the days page controller
              _daysPageController.animateToPage(
                page,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            itemBuilder: (context, page) {
              final month = _getDateForPage(page);
              return Center(
                child: Text(
                  widget.showYears 
                    ? '${IndonesianDateFormatter.getMonthName(month)} ${month.year}'
                    : IndonesianDateFormatter.getMonthName(month),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.monthColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Calendar days
        Container(
          height: 80,
          child: PageView.builder(
            controller: _daysPageController,
            itemBuilder: (context, page) {
              final month = _getDateForPage(page);
              final days = _getDaysInMonth(month);
              
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: days.map((day) {
                    final isSelected = _isSameDay(day, _selectedDate);
                    final isToday = _isSameDay(day, DateTime.now());
                    final isInRange = day.isAfter(widget.firstDate.subtract(const Duration(days: 1))) &&
                                     day.isBefore(widget.lastDate.add(const Duration(days: 1)));
                    
                    return Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: GestureDetector(
                        onTap: isInRange ? () {
                          setState(() {
                            _selectedDate = day;
                          });
                          widget.onDateSelected(day);
                        } : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? widget.activeBackgroundDayColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isToday ? Border.all(color: widget.activeBackgroundDayColor, width: 2) : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                IndonesianDateFormatter.getDayName(day).substring(0, 3), // Short day name
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSelected ? widget.activeDayColor : widget.dayColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected ? widget.activeDayColor : widget.dayColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Navigation arrows
        Container(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentPage > 0 ? () {
                  _headerPageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: _currentPage > 0 ? widget.dayColor : Colors.grey,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              IconButton(
                onPressed: _currentPage < _getPageForDate(widget.lastDate) ? () {
                  _headerPageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: _currentPage < _getPageForDate(widget.lastDate) ? widget.dayColor : Colors.grey,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  @override
  void dispose() {
    _headerPageController.dispose();
    _daysPageController.dispose();
    super.dispose();
  }
}
