import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sample/weather.dart';
import 'package:sample/zip_code.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  Weather currentWeather = Weather(time: DateTime(2021, 10, 1, 10));
  String? address = '-';
  String? errorMessage = '';
  List<Weather> hourlyWeather = [];
  List<Weather> dailyWeather = [];
  List<String> weekDay = ['月','火','水','木','金','土','日'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
            children: [
              Container(
                width: 200,
                child: TextField(
                  onSubmitted: (value) async {
                    Map<String, String> response = {};
                    response = await ZipCode.searchAddressFromZipCode(value);
                    errorMessage = response['message'];
                    if (response.containsKey('address')) {
                      address = response['address'];
                      currentWeather = await Weather.getCurrentWeather(value);
                      Map<String, List<Weather>> weatherForecast = await Weather.getForecast(lon: currentWeather.lon, lat: currentWeather.lat);
                      hourlyWeather = (weatherForecast['hourly'] ?? []);
                      dailyWeather = (weatherForecast['daily'] ?? []);
                    }
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '郵便番号を入力'
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Text(address!, style: const TextStyle(fontSize: 25),),
              Text(currentWeather.description ?? ''),
              Text('${currentWeather.temp}°', style: TextStyle(fontSize: 88),),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text('最高:${currentWeather.tempMax ?? '0'}°'),
                  ),
                  Text('最低:${currentWeather.tempMin ?? '0'}°'),
                ],
              ),
              const SizedBox(height: 50),
              const Divider(height: 0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: hourlyWeather.isEmpty ? Container() : Row(
                  children: hourlyWeather.map((weather) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text('${DateFormat('H').format(weather.time)}時'),
                          Image.network('https://openweathermap.org/img/wn/${weather.icon}.png', width: 30,),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text('${weather.temp}°', style: const TextStyle(fontSize: 18),),
                          )
                        ],
                      ),
                    );
                  }).toList()
                ),
              ),
              const Divider(height: 0),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: dailyWeather.isEmpty? Container() : Column(
                      children: dailyWeather.map((weather) {
                        return Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                child: Text('${weekDay[weather.time.weekday - 1]}曜日'),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.wb_sunny_sharp),
                                  Text('${weather.rainyPercent}%', style: const TextStyle(color: Colors.lightBlueAccent)),
                                ],
                              ),
                              Container(
                                width: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${weather.tempMax}°', style: TextStyle(fontSize: 16)),
                                    Text('${weather.tempMin}°', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.4))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              )
            ],
          )
      )
    );
  }
}
