import 'package:flutter_test/flutter_test.dart';

import '../../../../../lib/features/home/domain/entities/weather_entity.dart';

void main() {
  group('WeatherEntity', () {
    late WeatherEntity testWeather;

    setUp(() {
      testWeather = WeatherEntity(
        temperature: 25.0,
        location: '東京',
        weatherId: 800,
        description: '晴れ',
        feelsLike: 27.0,
        humidity: 60,
        windSpeed: 5.0,
        iconCode: '01d',
        uvIndex: 6.0,
        visibility: 10000,
        pressure: 1013.25,
      );
    });

    group('constructor', () {
      test('should create weather with all parameters', () {
        // Act
        final weather = WeatherEntity(
          temperature: 20.0,
          location: '大阪',
          weatherId: 801,
          description: '曇り',
          feelsLike: 22.0,
          humidity: 70,
          windSpeed: 3.0,
          iconCode: '02d',
          uvIndex: 4.0,
          visibility: 8000,
          pressure: 1010.0,
        );

        // Assert
        expect(weather.temperature, equals(20.0));
        expect(weather.location, equals('大阪'));
        expect(weather.weatherId, equals(801));
        expect(weather.description, equals('曇り'));
        expect(weather.feelsLike, equals(22.0));
        expect(weather.humidity, equals(70));
        expect(weather.windSpeed, equals(3.0));
        expect(weather.iconCode, equals('02d'));
        expect(weather.uvIndex, equals(4.0));
        expect(weather.visibility, equals(8000));
        expect(weather.pressure, equals(1010.0));
      });
    });

    group('weather condition getters', () {
      test('isSunny should return true for clear sky', () {
        // Arrange
        final sunnyWeather = testWeather.copyWith(weatherId: 800);

        // Assert
        expect(sunnyWeather.isSunny, isTrue);
        expect(sunnyWeather.isRainy, isFalse);
        expect(sunnyWeather.isCloudy, isFalse);
        expect(sunnyWeather.isSnowy, isFalse);
      });

      test('isRainy should return true for rain conditions', () {
        // Arrange
        final rainWeather1 = testWeather.copyWith(
          weatherId: 200,
        ); // thunderstorm
        final rainWeather2 = testWeather.copyWith(weatherId: 300); // drizzle
        final rainWeather3 = testWeather.copyWith(weatherId: 500); // rain
        final rainWeather4 = testWeather.copyWith(weatherId: 599); // heavy rain

        // Assert
        expect(rainWeather1.isRainy, isTrue);
        expect(rainWeather2.isRainy, isTrue);
        expect(rainWeather3.isRainy, isTrue);
        expect(rainWeather4.isRainy, isTrue);
      });

      test('isCloudy should return true for cloud conditions', () {
        // Arrange
        final cloudyWeather1 = testWeather.copyWith(
          weatherId: 801,
        ); // few clouds
        final cloudyWeather2 = testWeather.copyWith(
          weatherId: 802,
        ); // scattered clouds
        final cloudyWeather3 = testWeather.copyWith(
          weatherId: 803,
        ); // broken clouds
        final cloudyWeather4 = testWeather.copyWith(
          weatherId: 804,
        ); // overcast clouds

        // Assert
        expect(cloudyWeather1.isCloudy, isTrue);
        expect(cloudyWeather2.isCloudy, isTrue);
        expect(cloudyWeather3.isCloudy, isTrue);
        expect(cloudyWeather4.isCloudy, isTrue);
      });

      test('isSnowy should return true for snow conditions', () {
        // Arrange
        final snowWeather1 = testWeather.copyWith(weatherId: 600); // light snow
        final snowWeather2 = testWeather.copyWith(weatherId: 650); // snow
        final snowWeather3 = testWeather.copyWith(weatherId: 699); // heavy snow

        // Assert
        expect(snowWeather1.isSnowy, isTrue);
        expect(snowWeather2.isSnowy, isTrue);
        expect(snowWeather3.isSnowy, isTrue);
      });

      test('should return false for conditions outside ranges', () {
        // Arrange
        final otherWeather = testWeather.copyWith(weatherId: 100); // unknown

        // Assert
        expect(otherWeather.isSunny, isFalse);
        expect(otherWeather.isRainy, isFalse);
        expect(otherWeather.isCloudy, isFalse);
        expect(otherWeather.isSnowy, isFalse);
      });
    });

    group('uvRiskLevel getter', () {
      test('should return low for UV index 0-2', () {
        // Arrange
        final lowUvWeather1 = testWeather.copyWith(uvIndex: 0.0);
        final lowUvWeather2 = testWeather.copyWith(uvIndex: 1.0);
        final lowUvWeather3 = testWeather.copyWith(uvIndex: 2.0);

        // Assert
        expect(lowUvWeather1.uvRiskLevel, equals('low'));
        expect(lowUvWeather2.uvRiskLevel, equals('low'));
        expect(lowUvWeather3.uvRiskLevel, equals('low'));
      });

      test('should return moderate for UV index 3-5', () {
        // Arrange
        final moderateUvWeather1 = testWeather.copyWith(uvIndex: 3.0);
        final moderateUvWeather2 = testWeather.copyWith(uvIndex: 4.0);
        final moderateUvWeather3 = testWeather.copyWith(uvIndex: 5.0);

        // Assert
        expect(moderateUvWeather1.uvRiskLevel, equals('moderate'));
        expect(moderateUvWeather2.uvRiskLevel, equals('moderate'));
        expect(moderateUvWeather3.uvRiskLevel, equals('moderate'));
      });

      test('should return high for UV index 6-7', () {
        // Arrange
        final highUvWeather1 = testWeather.copyWith(uvIndex: 6.0);
        final highUvWeather2 = testWeather.copyWith(uvIndex: 7.0);

        // Assert
        expect(highUvWeather1.uvRiskLevel, equals('high'));
        expect(highUvWeather2.uvRiskLevel, equals('high'));
      });

      test('should return very_high for UV index 8-10', () {
        // Arrange
        final veryHighUvWeather1 = testWeather.copyWith(uvIndex: 8.0);
        final veryHighUvWeather2 = testWeather.copyWith(uvIndex: 9.0);
        final veryHighUvWeather3 = testWeather.copyWith(uvIndex: 10.0);

        // Assert
        expect(veryHighUvWeather1.uvRiskLevel, equals('very_high'));
        expect(veryHighUvWeather2.uvRiskLevel, equals('very_high'));
        expect(veryHighUvWeather3.uvRiskLevel, equals('very_high'));
      });

      test('should return extreme for UV index above 10', () {
        // Arrange
        final extremeUvWeather1 = testWeather.copyWith(uvIndex: 11.0);
        final extremeUvWeather2 = testWeather.copyWith(uvIndex: 15.0);

        // Assert
        expect(extremeUvWeather1.uvRiskLevel, equals('extreme'));
        expect(extremeUvWeather2.uvRiskLevel, equals('extreme'));
      });
    });

    group('isGoodForWalk getter', () {
      test('should return true for good walking conditions', () {
        // Arrange
        final goodWeather = testWeather.copyWith(
          weatherId: 800, // sunny
          temperature: 20.0, // good temperature
        );

        // Assert
        expect(goodWeather.isGoodForWalk, isTrue);
      });

      test('should return false for rainy weather', () {
        // Arrange
        final rainyWeather = testWeather.copyWith(
          weatherId: 500, // rain
          temperature: 20.0,
        );

        // Assert
        expect(rainyWeather.isGoodForWalk, isFalse);
      });

      test('should return false for snowy weather', () {
        // Arrange
        final snowyWeather = testWeather.copyWith(
          weatherId: 600, // snow
          temperature: 20.0,
        );

        // Assert
        expect(snowyWeather.isGoodForWalk, isFalse);
      });

      test('should return false for temperature too low', () {
        // Arrange
        final coldWeather = testWeather.copyWith(
          weatherId: 800, // sunny
          temperature: 5.0, // too cold
        );

        // Assert
        expect(coldWeather.isGoodForWalk, isFalse);
      });

      test('should return false for temperature too high', () {
        // Arrange
        final hotWeather = testWeather.copyWith(
          weatherId: 800, // sunny
          temperature: 35.0, // too hot
        );

        // Assert
        expect(hotWeather.isGoodForWalk, isFalse);
      });

      test('should return true for temperature at boundaries', () {
        // Arrange
        final minTempWeather = testWeather.copyWith(
          weatherId: 800,
          temperature: 10.0, // minimum good temperature
        );
        final maxTempWeather = testWeather.copyWith(
          weatherId: 800,
          temperature: 30.0, // maximum good temperature
        );

        // Assert
        expect(minTempWeather.isGoodForWalk, isTrue);
        expect(maxTempWeather.isGoodForWalk, isTrue);
      });

      test('should return false for temperature just outside boundaries', () {
        // Arrange
        final tooColdWeather = testWeather.copyWith(
          weatherId: 800,
          temperature: 9.9, // just below minimum
        );
        final tooHotWeather = testWeather.copyWith(
          weatherId: 800,
          temperature: 30.1, // just above maximum
        );

        // Assert
        expect(tooColdWeather.isGoodForWalk, isFalse);
        expect(tooHotWeather.isGoodForWalk, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle extreme temperature values', () {
        // Arrange
        final extremeColdWeather = testWeather.copyWith(temperature: -50.0);
        final extremeHotWeather = testWeather.copyWith(temperature: 60.0);

        // Assert
        expect(extremeColdWeather.temperature, equals(-50.0));
        expect(extremeHotWeather.temperature, equals(60.0));
        expect(extremeColdWeather.isGoodForWalk, isFalse);
        expect(extremeHotWeather.isGoodForWalk, isFalse);
      });

      test('should handle extreme humidity values', () {
        // Arrange
        final noHumidityWeather = testWeather.copyWith(humidity: 0);
        final maxHumidityWeather = testWeather.copyWith(humidity: 100);

        // Assert
        expect(noHumidityWeather.humidity, equals(0));
        expect(maxHumidityWeather.humidity, equals(100));
      });

      test('should handle extreme wind speed values', () {
        // Arrange
        final noWindWeather = testWeather.copyWith(windSpeed: 0.0);
        final strongWindWeather = testWeather.copyWith(windSpeed: 100.0);

        // Assert
        expect(noWindWeather.windSpeed, equals(0.0));
        expect(strongWindWeather.windSpeed, equals(100.0));
      });

      test('should handle extreme pressure values', () {
        // Arrange
        final lowPressureWeather = testWeather.copyWith(pressure: 800.0);
        final highPressureWeather = testWeather.copyWith(pressure: 1100.0);

        // Assert
        expect(lowPressureWeather.pressure, equals(800.0));
        expect(highPressureWeather.pressure, equals(1100.0));
      });

      test('should handle extreme visibility values', () {
        // Arrange
        final noVisibilityWeather = testWeather.copyWith(visibility: 0);
        final maxVisibilityWeather = testWeather.copyWith(visibility: 50000);

        // Assert
        expect(noVisibilityWeather.visibility, equals(0));
        expect(maxVisibilityWeather.visibility, equals(50000));
      });

      test('should handle special characters in location and description', () {
        // Arrange
        const specialLocation = 'スペシャル場所: !@#\$%^&*()🎉🚀';
        const specialDescription = 'スペシャル天気: !@#\$%^&*()🎉🚀';

        // Act
        final specialWeather = testWeather.copyWith(
          location: specialLocation,
          description: specialDescription,
        );

        // Assert
        expect(specialWeather.location, equals(specialLocation));
        expect(specialWeather.description, equals(specialDescription));
      });

      test('should handle empty location and description', () {
        // Act
        final emptyWeather = testWeather.copyWith(
          location: '',
          description: '',
        );

        // Assert
        expect(emptyWeather.location, equals(''));
        expect(emptyWeather.description, equals(''));
      });

      test('should handle very long location and description', () {
        // Arrange
        final longLocation = 'A' * 1000;
        final longDescription = 'B' * 1000;

        // Act
        final longWeather = testWeather.copyWith(
          location: longLocation,
          description: longDescription,
        );

        // Assert
        expect(longWeather.location, equals(longLocation));
        expect(longWeather.description, equals(longDescription));
        expect(longWeather.location.length, equals(1000));
        expect(longWeather.description.length, equals(1000));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final sameWeather = WeatherEntity(
          temperature: 25.0,
          location: '東京',
          weatherId: 800,
          description: '晴れ',
          feelsLike: 27.0,
          humidity: 60,
          windSpeed: 5.0,
          iconCode: '01d',
          uvIndex: 6.0,
          visibility: 10000,
          pressure: 1013.25,
        );

        // Assert
        expect(testWeather, equals(sameWeather));
        expect(testWeather.hashCode, equals(sameWeather.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentWeather = testWeather.copyWith(temperature: 30.0);

        // Assert
        expect(testWeather, isNot(equals(differentWeather)));
        expect(testWeather.hashCode, isNot(equals(differentWeather.hashCode)));
      });

      test('should be equal to itself', () {
        // Assert
        expect(testWeather, equals(testWeather));
        expect(testWeather.hashCode, equals(testWeather.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testWeather.toString();

        // Assert
        expect(stringRepresentation, contains('WeatherEntity'));
        expect(stringRepresentation, contains('東京'));
        expect(stringRepresentation, contains('晴れ'));
      });
    });
  });

  group('WeatherLocationEntity', () {
    late WeatherLocationEntity testLocation;

    setUp(() {
      testLocation = WeatherLocationEntity(
        latitude: 35.6762,
        longitude: 139.6503,
        name: '東京',
      );
    });

    group('constructor', () {
      test('should create location with all parameters', () {
        // Act
        final location = WeatherLocationEntity(
          latitude: 34.6937,
          longitude: 135.5023,
          name: '大阪',
        );

        // Assert
        expect(location.latitude, equals(34.6937));
        expect(location.longitude, equals(135.5023));
        expect(location.name, equals('大阪'));
      });
    });

    group('edge cases', () {
      test('should handle extreme latitude values', () {
        // Arrange
        final northPoleLocation = testLocation.copyWith(latitude: 90.0);
        final southPoleLocation = testLocation.copyWith(latitude: -90.0);

        // Assert
        expect(northPoleLocation.latitude, equals(90.0));
        expect(southPoleLocation.latitude, equals(-90.0));
      });

      test('should handle extreme longitude values', () {
        // Arrange
        final eastLocation = testLocation.copyWith(longitude: 180.0);
        final westLocation = testLocation.copyWith(longitude: -180.0);

        // Assert
        expect(eastLocation.longitude, equals(180.0));
        expect(westLocation.longitude, equals(-180.0));
      });

      test('should handle special characters in name', () {
        // Arrange
        const specialName = 'スペシャル場所: !@#\$%^&*()🎉🚀';

        // Act
        final specialLocation = testLocation.copyWith(name: specialName);

        // Assert
        expect(specialLocation.name, equals(specialName));
      });

      test('should handle empty name', () {
        // Act
        final emptyLocation = testLocation.copyWith(name: '');

        // Assert
        expect(emptyLocation.name, equals(''));
      });

      test('should handle very long name', () {
        // Arrange
        final longName = 'A' * 1000;

        // Act
        final longLocation = testLocation.copyWith(name: longName);

        // Assert
        expect(longLocation.name, equals(longName));
        expect(longLocation.name.length, equals(1000));
      });
    });

    group('equality and hashCode', () {
      test('should be equal when all properties are same', () {
        // Arrange
        final sameLocation = WeatherLocationEntity(
          latitude: 35.6762,
          longitude: 139.6503,
          name: '東京',
        );

        // Assert
        expect(testLocation, equals(sameLocation));
        expect(testLocation.hashCode, equals(sameLocation.hashCode));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final differentLocation = testLocation.copyWith(name: '大阪');

        // Assert
        expect(testLocation, isNot(equals(differentLocation)));
        expect(
          testLocation.hashCode,
          isNot(equals(differentLocation.hashCode)),
        );
      });

      test('should be equal to itself', () {
        // Assert
        expect(testLocation, equals(testLocation));
        expect(testLocation.hashCode, equals(testLocation.hashCode));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        // Act
        final stringRepresentation = testLocation.toString();

        // Assert
        expect(stringRepresentation, contains('WeatherLocationEntity'));
        expect(stringRepresentation, contains('東京'));
      });
    });
  });
}
