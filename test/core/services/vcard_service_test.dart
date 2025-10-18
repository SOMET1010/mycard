import 'package:flutter_test/flutter_test.dart';
import 'package:mycard/core/services/vcard_service.dart';

void main() {
  group('VCardService', () {
    test('generateVCard should create valid vCard 3.0 format', () {
      final vCardContent = VCardService.generateVCard(
        firstName: 'John',
        lastName: 'Doe',
        title: 'Software Engineer',
        phone: '+1234567890',
        email: 'john.doe@example.com',
        company: 'Tech Corp',
        website: 'https://techcorp.com',
        address: '123 Main St',
        city: 'San Francisco',
        postalCode: '94105',
        country: 'USA',
      );

      expect(vCardContent, contains('BEGIN:VCARD'));
      expect(vCardContent, contains('VERSION:3.0'));
      expect(vCardContent, contains('FN:John Doe'));
      expect(vCardContent, contains('N:Doe;John;;;'));
      expect(vCardContent, contains('TEL;TYPE=CELL,VOICE:+1234567890'));
      expect(vCardContent, contains('EMAIL:john.doe@example.com'));
      expect(vCardContent, contains('TITLE:Software Engineer'));
      expect(vCardContent, contains('ORG:Tech Corp'));
      expect(vCardContent, contains('URL:https://techcorp.com'));
      expect(vCardContent, contains('ADR;TYPE=WORK:;;123 Main St;San Francisco;94105;USA;;'));
      expect(vCardContent, contains('END:VCARD'));
    });

    test('generateVCard should handle minimal data', () {
      final vCardContent = VCardService.generateVCard(
        firstName: 'Jane',
        lastName: 'Smith',
        phone: '+0987654321',
        email: 'jane@example.com',
      );

      expect(vCardContent, contains('FN:Jane Smith'));
      expect(vCardContent, contains('N:Smith;Jane;;;'));
      expect(vCardContent, contains('TEL;TYPE=CELL,VOICE:+0987654321'));
      expect(vCardContent, contains('EMAIL:jane@example.com'));
      expect(vCardContent, isNot(contains('TITLE:')));
      expect(vCardContent, isNot(contains('ORG:')));
    });

    test('generateFileName should sanitize name properly', () {
      final fileName = VCardService.generateFileName('John Doe Jr.');
      expect(fileName, equals('john_doe_jr_contact.vcf'));
    });

    test('generateFileName should handle special characters', () {
      final fileName = VCardService.generateFileName('Jean-Claude Van Damme');
      expect(fileName, equals('jean_claude_van_damme_contact.vcf'));
    });

    test('validateMinimumData should return true for valid data', () {
      final isValid = VCardService.validateMinimumData(
        firstName: 'John',
        lastName: 'Doe',
        phone: '+1234567890',
        email: 'john@example.com',
      );
      expect(isValid, isTrue);
    });

    test('validateMinimumData should return false for invalid email', () {
      final isValid = VCardService.validateMinimumData(
        firstName: 'John',
        lastName: 'Doe',
        phone: '+1234567890',
        email: 'invalid-email',
      );
      expect(isValid, isFalse);
    });

    test('validateMinimumData should return false for empty required fields', () {
      final isValid = VCardService.validateMinimumData(
        firstName: '',
        lastName: 'Doe',
        phone: '+1234567890',
        email: 'john@example.com',
      );
      expect(isValid, isFalse);
    });

    test('parseVCard should extract basic information', () {
      const vCardContent = '''
BEGIN:VCARD
VERSION:3.0
FN:John Doe
TEL:+1234567890
EMAIL:john@example.com
TITLE:Software Engineer
ORG:Tech Corp
URL:https://techcorp.com
END:VCARD
''';

      final parsed = VCardService.parseVCard(vCardContent);

      expect(parsed.firstName, equals('John'));
      expect(parsed.lastName, equals('Doe'));
      expect(parsed.phone, equals('+1234567890'));
      expect(parsed.email, equals('john@example.com'));
      expect(parsed.title, equals('Software Engineer'));
      expect(parsed.company, equals('Tech Corp'));
      expect(parsed.website, equals('https://techcorp.com'));
    });
  });
}