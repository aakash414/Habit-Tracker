import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 0)
class UserData {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String nationality;

  @HiveField(3)
  final double weight;

  @HiveField(4)
  final double height;

  @HiveField(5)
  final double dailyFoodBudget;

  @HiveField(5)
  final double goalWeight;

  UserData(this.name, this.age, this.nationality, this.weight, this.height,
      this.dailyFoodBudget, this.goalWeight);
}

class UserDataAdapter extends TypeAdapter<UserData> {
  @override
  final int typeId = 0;

  @override
  UserData read(BinaryReader reader) {
    return UserData(
        reader.readString(),
        reader.readInt(),
        reader.readString(),
        reader.readDouble(),
        reader.readDouble(),
        reader.readDouble(),
        reader.readDouble());
  }

  @override
  void write(BinaryWriter writer, UserData obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.age);
    writer.writeString(obj.nationality);
    writer.writeDouble(obj.weight);
    writer.writeDouble(obj.height);
    writer.writeDouble(obj.dailyFoodBudget);
    writer.writeDouble(obj.goalWeight);
  }
}
