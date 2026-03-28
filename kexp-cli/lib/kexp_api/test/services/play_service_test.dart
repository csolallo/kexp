import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'dart:convert';
import 'dart:io';

import '../../src/services/plays_service.dart';
import '../../src/models/song_model.dart';
import '../../src/models/airbreak_model.dart';

// run 'dart run build_runner build' to generate the mocks before running the tests
@GenerateNiceMocks([MockSpec<Client>()])
import '../helpers/play_service_tests.mocks.dart';

void main() {
    group("getPlays", () {
        var mockClient = MockClient();

        void mockPage(int n) {
            if (n == 0) {
                when(mockClient.get(
                    argThat(
                        predicate((Uri u) => !u.toString().contains("offset=")
                    )), 
                    headers: anyNamed('headers'))
                ).thenAnswer((_) async {
                    final file = File('test/data/twelve-hours/pg0.json');
                    final contents = await file.readAsBytes();

                    return Response(utf8.decode(contents), 200);
                });
            } else {
                when(mockClient.get
                    (argThat(
                        predicate((Uri u) => u.toString().contains("offset=${n*20}")
                    )), 
                    headers: anyNamed('headers'))
                ).thenAnswer((_) async {
                    final file = File('test/data/twelve-hours/pg$n.json');
                    final contents = await file.readAsBytes();

                    return Response(utf8.decode(contents), 200);
                });
            }
        }   

        setUp(() {
            reset(mockClient);
        });

        test("it should handle responses with both songs and air breaks", () async {
            when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
                final file = File('test/data/song+airbreak.json');
                final contents = await file.readAsString();

                return Future.value(Response(contents, 200));
            });

            PlayRequest request = PlayRequest.currentSongs(true, 2);
            PlayService service = PlayService(client: mockClient);
            var response = await service.getPlays(request);

            expect(response.length, 2);

            final airing_1 = response.elementAt(0);
            expect(airing_1.track is Song, true);

            final airing_2 = response.elementAt(1);
            expect(airing_2.track is Airbreak, true);
        });

        test("it should call the next url when it needs more elements", () async {
            when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
                final file = File('test/data/one-song-with-next.json');
                final contents = await file.readAsString();

                return Future.value(Response(contents, 200));
            });

            PlayRequest request = PlayRequest.currentSongs(true, 2);
            PlayService service = PlayService(client: mockClient);
            
            var response = await service.getPlays(request);
            expect(response.length, 2);

            verify(mockClient.get(any, headers: anyNamed('headers'))).called(2);
        });

        test("it should handle unbounded date parameters correctly", () async {
            // ignore: avoid_function_literals_in_foreach_calls
            Iterable<int>.generate(11).forEach((n) => mockPage(n));

            PlayRequest request = PlayRequest(true, null, "2025-11-03T13:00:00-0800", "2025-11-03T16:00:00-0800");
            PlayService service = PlayService(client: mockClient);

            var response = await service.getPlays(request);
            expect(response.length, 10);
        });

        test("number parameter should limit tracks returned for a date range", () async {
            // ignore: avoid_function_literals_in_foreach_calls
            Iterable<int>.generate(11).forEach((n) => mockPage(n));

            PlayRequest request = PlayRequest(true, 6, "2025-11-03T13:00:00-0800", "2025-11-03T16:00:00-0800");
            PlayService service = PlayService(client: mockClient);

            var response = await service.getPlays(request);
            expect(response.length, 6);
        });
    });
}
