@override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = AppTheme.accentColor;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Habits',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}