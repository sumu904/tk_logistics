import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Trip {
  final String tripNo;
  final String vehicleNumber;
  final String date;
  final String from;
  final String to;
  final String status;

  Trip({required this.tripNo,required this.vehicleNumber, required this.date, required this.from, required this.to, required this.status});
}

class TripHistoryController extends GetxController {
  var selectedDate = DateTime.now().obs; // Observable for selected date
  final DateFormat formatter = DateFormat('yyyy-MM-dd'); // Format date
  var filteredTrips = <Trip>[].obs; // List of trips to display

  // Sample trip history data
  final List<Trip> allTrips = [
    Trip(tripNo:"0001",vehicleNumber: "ABC-1234", date: "2025-03-01", from: "Dhanmondi", to: "Mirpur", status: "Cancelled"),
    Trip(tripNo:"0002",vehicleNumber: "XYZ-5678", date: "2025-02-28", from: "Gulshan", to: "Banani", status: "Completed"),
    Trip(tripNo:"0003",vehicleNumber: "LMN-9101", date: "2025-02-27", from: "Uttara", to: "Bashundhara", status: "Completed"),
    Trip(tripNo:"0004",vehicleNumber: "XYZ-5678", date: "2025-02-27", from: "Mohakhali", to: "Farmgate", status: "Cancelled"),
  ];

  @override
  void onInit() {
    filterTrips(); // Show today's trips by default
    super.onInit();
  }

  void pickDate(DateTime date) {
    selectedDate.value = date;
    filterTrips(); // Filter trips when date changes
  }

  void filterTrips() {
    String selected = formatter.format(selectedDate.value);
    filteredTrips.value = allTrips.where((trip) => trip.date == selected).toList();
  }
}

