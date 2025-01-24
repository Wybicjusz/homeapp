import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homeapp/repositories/weather_repository.dart';
import 'package:homeapp/blocs/weather_event.dart';
import 'package:homeapp/blocs/weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc(this.weatherRepository) : super(WeatherInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        final data = await weatherRepository.fetchWeatherForecast();
        emit(WeatherLoaded(data));
      } catch (error) {
        emit(WeatherError(error.toString()));
      }
    });
  }
}
