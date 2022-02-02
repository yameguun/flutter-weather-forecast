import 'dart:convert';
import 'package:http/http.dart';

import 'config.dart';

class Weather {
  int? temp; //気温
  int? tempMax; //最高気温
  int? tempMin; //最低気温
  String? description; //天気状態
  double? lon; //経度
  double? lat; //緯度
  String? icon; //天気情報のアイコン画像
  DateTime time; //日時
  int? rainyPercent; //降水確率

  Weather(
      {this.temp,
      this.tempMax,
      this.tempMin,
      this.description,
      this.lon,
      this.lat,
      this.icon,
      required this.time,
      this.rainyPercent});

  static Future<Weather> getCurrentWeather(String zipCode) async {
    String _zipCode;
    if (zipCode.contains('-')) {
      _zipCode = zipCode;
    } else {
      _zipCode = zipCode.substring(0, 3) + '-' + zipCode.substring(3);
    }
    String url =
        'https://api.openweathermap.org/data/2.5/weather?zip=$_zipCode,JP&appid=$API_KEY&lang=ja&units=metric';
    try {
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      Weather currentWeather = Weather(
          description: data['weather'][0]['description'],
          temp: data['main']['temp'].toInt(),
          tempMax: data['main']['temp_max'].toInt(),
          tempMin: data['main']['temp_min'].toInt(),
          time: DateTime.now(),
          lon: data['coord']['lon'],
          lat: data['coord']['lat']);
      return currentWeather;
    } catch (e) {
      return Weather(
          description: '',
          temp: 0,
          tempMax: 0,
          tempMin: 0,
          time: DateTime.now());
    }
  }

  static Future<Map<String, List<Weather>>> getForecast(
      {double? lon, double? lat}) async {
    Map<String, List<Weather>> response = {};
    String url =
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely&appid=$API_KEY&lang=ja&units=metric';
    try {
      var result = await get(Uri.parse(url));
      Map<String, dynamic> data = jsonDecode(result.body);
      List<dynamic> hourlyWeatherData = data['hourly'];
      List<dynamic> dailyWeatherData = data['daily'];

      List<Weather> hourlyWeather = hourlyWeatherData.map((weather) {
        return Weather(
          time: DateTime.fromMillisecondsSinceEpoch(weather['dt'] * 1000),
          temp: weather['temp'].toInt(),
          icon: weather['weather'][0]['icon'],
        );
      }).toList();

      List<Weather> dailyWeather = dailyWeatherData.map((weather) {
        return Weather(
          time: DateTime.fromMillisecondsSinceEpoch(weather['dt'] * 1000),
          icon: weather['weather'][0]['icon'],
          tempMax: weather['temp']['max'].toInt(),
          tempMin: weather['temp']['min'].toInt(),
          rainyPercent: 0,
        );
      }).toList();

      response['hourly'] = hourlyWeather.isEmpty ? [] : hourlyWeather;
      response['daily'] = dailyWeather.isEmpty ? [] : dailyWeather;

      return response;
    } catch (e) {
      return <String, List<Weather>>{};
    }
  }
}
