/// Date and time text for screens. Client-safe (no `dart:io`).
library;

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _two(int n) => n.toString().padLeft(2, '0');

/// `Mon 22 Mar 2027`
String formatDate(DateTime d) => '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year}';

/// `09:30`
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// `Mon 22 Mar 2027, 09:30`, plus ` UTC` for a UTC value.
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}${d.isUtc ? ' UTC' : ''}';

/// `yyyy-MM-dd`, the form of an HCL `Date` value in paths and inputs.
String isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';
