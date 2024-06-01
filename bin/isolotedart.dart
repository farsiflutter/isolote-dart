import 'dart:async';
import 'dart:isolate';

void main() async {
  /// ایجاد یک ReceivePort برای دریافت پیام‌ها از ایزوله
  final receivePort = ReceivePort();

  /// ایجاد یک ایزوله جدید و ارسال SendPort به آن
  await Isolate.spawn(isolateTask, receivePort.sendPort);

  /// دریافت SendPort از ایزوله
  final sendPort = await receivePort.first as SendPort;

  /// ایجاد یک ReceivePort برای دریافت نتیجه از ایزوله
  final responsePort = ReceivePort();

  /// ارسال پیام به ایزوله با داده‌ها و پورت پاسخ
  sendPort.send(['Hello from main!', responsePort.sendPort]);

  /// منتظر ماندن برای دریافت پاسخ از ایزوله
  final result = await responsePort.first;

  print('Result from isolate: $result');
}

void isolateTask(SendPort mainSendPort) async {
  /// ایجاد یک ReceivePort برای دریافت پیام‌ها از ایزوله اصلی
  final receivePort = ReceivePort();

  /// ارسال SendPort مربوط به ReceivePort به ایزوله اصلی
  mainSendPort.send(receivePort.sendPort);

  /// منتظر ماندن برای دریافت پیام از ایزوله اصلی
  await for (final message in receivePort) {
    final data = message[0] as String;
    final sendPort = message[1] as SendPort;

    /// انجام یک وظیفه سنگین (شبیه‌سازی با یک تأخیر)
    final result = await heavyTask(data);

    /// ارسال نتیجه به ایزوله اصلی
    sendPort.send(result);
  }
}

Future<String> heavyTask(String data) async {
  /// شبیه‌سازی یک وظیفه سنگین با یک تأخیر
  await Future.delayed(Duration(seconds: 2));
  return 'Processed data: $data';
}
