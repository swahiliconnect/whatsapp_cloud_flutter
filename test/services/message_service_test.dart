import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:whatsapp_cloud_flutter/src/config/constants.dart';
import 'package:whatsapp_cloud_flutter/whatsapp_cloud_flutter.dart';

import '../mock_data/response_fixtures.dart';

// Create mock classes
class MockApiClient extends Mock implements ApiClient {}
class MockLogger extends Mock implements Logger {}

void main() {
  late MessageService messageService;
  late MockApiClient mockApiClient;
  late MockLogger mockLogger;

  const phoneNumberId = '1234567890';
  const recipient = '+9876543210';

  setUp(() {
    mockApiClient = MockApiClient();
    mockLogger = MockLogger();
    messageService = MessageService(
      apiClient: mockApiClient,
      phoneNumberId: phoneNumberId,
      logger: mockLogger,
    );
  });

  group('MessageService tests', () {
    test('sendTextMessage should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.sendTextMessage(
        recipient: recipient,
        text: 'Hello, World!',
      );

      // Assert
      expect(response.successful, isTrue);
      expect(response.messageId, 'wamid.123456789');
      expect(response.status, 'sent');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('sendTextMessage should return error response when API call fails', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => errorMessageResponse);

      // Act
      final response = await messageService.sendTextMessage(
        recipient: recipient,
        text: 'Hello, World!',
      );

      // Assert
      expect(response.successful, isFalse);
      expect(response.errorMessage, 'Invalid recipient');
      expect(response.errorCode, 'invalid_parameter');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('sendTextMessage should throw exception when validation fails', () {
      // Arrange & Act & Assert
      expect(
        () => messageService.sendTextMessage(
          recipient: recipient,
          text: '', // Empty text is invalid
        ),
        throwsA(isA<MessageException>()),
      );
    });

    test('sendImageMessage should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.sendImageMessage(
        recipient: recipient,
        source: MediaSource.url,
        mediaUrl: 'https://example.com/image.jpg',
        caption: 'Image caption',
      );

      // Assert
      expect(response.successful, isTrue);
      expect(response.messageId, 'wamid.123456789');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('sendLocationMessage should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.sendLocationMessage(
        recipient: recipient,
        latitude: 40.7128,
        longitude: -74.0060,
        name: 'New York City',
        address: 'New York, NY, USA',
      );

      // Assert
      expect(response.successful, isTrue);
      expect(response.messageId, 'wamid.123456789');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('sendCtaUrlMessage should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.sendCtaUrlMessage(
        recipient: recipient,
        bodyText: 'Check out our website',
        buttonText: 'Visit Website',
        url: 'https://example.com',
      );

      // Assert
      expect(response.successful, isTrue);
      expect(response.messageId, 'wamid.123456789');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('sendLocationRequestMessage should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.sendLocationRequestMessage(
        recipient: recipient,
        bodyText: 'Please share your location',
      );

      // Assert
      expect(response.successful, isTrue);
      expect(response.messageId, 'wamid.123456789');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('sendAddressMessage should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.sendAddressMessage(
        recipient: recipient,
        bodyText: 'Please provide your delivery address',
      );

      // Assert
      expect(response.successful, isTrue);
      expect(response.messageId, 'wamid.123456789');
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    test('markMessageAsRead should return success response when API call succeeds', () async {
      // Arrange
      when(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: anyNamed('data'),
      )).thenAnswer((_) async => successMessageResponse);

      // Act
      final response = await messageService.markMessageAsRead(
        messageId: 'wamid.123456789',
      );

      // Assert
      expect(response.successful, isTrue);
      verify(mockApiClient.post(
        '$phoneNumberId/${Constants.messagePath}',
        data: captureAnyNamed('data'),
      )).called(1);
    });

    // Add more tests as needed
  });
}