// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessCardAdapter extends TypeAdapter<BusinessCard> {
  @override
  final int typeId = 0;

  @override
  BusinessCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessCard(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      title: fields[3] as String,
      phone: fields[4] as String,
      email: fields[5] as String,
      company: fields[6] as String?,
      website: fields[7] as String?,
      address: fields[8] as String?,
      city: fields[9] as String?,
      postalCode: fields[10] as String?,
      country: fields[11] as String?,
      notes: fields[12] as String?,
      templateId: fields[13] as String,
      eventOverlayId: fields[14] as String?,
      customColors: (fields[15] as Map?)?.cast<String, String>(),
      logoPath: fields[16] as String?,
      backNotes: fields[17] as String?,
      backServices: (fields[18] as List?)
          ?.where((e) => e != null)
          .map((e) => e.toString())
          .toList(),
      backOpeningHours: fields[19] as String?,
      backSocialLinks: (fields[20] as Map?)?.cast<String, String>(),
      createdAt: fields[21] as DateTime?,
      updatedAt: fields[22] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessCard obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.company)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.city)
      ..writeByte(10)
      ..write(obj.postalCode)
      ..writeByte(11)
      ..write(obj.country)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.templateId)
      ..writeByte(14)
      ..write(obj.eventOverlayId)
      ..writeByte(15)
      ..write(obj.customColors)
      ..writeByte(16)
      ..write(obj.logoPath)
      ..writeByte(17)
      ..write(obj.backNotes)
      ..writeByte(18)
      ..write(obj.backServices)
      ..writeByte(19)
      ..write(obj.backOpeningHours)
      ..writeByte(20)
      ..write(obj.backSocialLinks)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
